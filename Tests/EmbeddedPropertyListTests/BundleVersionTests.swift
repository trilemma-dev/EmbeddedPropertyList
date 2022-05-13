//
//  BundleVersionTests.swift
//  EmbeddedPropertyList
//
//  Created by Josh Kaplan on 2021-11-18
//

import XCTest
@testable import EmbeddedPropertyList

final class BundleVersionTests: XCTestCase {
    func testMajorVersion() {
        XCTAssertNotNil(BundleVersion(rawValue: "1"))
        XCTAssertNil(BundleVersion(rawValue: "1."))
        XCTAssertNil(BundleVersion(rawValue: "A"))
        XCTAssertNil(BundleVersion(rawValue: ""))
        XCTAssertNil(BundleVersion(rawValue: "."))
        XCTAssertNil(BundleVersion(rawValue: ".1"))
        XCTAssertNil(BundleVersion(rawValue: " .1"))
    }
    
    func testMinorVersion() {
        XCTAssertNotNil(BundleVersion(rawValue: "1.2"))
        XCTAssertNil(BundleVersion(rawValue: "1.2."))
        XCTAssertNil(BundleVersion(rawValue: "1.B"))
        XCTAssertNil(BundleVersion(rawValue: "A.B"))
    }
    
    func testPatchVersion() {
        XCTAssertNotNil(BundleVersion(rawValue: "1.2.3"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3."))
        XCTAssertNil(BundleVersion(rawValue: "1.2.C"))
        XCTAssertNil(BundleVersion(rawValue: "1.B.C"))
        XCTAssertNil(BundleVersion(rawValue: "A.B.C"))
    }
    
    func testPostPatchVersion() {
        XCTAssertNotNil(BundleVersion(rawValue: "1.2.3.4"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3.4."))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3.D"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.C.D"))
        XCTAssertNil(BundleVersion(rawValue: "1.B.C.D"))
        XCTAssertNil(BundleVersion(rawValue: "A.B.C.D"))
        
        XCTAssertNotNil(BundleVersion(rawValue: "1.2.3.4.5"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3.4.5."))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3.4.E"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.3.D.E"))
        XCTAssertNil(BundleVersion(rawValue: "1.2.C.D.E"))
        XCTAssertNil(BundleVersion(rawValue: "1.B.C.D.E"))
        XCTAssertNil(BundleVersion(rawValue: "A.B.C.D.E"))
    }
    
    struct Container: Decodable {
        let version: BundleVersion
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
