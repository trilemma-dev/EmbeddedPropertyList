//
//  EmbeddedPropertyListReader.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Read a property list embedded in a Mach-O executable.
public enum EmbeddedPropertyListReader {
    /// An embedded info property list.
    case info
    /// An embedded launchd property list.
    case launchd
    /// A custom embedded property list type.
    ///
    /// The associated value must be the name of the `__TEXT` section within Mach-O header of the executable (or executable slice in the case of a universal
    /// binary).
    case other(String)
    
    /// The name of  `__TEXT` section within Mach-O header.
    private var sectionName: String {
        switch self {
            case .info:
                return "__info_plist"
            case .launchd:
                return "__launchd_plist"
            case .other(let userProvided):
                return userProvided
        }
    }
    
    /// Read the property list embedded within this executable.
    ///
    /// - Throws: If not running as a 64-bit executable then ``ReadError/unsupportedArchitecture`` will be thrown.
    /// - Returns: The property list as data.
    public func readInternal() throws -> Data {
        // By passing in nil, this returns a handle for the dynamic shared object (shared library) for this executable
        guard let handle = dlopen(nil, RTLD_LAZY) else {
            throw ReadError.machHeaderExecuteSymbolUnretrievable
        }
        defer { dlclose(handle) }
        
        guard let mhExecutePointer = dlsym(handle, MH_EXECUTE_SYM) else {
            throw ReadError.machHeaderExecuteSymbolUnretrievable
        }
        let mhExecuteBoundPointer = mhExecutePointer.assumingMemoryBound(to: mach_header_64.self)

        var size: UInt = 0
        guard let section = getsectiondata(mhExecuteBoundPointer, "__TEXT", self.sectionName, &size) else {
            throw ReadError.sectionNotFound
        }
        
        return Data(bytes: section, count: Int(size))
    }

    /// Read the property list embedded in an on disk executable.
    ///
    /// If this is a universal binary and multiple architecture slices are supported by this framework, then the property list for one of the architectures will be returned.
    /// Which architecture's property list is returned is undefined. However, in practice a given property list is likely to be identical across architectures.
    ///
    /// - Parameters:
    ///   - from: Location of the executable to be read.
    /// - Throws: Only 64-bit executables (or 64-bit slices of universal binaries) are supported; if the executable only contains unsupported architectures then
    /// ``ReadError/unsupportedArchitecture`` will be thrown.
    /// - Returns: The property list as data.
    public func readExternal(from executableURL: URL) throws -> Data {
        // Read the executable into a data instance
        let data = try Data(contentsOf: executableURL)
        
        // Determine if this is a Mach-O executable. If it's not, then trying to parse it is very likely to result in
        // bad memory access that will crash this process.
        let magic = readMagic(data, fromByteOffset: 0)
        if !isMagicFat(magic) && !isMagic32(magic) && !isMagic64(magic) {
            throw ReadError.notMachOExecutable
        }
        
        // Determine if this is a fat (universal) or single architecture executable. If it's a fat executable we'll need
        // to determine the offset of one or more of the architecture "slices" within it so that we can find the plist
        // data within those slices.
        let machHeaderOffset: UInt32
        if isMagicFat(magic) {
            let mustSwap = mustSwapEndianness(magic: magic)
            let offsets = machHeaderOffsetsForFatExecutable(data: data, mustSwap: mustSwap)
            guard let offset = offsets.first?.value else {
                throw ReadError.unsupportedArchitecture
            }
            machHeaderOffset = offset
        } else {
            if !isMagic64(magic) {
                // This implementation only supports 64-bit architectures.
                throw ReadError.unsupportedArchitecture
            }
            
            // When not a fat executable, the mach header starts at the beginning of the executable
            machHeaderOffset = 0
        }
        
        // The getsectbynamefromheader_64 function expects the mach_header_64 pointer to be part of a contiguous block
        // of memory that contains (at least) the entire mach-o data structure; passing in a pointer to just the
        // mach_header_64 struct which is disassociated from the rest of the header will result in bad memory access and
        // therefore crash this process.
        // Function source code: https://opensource.apple.com/source/cctools/cctools-895/libmacho/getsecbyname.c.auto.html
        let offsetData = data[Data.Index(machHeaderOffset)..<data.count]
        let plist: Data = try offsetData.withUnsafeBytes { pointer in
            let headerPointer = pointer.bindMemory(to: mach_header_64.self).baseAddress
            guard let sectionPointer = getsectbynamefromheader_64(headerPointer, "__TEXT", self.sectionName) else {
                throw ReadError.sectionNotFound
            }
            
            // This section does not contain the property list itself, but instead describes where within this slice
            // the property list exists
            let plistDataRangeStart = Data.Index(offsetData.startIndex + Int(sectionPointer.pointee.offset))
            let plistDataRangeEnd = Data.Index(plistDataRangeStart + Int(sectionPointer.pointee.size))
            
            return offsetData[plistDataRangeStart..<plistDataRangeEnd]
        }
        
        return plist
    }

