//
//  VersionTests.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-11-18
//

import XCTest
@testable import EmbeddedPropertyList

final class VersionTests: XCTestCase {
    func testMajorVersion() {
        XCTAssertNotNil(Version(rawValue: "1"))
        XCTAssertNil(Version(rawValue: "A"))
        XCTAssertNil(Version(rawValue: ""))
        XCTAssertNil(Version(rawValue: "."))
        XCTAssertNil(Version(rawValue: ".1"))
        XCTAssertNil(Version(rawValue: " .1"))
    }
    
    func testMinorVersion() {
        XCTAssertNotNil(Version(rawValue: "1.2"))
        XCTAssertNil(Version(rawValue: "1.B"))
        XCTAssertNil(Version(rawValue: "A.B"))
    }
    
    func testPatchVersion() {
        XCTAssertNotNil(Version(rawValue: "1.2.3"))
        XCTAssertNil(Version(rawValue: "1.2.C"))
        XCTAssertNil(Version(rawValue: "1.B.C"))
        XCTAssertNil(Version(rawValue: "A.B.C"))
    }
    
    func testPostPatchVersion() {
        XCTAssertNotNil(Version(rawValue: "1.2.3.4"))
        XCTAssertNil(Version(rawValue: "1.2.3.D"))
        XCTAssertNil(Version(rawValue: "1.2.C.D"))
        XCTAssertNil(Version(rawValue: "1.B.C.D"))
        XCTAssertNil(Version(rawValue: "A.B.C.D"))
        
        XCTAssertNotNil(Version(rawValue: "1.2.3.4.5"))
        XCTAssertNil(Version(rawValue: "1.2.3.4.E"))
        XCTAssertNil(Version(rawValue: "1.2.3.D.E"))
        XCTAssertNil(Version(rawValue: "1.2.C.D.E"))
        XCTAssertNil(Version(rawValue: "1.B.C.D.E"))
        XCTAssertNil(Version(rawValue: "A.B.C.D.E"))
    }
    
    struct Container: Decodable {
        let version: Version
        let other: Int
    }
    
    func testDecodeValid() throws {
        let versionRawValue = "1.0.6"
        let serialized = try PropertyListSerialization.data(fromPropertyList: ["version": versionRawValue,
                                                                               "other": 5],
                                                            format: .xml,
                                                            options: 0)
        let container = try PropertyListDecoder().decode(Container.self, from: serialized)
        XCTAssertEqual(container.version.rawValue, versionRawValue)
    }
    
    func testDecodeInvalid() throws {
        let versionRawValue = "1.0.a"
        let serialized = try PropertyListSerialization.data(fromPropertyList: ["version": versionRawValue,
                                                                               "other": 5],
                                                            format: .xml,
                                                            options: 0)
        do {
            _  = try PropertyListDecoder().decode(Container.self, from: serialized)
            XCTFail("Error expected to be thrown, but was not")
        } catch DecodingError.dataCorrupted(_) {
            // Expected
        } catch {
            XCTFail("Unexpected error was thrown: \(error)")
        }
    }
}
