//
//  CBORDecoderTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
import XCTest

class CBORDecoderTests: XCTestCase {
  static var allTests = [
    ("testDecodeNull", testDecodeNull),
    ("testDecodeBools", testDecodeBools),
    ("testDecodeInts", testDecodeInts),
    ("testDecodeNegativeInts", testDecodeNegativeInts),
    ("testDecodeStrings", testDecodeStrings),
    ("testDecodeByteStrings", testDecodeByteStrings),
    ("testDecodeArrays", testDecodeArrays),
    ("testDecodeMaps", testDecodeMaps),
    ("testDecodeDates", testDecodeDates),
  ]

  func testDecodeNull() {
    XCTAssertNil(try CBORDecoder().decodeIfPresent(String.self, from: Data([0xF6])))
  }

  func testDecodeBools() {
    XCTAssertEqual(try CBORDecoder().decode(Bool.self, from: Data([0xF4])), false)
    XCTAssertEqual(try CBORDecoder().decode(Bool.self, from: Data([0xF5])), true)
  }

  func testDecodeInts() {
    // Less than 24
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x00])), 0)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x08])), 8)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x0A])), 10)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x17])), 23)

    // Just bigger than 23
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x18, 0x18])), 24)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x18, 0x19])), 25)

    // Bigger
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x18, 0x64])), 100)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x19, 0x03, 0xE8])), 1000)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x1A, 0x00, 0x0F, 0x42, 0x40])), 1000000)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x1B, 0x00, 0x00, 0x00, 0xE8, 0xD4, 0xA5, 0x10, 0x00])), 1000000000000)

    // TODO: Tagged byte strings for big numbers
    //        let bigNum = try CBORDecoder().decode(Int.self, from: Data([0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    //        XCTAssertEqual(bigNum, 18_446_744_073_709_551_615)
    //        let biggerNum = try CBORDecoder().decode(Int.self, from: Data([0x2c, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,]))
    //        XCTAssertEqual(biggerNum, 18_446_744_073_709_551_616)
  }

  func testDecodeNegativeInts() {
    // Less than 24
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x20])), -1)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x29])), -10)

    // Bigger
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x38, 0x63])), -100)
    XCTAssertEqual(try CBORDecoder().decode(Int.self, from: Data([0x39, 0x03, 0xE7])), -1000)

    // Overflow
    XCTAssertThrowsError(try CBORDecoder().decode(Int8.self, from: Data([0x38, 0x80])))

    // TODO: Tagged byte strings for big numbers
    //        let bigNum = try CBORDecoder().decode(Int.self, from: Data([0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
    //        XCTAssertEqual(bigNum, 18_446_744_073_709_551_615)
    //        let biggerNum = try CBORDecoder().decode(Int.self, from: Data([0x2c, 0x49, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,]))
    //        XCTAssertEqual(biggerNum, 18_446_744_073_709_551_616)
  }

  func testDecodeStrings() {
    XCTAssertEqual(try CBORDecoder().decode(String.self, from: Data([0x60])), "")
    XCTAssertEqual(try CBORDecoder().decode(String.self, from: Data([0x61, 0x61])), "a")
    XCTAssertEqual(try CBORDecoder().decode(String.self, from: Data([0x64, 0x49, 0x45, 0x54, 0x46])), "IETF")
    XCTAssertEqual(try CBORDecoder().decode(String.self, from: Data([0x62, 0x22, 0x5C])), "\"\\")
    XCTAssertEqual(try CBORDecoder().decode(String.self, from: Data([0x62, 0xC3, 0xBC])), "\u{00FC}")

  }

  func testDecodeByteStrings() {
    XCTAssertEqual(try CBORDecoder().decode(Data.self, from: Data([0x44, 0x01, 0x02, 0x03, 0x04])),
                   Data([0x01, 0x02, 0x03, 0x04]))
    XCTAssertEqual(try CBORDecoder().decode(Data.self, from: Data([0x5F, 0x42, 0x01, 0x02, 0x43, 0x03, 0x04, 0x05, 0xFF])),
                   Data([0x01, 0x02, 0x03, 0x04, 0x05]))
  }

  func testDecodeArrays() {
    XCTAssertEqual(try CBORDecoder().decode([String].self, from: Data([0x80])),
                   [])
    XCTAssertEqual(try CBORDecoder().decode([Int].self, from: Data([0x83, 0x01, 0x02, 0x03])),
                   [1, 2, 3])
    XCTAssertEqual(try CBORDecoder().decode([Int].self, from: Data([0x98, 0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x18, 0x18, 0x19])),
                   [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25])
    XCTAssertEqual(try CBORDecoder().decode([[Int]].self, from: Data([0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05])),
                   [[1], [2, 3], [4, 5]])
    // indefinite
    XCTAssertEqual(try CBORDecoder().decode([Int].self, from: Data([0x9F, 0x04, 0x05, 0xFF])),
                   [4, 5])
    XCTAssertEqual(try CBORDecoder().decode([[Int]].self, from: Data([0x9F, 0x81, 0x01, 0x82, 0x02, 0x03, 0x9F, 0x04, 0x05, 0xFF, 0xFF])),
                   [[1], [2, 3], [4, 5]])
  }

  func testDecodeMaps() {
    XCTAssertEqual(try CBORDecoder().decode([String: String].self, from: Data([0xA0])),
                   [:])
    XCTAssertEqual(try CBORDecoder().decode([String: String].self, from: Data([0xA5, 0x61, 0x61, 0x61, 0x41, 0x61, 0x62, 0x61, 0x42, 0x61, 0x63, 0x61, 0x43, 0x61, 0x64, 0x61, 0x44, 0x61, 0x65, 0x61, 0x45])),
                   ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"])
    XCTAssertEqual(try CBORDecoder().decode([Int: Int].self, from: Data([0xA2, 0x01, 0x02, 0x03, 0x04])), [1: 2, 3: 4])
    XCTAssertEqual(try CBORDecoder().decode([String: String].self, from: Data([0xBF, 0x63, 0x46, 0x75, 0x6E, 0x61, 0x62, 0x63, 0x41, 0x6D, 0x74, 0x61, 0x63, 0xFF])),
                   ["Fun": "b", "Amt": "c"])
    XCTAssertEqual(try CBORDecoder().decode([String: [String: String]].self, from: Data([0xBF, 0x63, 0x46, 0x75, 0x6E, 0xA1, 0x61, 0x62, 0x61, 0x42, 0x63, 0x41, 0x6D, 0x74, 0xBF, 0x61, 0x63, 0x61, 0x43, 0xFF, 0xFF])),
                   ["Fun": ["b": "B"], "Amt": ["c": "C"]])
  }

  func testDecodingDoesntTranslateMapKeys() throws {
    let decoder = CBORDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let dict = try decoder.decodeTree([String: Int].self, from: .map(["this_is_an_example_key": 0]))
    XCTAssertEqual(dict.keys.first, "this_is_an_example_key")
  }

  func testDecodeDates() {
    let expectedDateOne = Date(timeIntervalSince1970: 1363896240)
    XCTAssertEqual(try CBORDecoder().decode(Date.self, from: Data([0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])), expectedDateOne)
    let expectedDateTwo = Date(timeIntervalSince1970: 1363896240.5)
    XCTAssertEqual(try CBORDecoder().decode(Date.self, from: Data([0xC1, 0xFB, 0x41, 0xD4, 0x52, 0xD9, 0xEC, 0x20, 0x00, 0x00])), expectedDateTwo)
  }
}