    /// Reads a portion of data as the specified type.
    ///
    /// - Parameters:
    ///   - _: The executable's bytes.
    ///   - as: The type to read the data as.
    ///   - fromByteOffset: Relative to the start of `data` where to start reading the value.
    /// - Returns: The `data` starting at `offset` as an instance of `asType`.
    private func read<T>(_ data: Data, as type: T.Type, fromByteOffset offset: Int) -> T {
        data.withUnsafeBytes { pointer in
            pointer.load(fromByteOffset: offset, as: type)
        }
    }

    /// Reads the magic value from the start of the executable as well as any architecture slices within in it (when a universal binary)
    ///
    /// - Parameters:
    ///   - _: The executable's bytes.
    ///   - fromByteOffset: Relative to the start of `data` where to start reading the magic value.
    /// - Returns: The magic value.
    private func readMagic(_ data: Data, fromByteOffset offset: Int) -> UInt32 {
        return read(data, as: UInt32.self, fromByteOffset: offset)
    }

    /// Whether the magic value represents an executable for a 32-bit architecture.
    ///
    /// If the magic value passed in doesn't represent a executable header and instead represents a fat header, then false will be returned. As such, using this
    /// function cannot allow you to distinguish between a fat executable and a 64-bit executable or slice. Use `isMagicFat()` for this purpose.
    ///
    /// - Parameters:
    ///   - _: The magic value.
    /// - Returns: Whether the magic value represents a 32-bit architecture executable.
    private func isMagic32(_ magic: UInt32) -> Bool {
        return (magic == MH_MAGIC) || (magic == MH_CIGAM)
    }

    /// Whether the magic value represents a executable for a 64-bit architecture.
    ///
    /// If the magic value passed in doesn't represent an executable header and instead represents a fat header, then false will be returned. As such, using this
    /// function cannot allow you to distinguish between a fat executable and a 32-bit executable or slice. Use `isMagicFat()` for this purpose.
    ///
    /// - Parameters:
    ///   - _: The magic value.
    /// - Returns: Whether the magic value represents a 64-bit architecture executable.
    private func isMagic64(_ magic: UInt32) -> Bool {
        return (magic == MH_MAGIC_64) || (magic == MH_CIGAM_64)
    }

    /// Whether the magic value represents a fat executable (universal binary).
    ///
    /// - Parameters:
    ///   - _: The magic value.
    /// - Returns: Whether the magic value represents a fat executable (universal binary).
    private func isMagicFat(_ magic: UInt32) -> Bool {
      return (magic == FAT_MAGIC) || (magic == FAT_CIGAM)
    }

    /// Whether endianness of the fat or mach header that proceeds this magic value must be swapped.
    ///
    /// - Parameters:
    ///   - magic: The magic value
    /// - Returns: Whether the magic value represents the oppositie endianness.
    private func mustSwapEndianness(magic: UInt32) -> Bool {
        return (magic == MH_CIGAM) || (magic == MH_CIGAM_64) || (magic == FAT_CIGAM)
    }

    /// Finds the offsets within the executable of where the mach header for each slice of the fat executable (universal binary) is located.
    ///
    /// - Parameters:
    ///   - data: Data representing the fat executable (universal binary). This function assumes, and performs no error checking, that the data passed in
    ///           represents a fat executable. If it does not, behavior is undefined and it's likely that a fatal bad memory access will occur.
    ///   - mustSwap: Whether the data representing the fat header must have it endianness swapped.
    /// - Returns: A dictionary of CPU types to mach headers within the executable. Only 64-bit CPU types are included.
    private func machHeaderOffsetsForFatExecutable(data: Data, mustSwap: Bool) -> [cpu_type_t : UInt32] {
        // To populate with offsets
        var archOffsets = [cpu_type_t : UInt32]()
        
        // In practice the fat header and fat arch data is always in big-endian byte order while x86_64 (Intel) and
        // arm64 (Apple Silicon) are little-endian. So the byte orders are always going to need to be swapped. The code
        // here does not assume this to be true, but it's helpful to keep in mind if ever debugging this code.
        var header = read(data, as: fat_header.self, fromByteOffset: 0)
        if mustSwap {
            swap_fat_header(&header, NXHostByteOrder())
        }
        
        // Loop through all of the architecture descriptions in the fat executable (in practice there will typically be
        // 2). These descriptions start immediately after the fat header, so start the offset there.
        var archOffset = MemoryLayout<fat_header>.size
        for _ in 0..<header.nfat_arch {
            var arch = read(data, as: fat_arch.self, fromByteOffset: archOffset)
            if mustSwap {
                swap_fat_arch(&arch, 1, NXHostByteOrder())
            }
            
            // This implementation only supports 64-bit architectures.
            if isMagic64(readMagic(data, fromByteOffset: Int(arch.offset))) {
                archOffsets[arch.cputype] = arch.offset
            }
            
            // Increment the offset for the next loop
            archOffset += MemoryLayout<fat_arch>.size
        }
        
        return archOffsets
    }
}
