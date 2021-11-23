//
//  ReadExternalTests.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-11-18
//

import XCTest
@testable import EmbeddedPropertyList

final class ReadExternalTests: XCTestCase {
    
    // MARK: Info
    
    func testInfoReadIntelx86_64__for_x86_64Slice_IgnoredParameter() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.intelx86_64,
                                                                         forSlice: .x86_64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    func testInfoReadIntelx86_64__for_arm64Slice_IgnoredParameter() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.intelx86_64,
                                                                         forSlice: .arm64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    func testInfoReadUniversalBinary__for_x86_64Slice() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.universalBinary,
                                                                         forSlice: .x86_64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    func testInfoReadUniversalBinary__for_arm64Slice() throws {
        let plistData = try EmbeddedPropertyListReader.info.readExternal(from: TestExecutables.universalBinary,
                                                                         forSlice: .arm64)
        let plist = try PropertyListDecoder().decode(InfoPropertyList.self, from: plistData)
        XCTAssertEqual(plist.bundleIdentifier, InfoPropertyList.bundleIdentifierValue)
        XCTAssertEqual(plist.bundleVersion.rawValue, InfoPropertyList.bundleVersionValue)
    }
    
    // MARK: launchd
    
    func testLaunchdReadIntelx86_64__for_x86_64Slice_IgnoredParameter() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.intelx86_64,
                                                                            forSlice: .x86_64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
    
    func testLaunchdReadIntelx86_64__for_arm64Slice_IgnoredParameter() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.intelx86_64,
                                                                            forSlice: .arm64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
    
    func testLaunchdReadUniversalBinary__for_x86_64Slice() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.universalBinary,
                                                                            forSlice: .x86_64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
    
    func testLaunchdReadUniversalBinary__for_arm64Slice() throws {
        let plistData = try EmbeddedPropertyListReader.launchd.readExternal(from: TestExecutables.universalBinary,
                                                                            forSlice: .arm64)
        let plist = try PropertyListDecoder().decode(LaunchdPropertyList.self, from: plistData)
        XCTAssertEqual(plist.label, LaunchdPropertyList.labelValue)
    }
}
