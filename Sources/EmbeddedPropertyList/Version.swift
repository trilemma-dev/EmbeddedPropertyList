//
//  Version.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Represents a
/// [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion)
/// value as found in info property lists.
///
/// Capable of representing any version with a format that matches one of:
///   - `major`
///   - `major.minor`
///   - `major.minor.patch`
///       - More values after `patch` may be provided, but will be ignored in comparison and equality checks.
///
/// `major`, `minor`, and `patch` must be representable as `Int`s. Any values not provided will be represented as `0`. For example if this represents
/// `1.2` then `patch` will be `0`. This matches `CFBundleVersion` semantics.
///
/// > Note: `CFBundleVersion` does not exclusively represent a **bundle's** version. A Mach-O executable's info property list often contains this key.
public struct Version: RawRepresentable {

    public typealias RawValue = String
    
    /// The raw string representation of this version.
    public let rawValue: String
    
    /// The major version.
    public let major: Int
    
    /// The minor version.
    ///
    /// `0` if not specified.
    public let minor: Int
    
    /// The patch version.
    ///
    /// `0` if not specified.
    public let patch: Int
    
    /// Initializes from a raw `String` representation.
    ///
    /// - Parameters:
    ///   - rawValue: To successfully initialize, the `rawValue` must match one of:
    ///     - `major`
    ///     - `major.minor`
    ///     - `major.minor.patch`
    ///         - More values after `patch` may be provided, but will be ignored in comparison and equality checks.
    ///
    ///     Where `major`, `minor`, `patch` and any additional values are `Int`s.
    public init?(rawValue: String) {
        self.rawValue = rawValue
        
        // MARK: Validation
        
        // Must start with an integer, not a seperator
        if rawValue.starts(with: ".") {
            return nil
        }
        
        let versionParts = rawValue.split(separator: ".")
        
        // At least one part must exist
        if versionParts.isEmpty {
            return nil
        }
        
        // All parts must be integers
        var intParts = [Int]()
        for versionPart in versionParts {
            if let part = Int(versionPart) {
                intParts.append(part)
            } else {
                return nil
            }
        }
        
        // MARK: Initialization
        
        if intParts.count == 1 {
            self.major = intParts[0]
            self.minor = 0
            self.patch = 0
        } else if intParts.count == 2 {
            self.major = intParts[0]
            self.minor = intParts[1]
            self.patch = 0
        } else {
            self.major = intParts[0]
            self.minor = intParts[1]
            self.patch = intParts[2]
        }
    }
}

extension Version: CustomStringConvertible {
    /// A textual representation of this version.
    public var description: String {
        return "\(self.major).\(self.minor).\(self.patch) (\(self.rawValue))"
    }
}

extension Version: Hashable {
    /// Hashes this version.
    ///
    /// Hashing does not take ``rawValue-swift.property`` into account, this means the following will hash identically:
    ///  - `1.` and `1.0.0`
    ///  - `1.2` and `1.2.0`
    ///  - `1.2.3` and `1.2.3.a`
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.major)
        hasher.combine(self.minor)
        hasher.combine(self.patch)
    }
    
    /// Determines equality of two `Version` instances.
    ///
    /// The ``rawValue-swift.property`` is not considered, this means the following will evaluate as equal:
    ///  - `1.` and `1.0.0`
    ///  - `1.2` and `1.2.0`
    ///  - `1.2.3` and `1.2.3.a`
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return (lhs.major == rhs.major) && (lhs.minor == rhs.minor) && (lhs.patch == rhs.patch)
    }
}

extension Version: Comparable {
    /// Semantically compares two `Version` instances.
    ///
    /// When comparing versions, any values beyond ``patch`` will not be taken into account.
    public static func < (lhs: Version, rhs: Version) -> Bool {
        var lessThan = false
        if lhs.major < rhs.major {
            lessThan = true
        } else if lhs.major == rhs.major, lhs.minor < rhs.minor {
            lessThan = true
        } else if lhs.major == rhs.major, lhs.minor == rhs.minor, lhs.patch < rhs.patch {
            lessThan = true
        }
        
        return lessThan
    }
}

extension Version: Decodable {
    /// Initializes from an encoded representation.
    ///
    /// - Parameter decoder: Decoder containing an encoded representation of a version.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let bundleVersion = Version(rawValue: rawValue) {
            self = bundleVersion
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                                debugDescription: "\(rawValue) is not a valid build number",
                                                underlyingError: nil)
            throw DecodingError.dataCorrupted(context)
        }
    }
}
