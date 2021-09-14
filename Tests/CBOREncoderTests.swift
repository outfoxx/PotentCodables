/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@testable import PotentCBOR
@testable import PotentCodables
import XCTest


class CBOREncoderTests: XCTestCase {
  static var allTests = [
    ("testEncodeNull", testEncodeNull),
    ("testEncodeBools", testEncodeBools),
    ("testEncodeInts", testEncodeInts),
    ("testEncodeNegativeInts", testEncodeNegativeInts),
    ("testEncodeStrings", testEncodeStrings),
    ("testEncodeByteStrings", testEncodeByteStrings),
    ("testEncodeArrays", testEncodeArrays),
    ("testEncodeMaps", testEncodeMaps),
    ("testEncodeSimpleStructs", testEncodeSimpleStructs),
  ]

  func encode<T: Encodable>(_ value: T, dates: CBOREncoder.DateEncodingStrategy = .iso8601) throws -> [UInt8] {
    return Array(try CBOREncoder().encode(value))
  }

  func testEncodeNull() {
    XCTAssertEqual(try encode(String?(nil)), [0xF6])
  }

  func testEncodeBools() {
    XCTAssertEqual(try encode(false), [0xF4])
    XCTAssertEqual(try encode(true), [0xF5])
  }

  func testEncodeInts() {
    // Less than 24
    XCTAssertEqual(try encode(0), [0x00])
    XCTAssertEqual(try encode(8), [0x08])
    XCTAssertEqual(try encode(10), [0x0A])
    XCTAssertEqual(try encode(23), [0x17])

    // Just bigger than 23
    XCTAssertEqual(try encode(24), [0x18, 0x18])
    XCTAssertEqual(try encode(25), [0x18, 0x19])

    // Bigger
    XCTAssertEqual(try encode(100), [0x18, 0x64])
    XCTAssertEqual(try encode(1000), [0x19, 0x03, 0xE8])
    XCTAssertEqual(try encode(1_000_000), [0x1A, 0x00, 0x0F, 0x42, 0x40])
    XCTAssertEqual(try encode(Int64(1_000_000_000_000)), [0x1B, 0x00, 0x00, 0x00, 0xE8, 0xD4, 0xA5, 0x10, 0x00])

    // Biggest
    XCTAssertEqual(try encode(UInt64(18_446_744_073_709_551_615)), [0x1b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
  }

  func testEncodeNegativeInts() {
    // Less than 24
    XCTAssertEqual(try encode(-1), [0x20])
    XCTAssertEqual(try encode(-10), [0x29])

    // Bigger
    XCTAssertEqual(try encode(-100), [0x38, 0x63])
    XCTAssertEqual(try encode(-1000), [0x39, 0x03, 0xE7])

    // Biggest
    XCTAssertEqual(try encode(Int64(-9_223_372_036_854_775_808)), [0x3b, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
  }

  func testEncodeStrings() {
    XCTAssertEqual(try encode(""), [0x60])
    XCTAssertEqual(try encode("a"), [0x61, 0x61])
    XCTAssertEqual(try encode("IETF"), [0x64, 0x49, 0x45, 0x54, 0x46])
    XCTAssertEqual(try encode("\"\\"), [0x62, 0x22, 0x5C])
    XCTAssertEqual(try encode("\u{00FC}"), [0x62, 0xC3, 0xBC])
  }

  func testEncodeByteStrings() {
    XCTAssertEqual(try encode(Data([0x01, 0x02, 0x03, 0x04])), [0x44, 0x01, 0x02, 0x03, 0x04])
  }

  func testEncodeArrays() {
    XCTAssertEqual(
      try encode([String]()),
      [0x80]
    )
    XCTAssertEqual(
      try encode([1, 2, 3]),
      [0x83, 0x01, 0x02, 0x03]
    )
    XCTAssertEqual(
      try encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]),
      [
        0x98,
        0x19,
        0x01,
        0x02,
        0x03,
        0x04,
        0x05,
        0x06,
        0x07,
        0x08,
        0x09,
        0x0A,
        0x0B,
        0x0C,
        0x0D,
        0x0E,
        0x0F,
        0x10,
        0x11,
        0x12,
        0x13,
        0x14,
        0x15,
        0x16,
        0x17,
        0x18,
        0x18,
        0x18,
        0x19,
      ]
    )
    XCTAssertEqual(
      try encode([[1], [2, 3], [4, 5]]),
      [0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05]
    )
  }

  func testEncodeMaps() throws {
    XCTAssertEqual(try encode([String: String]()), [0xA0])

    let stringToString = try encode(["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"])
    XCTAssertEqual(stringToString.first!, 0xA5)

    let dataMinusFirstByte = stringToString[1...].map { $0 }.chunked(into: 4)
      .sorted(by: { $0.lexicographicallyPrecedes($1) })
    let dataForKeyValuePairs: [[UInt8]] = [
      [0x61, 0x61, 0x61, 0x41],
      [0x61, 0x62, 0x61, 0x42],
      [0x61, 0x63, 0x61, 0x43],
      [0x61, 0x64, 0x61, 0x44],
      [0x61, 0x65, 0x61, 0x45],
    ]
    XCTAssertEqual(dataMinusFirstByte, dataForKeyValuePairs)

    let oneTwoThreeFour = try encode([1: 2, 3: 4])
    XCTAssert(
      oneTwoThreeFour == [0xA2, 0x61, 0x31, 0x02, 0x61, 0x33, 0x04] || oneTwoThreeFour ==
        [0xA2, 0x61, 0x33, 0x04, 0x61, 0x31, 0x02]
    )
  }

  func testEncodingDoesntTranslateMapKeys() throws {
    let encoder = CBOREncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    let tree = try encoder.encodeTree(["thisIsAnExampleKey": 0])
    XCTAssertEqual(tree.mapValue?.keys.first, "thisIsAnExampleKey")
  }

  func testEncodeDates() throws {
    let dateOne = Date(timeIntervalSince1970: 1_363_896_240)
    let dateTwo = Date(timeIntervalSince1970: 1_363_896_240.5)

    // numeric  dates
    let encoder = CBOREncoder()
    encoder.dateEncodingStrategy = .millisecondsSince1970
    XCTAssertEqual(try Array(encoder.encode(dateOne)), [0xC1, 0x1B, 0x00, 0x00, 0x01, 0x3D, 0x8E, 0x8D, 0x07, 0x80])
    XCTAssertEqual(try Array(encoder.encode(dateTwo)), [0xC1, 0x1B, 0x00, 0x00, 0x01, 0x3D, 0x8E, 0x8D, 0x09, 0x74])

    // numeric fractional dates
    encoder.dateEncodingStrategy = .secondsSince1970
    XCTAssertEqual(try Array(encoder.encode(dateOne)), [0xC1, 0xFB, 0x41, 0xD4, 0x52, 0xD9, 0xEC, 0x00, 0x00, 0x00])
    XCTAssertEqual(try Array(encoder.encode(dateTwo)), [0xC1, 0xFB, 0x41, 0xD4, 0x52, 0xD9, 0xEC, 0x20, 0x00, 0x00])

    // string dates (no fractional seconds)
    encoder.dateEncodingStrategy = .iso8601
    XCTAssertEqual(
      try Array(encoder.encode(dateOne)),
      [
        0xC0,
        0x78,
        0x18,
        0x32,
        0x30,
        0x31,
        0x33,
        0x2D,
        0x30,
        0x33,
        0x2D,
        0x32,
        0x31,
        0x54,
        0x32,
        0x30,
        0x3A,
        0x30,
        0x34,
        0x3A,
        0x30,
        0x30,
        0x2E,
        0x30,
        0x30,
        0x30,
        0x5A,
      ]
    )
    XCTAssertEqual(
      try Array(encoder.encode(dateTwo)),
      [
        0xC0,
        0x78,
        0x18,
        0x32,
        0x30,
        0x31,
        0x33,
        0x2D,
        0x30,
        0x33,
        0x2D,
        0x32,
        0x31,
        0x54,
        0x32,
        0x30,
        0x3A,
        0x30,
        0x34,
        0x3A,
        0x30,
        0x30,
        0x2E,
        0x35,
        0x30,
        0x30,
        0x5A,
      ]
    )
  }

  func testEncodeSimpleStructs() throws {
    struct MyStruct: Codable {
      let age: Int
      let name: String
    }

    let encoded = try encode(MyStruct(age: 27, name: "Ham"))

    XCTAssert(
      encoded == [0xA2, 0x63, 0x61, 0x67, 0x65, 0x18, 0x1B, 0x64, 0x6E, 0x61, 0x6D, 0x65, 0x63, 0x48, 0x61, 0x6D]
        || encoded == [0xA2, 0x64, 0x6E, 0x61, 0x6D, 0x65, 0x63, 0x48, 0x61, 0x6D, 0x63, 0x61, 0x67, 0x65, 0x18, 0x1B]
    )
  }
}

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
