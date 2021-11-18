//
//  Version.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Represent a version as is typically included in an info property list.
///
/// Capable of representing any version with a format that matches one of:
///   - `major`
///   - `major.minor`
///   - `major.minor.patch`
///
/// `major`, `minor`, and `patch` must be `Int`s. Any values not provided will be represented as `0`. For example if this represents `6.4` then `patch`
/// will be `0`. This matches
/// [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion)
/// semantics.
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
    ///
    ///     Where `major`, `minor`, and `patch` are `Int`s.
    public init?(rawValue: String) {
        self.rawValue = rawValue
        
        let versionParts = rawValue.split(separator: ".")
        if versionParts.count == 1,
           let major = Int(versionParts[0]) {
            self.major = major
            self.minor = 0
            self.patch = 0
        } else if versionParts.count == 2,
            let major = Int(versionParts[0]),
            let minor = Int(versionParts[1]) {
            self.major = major
            self.minor = minor
            self.patch = 0
        } else if versionParts.count == 3,
            let major = Int(versionParts[0]),
            let minor = Int(versionParts[1]),
            let patch = Int(versionParts[2]) {
            self.major = major
            self.minor = minor
            self.patch = patch
        } else {
            return nil
        }
    }
}

extension Version: CustomStringConvertible {
    /// A textual representation of this version.
    public var description: String {
        return "\(self.major).\(self.minor).\(self.patch)"
    }
}

extension Version: Hashable {
    /// Hashes this version.
    ///
    /// Hashing does not take ``rawValue-swift.property`` into account, so for example `6.4` and `6.4.0` will intentionally hash to the same value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.major)
        hasher.combine(self.minor)
        hasher.combine(self.patch)
    }
    
    /// Determines equality of two `Version` instances.
    ///
    ///
    /// The ``rawValue-swift.property`` is not considered, meaning `6.4` and `6.4.0` are intentionally considered equal.
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return (lhs.major == rhs.major) && (lhs.minor == rhs.minor) && (lhs.patch == rhs.patch)
    }
}

extension Version: Comparable {
    /// Semantically compares two `Version` instances.
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
