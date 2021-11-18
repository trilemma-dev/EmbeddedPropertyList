//
//  ReadExternalTests.swift
//  
//
//  Created by Josh Kaplan on 2021-11-18
//

import XCTest
@testable import EmbeddedPropertyList


final class ReadExternalTests: XCTestCase {
    
    func testInfoReadIntelx64_86() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.intelx86_64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.CFBundleIdentifier, "com.example.TestCLT")
        XCTAssertEqual(plist.CFBundleVersion.rawValue, "1.2.3")
    }
    
    func testInfoReadUniversalBinary() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.universalBinary)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.CFBundleIdentifier, "com.example.TestCLT")
        XCTAssertEqual(plist.CFBundleVersion.rawValue, "1.2.3")
    }
    
    func testLaunchdReadIntelx64_86() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.intelx86_64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.Label, "RepresentativeValue")
    }
    
    func testLaunchdReadUniversalBinary() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.universalBinary)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.Label, "RepresentativeValue")
    }
}
