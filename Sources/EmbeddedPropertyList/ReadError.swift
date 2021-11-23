//
//  ReadError.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Errors that may occur while trying to read embedded property lists.
public enum ReadError: Error {
    /// The `__TEXT` section describing where the property list is stored was not found in the Mach-O header.
    case sectionNotFound
    /// The file is not an executable with a Mach-O header.
    case notMachOExecutable
    /// None of the Mach-O header architectures in the executable are supported.
    ///
    /// `x86_64` (Intel) and `arm64` (Apple Silicon) architectures are supported.
    case unsupportedArchitecture
    /// The requested universal binary slice type was not present in the Mach-O executable.
    case universalBinarySliceUnavailable
    /// The mach header execute symbol for the Mach-O executable could not be retrieved.
    ///
    /// This is an internal error.
    case machHeaderExecuteSymbolUnretrievable
    /// The architecture of this Mac could not be determiend.
    ///
    /// This is an internal error.
    case architectureNotDetermined
}
