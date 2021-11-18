//
//  ReadExternalTests.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-11-18
//

import XCTest
@testable import EmbeddedPropertyList

final class ReadExternalTests: XCTestCase {
    
    func testInfoReadIntelx86_64() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.intelx86_64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    func testInfoReadUniversalBinary() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.universalBinary)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    func testLaunchdReadIntelx86_64() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.intelx86_64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
    
    func testLaunchdReadUniversalBinary() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.universalBinary)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
}
