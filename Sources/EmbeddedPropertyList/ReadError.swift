//
//  ReadError.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-10-13
//

import Foundation

/// Errors that may occur while try to read embedded property lists.
public enum ReadError: Error {
    /// The `__TEXT` section within the embedded property list that describes where the property list is stored was not found.
    case sectionNotFound
    /// The provided URL does not reference an executable with a Mach-O header.
    case notMachOExecutable
    /// None of the Mach-O header(s) ins the executable are supported.
    ///
    /// `x86_64` (Intel) and `arm64` (Apple Silicon) are supported.
    case unsupportedArchitecture
    /// The mach header execute symbol for the Mach-O executable could not be retrieved.
    ///
    /// This is an internal error.
    case machHeaderExecuteSymbolUnretrievable
}
