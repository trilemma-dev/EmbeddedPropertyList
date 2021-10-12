//
//  BundleVersion.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Represents a
/// [`CFBundleVersion`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleversion)
/// value typically found in an Info.plist.
///
/// Capable of representing any properly formatted version that matches one of:
///   - `major`
///   - `major.minor`
///   - `major.minor.patch`
///
/// Where `major`, `minor`, and `patch` must be `Int`s.
///
/// > Note: While this key is called `CFBundleVersion` it does not exclusively represent a **bundle's** version, it will typically also be present in the Info.plist
/// embedded in a Mach-O executable.
public struct BundleVersion: Comparable, Decodable, Hashable, RawRepresentable, CustomStringConvertible {

    public typealias RawValue = String
    
    /// The raw string representation of the version.
    public let rawValue: String
    
    /// The major version.
    public let major: Int
    
    /// The minor version.
    public let minor: Int
    
    /// The patch version.
    public let patch: Int
    
    /// Initializes from an encoded representation.
    ///
    /// - Parameter decoder: <#decoder description#>
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let bundleVersion = BundleVersion(rawValue: rawValue) {
            self = bundleVersion
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath,
                                  debugDescription: "\(rawValue) is not a valid build number",
                                  underlyingError: nil)
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    /// Initializes from a raw `String` representation.
    ///
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
        }
        else if versionParts.count == 2,
            let major = Int(versionParts[0]),
            let minor = Int(versionParts[1]) {
            self.major = major
            self.minor = minor
            self.patch = 0
        }
        else if versionParts.count == 3,
            let major = Int(versionParts[0]),
            let minor = Int(versionParts[1]),
            let patch = Int(versionParts[2]) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }
        else {
            return nil
        }
    }
    
    public var description: String {
        return rawValue
    }
    
    public static func < (lhs: BundleVersion, rhs: BundleVersion) -> Bool {
        var lessThan = false
        if lhs.major < rhs.major {
            lessThan = true
        }
        else if (lhs.major == rhs.major) &&
                (lhs.minor < rhs.minor) {
            lessThan = true
        }
        else if (lhs.major == rhs.major) &&
                (lhs.minor == rhs.minor) &&
                (lhs.patch < rhs.patch) {
            lessThan = true
        }
        
        return lessThan
    }
}
