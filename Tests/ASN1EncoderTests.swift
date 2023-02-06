//
//  ASN1EncoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables
import PotentASN1
import XCTest


class ASN1EncoderTests: XCTestCase {

  func testEncodeNull() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .null).encode(nil as String?),
      Data([ASN1.Tag.null.rawValue, 0])
    )
  }

  func testEncodeBool() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .boolean()).encode(true),
      Data([ASN1.Tag.boolean.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .boolean()).encode(false),
      Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00])
    )
  }

  func testEncodeInt() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(1),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(-1),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
  }

  func testEncodeInt8() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int8(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int8(-1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int8.max),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int8.min),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x80])
    )
  }

  func testEncodeInt16() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int16(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int16(-1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int16.max),
      Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int16.min),
      Data([ASN1.Tag.integer.rawValue, 0x02, 0x80, 0x00])
    )
  }

  func testEncodeInt32() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int32(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int32(-1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int32.max),
      Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int32.min),
      Data([ASN1.Tag.integer.rawValue, 0x04, 0x80, 0x00, 0x00, 0x00])
    )
  }

  func testEncodeInt64() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int64(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int64(-1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int64.max),
      Data([ASN1.Tag.integer.rawValue, 0x08, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(Int64.min),
      Data([ASN1.Tag.integer.rawValue, 0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    )
  }

  func testEncodeUInt() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
  }

  func testEncodeUInt8() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt8(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt8.max),
      Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0xff])
    )
  }

  func testEncodeUInt16() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt16(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt16.max),
      Data([ASN1.Tag.integer.rawValue, 0x03, 0x00, 0xff, 0xff])
    )
  }

  func testEncodeUInt32() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt32(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt32.max),
      Data([ASN1.Tag.integer.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])
    )
  }

  func testEncodeUInt64() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt64(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(UInt64.max),
      Data([ASN1.Tag.integer.rawValue, 0x09, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    )
  }

  func testEncodeBigInt() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(-1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(Int8.max)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(Int8.min)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x80])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(Int64.max)),
      Data([ASN1.Tag.integer.rawValue, 0x08, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(ASN1.Integer(Int64.min)),
      Data([ASN1.Tag.integer.rawValue, 0x08, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    )
  }

  func testEncodeBigUInt() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(BigUInt(1)),
      Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(BigUInt(UInt8.max)),
      Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0xff])
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .integer()).encode(BigUInt(UInt64.max)),
      Data([ASN1.Tag.integer.rawValue, 0x09, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
    )
  }

  func testEncodeFloat() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .real).encode(Float(1.5)).hexEncodedString(),
      Data([ASN1.Tag.real.rawValue, 0x04, 0x00, 0x31, 0x2E, 0x35]).hexEncodedString()
    )
  }

  func testEncodeDouble() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .real).encode(Double(1.23)).hexEncodedString(),
      Data([ASN1.Tag.real.rawValue, 0x05, 0x00, 0x31, 0x2E, 0x32, 0x33]).hexEncodedString()
    )
  }

  func testEncodeDecimal() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .real).encode(Decimal(sign: .plus, exponent: -2, significand: 123)),
      Data([ASN1.Tag.real.rawValue, 0x05, 0x00, 0x31, 0x2E, 0x32, 0x33])
    )
  }

  func testEncodeStrings() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .utf8)).encode("test"),
      Data([ASN1.Tag.utf8String.rawValue, 0x4, 0x74, 0x65, 0x73, 0x74])
    )
  }

  func testEncodeUUID() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .utf8)).encode(UUID(uuidString: "353568D8-B232-4A00-BD76-338B8B3C7FB7")),
      Data([ASN1.Tag.utf8String.rawValue, 0x24,
            0x33, 0x35, 0x33, 0x35, 0x36, 0x38, 0x44, 0x38, 0x2D, 0x42, 0x32, 0x33,
            0x32, 0x2D, 0x34, 0x41, 0x30, 0x30, 0x2D, 0x42, 0x44, 0x37, 0x36, 0x2D,
            0x33, 0x33, 0x38, 0x42, 0x38, 0x42, 0x33, 0x43, 0x37, 0x46, 0x42, 0x37])
    )
  }

  func testEncodeURL() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .utf8)).encode(URL(string: "https://example.com/some/thing")),
      Data([ASN1.Tag.utf8String.rawValue, 0x1E,
            0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x65, 0x78, 0x61, 0x6D,
            0x70, 0x6C, 0x65, 0x2E, 0x63, 0x6F, 0x6D, 0x2F, 0x73, 0x6F, 0x6D, 0x65,
            0x2F, 0x74, 0x68, 0x69, 0x6E, 0x67])
    )
  }

  func testEncodeData() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Data(hexEncoded: "4CFD3C5A6D1B4B528476DA6EEF38C253")),
      Data([ASN1.Tag.octetString.rawValue, 0x10,
            0x4C, 0xFD, 0x3C, 0x5A, 0x6D, 0x1B, 0x4B, 0x52,
            0x84, 0x76, 0xDA, 0x6E, 0xEF, 0x38, 0xC2, 0x53])
    )
  }

  func testEncodeGeneralizedDate() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .time(kind: .generalized))
        .encode(ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")!.utcDate),
      Data([ASN1.Tag.generalizedTime.rawValue, 0x13,
            0x32, 0x30, 0x32, 0x32, 0x31, 0x32, 0x31, 0x31,
            0x31, 0x30, 0x30, 0x39, 0x30, 0x38, 0x2E, 0x30, 0x30, 0x30, 0x5A])
    )
  }

  func testEncodeUTCDate() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .time(kind: .utc))
        .encode(ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")!.utcDate),
      Data([ASN1.Tag.utcTime.rawValue, 0x0d,
            0x32, 0x32, 0x31, 0x32, 0x31, 0x31, 0x31, 0x30, 0x30, 0x39, 0x30, 0x38, 0x5A])
    )
  }

  func testEncodeAnyString() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .utf8)).encode(AnyString("Hello World", kind: .utf8)),
      Data([ASN1.Tag.utf8String.rawValue, 0x0b, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64])
    )
  }

  func testEncodeAnyTime() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .time(kind: .utc))
        .encode(AnyTime(ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")!, kind: .utc)),
      Data([ASN1.Tag.utcTime.rawValue, 0x0d,
            0x32, 0x32, 0x31, 0x32, 0x31, 0x31, 0x31, 0x30, 0x30, 0x39, 0x30, 0x38, 0x5A])
    )
  }

  func testEncodeBitString() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(BitString(octets: [0xfe, 0xff, 0xff, 0x7f])),
      Data([ASN1.Tag.bitString.rawValue, 0x05, 0x01, 0x7f, 0xff, 0xff, 0xfe])
    )
  }

  func testEncodeObjectIdentifier() {
    XCTAssertEqual(
      try ASN1Encoder(schema: .objectIdentifier()).encode(ObjectIdentifier([1, 2, 3, 4])),
      Data([ASN1.Tag.objectIdentifier.rawValue, 0x03, 0x2A, 0x03, 0x04])
    )
  }

  func testEncodeTagged() {

    struct TaggedInt: Equatable, Codable, Tagged {
      var tag: ASN1.AnyTag = 0x35
      var int: BigInt

      init?(tag: ASN1.AnyTag, value: Any?) {
        guard let int = value as? BigInt else {
          return nil
        }
        self.int = int
      }

      var value: Any? { int }

      func encode(schema: Schema) throws -> ASN1 {
        return .tagged(0x35, try ASN1Encoder(schema: .integer()).encode(int))
      }

    }

    XCTAssertEqual(
      try ASN1Encoder(schema: .implicit(0x35, .integer())).encode(TaggedInt(tag: 0x35, value: BigInt(1))),
      Data([ASN1.Tag.tag(from: 0x35, in: .contextSpecific, constructed: false),
            0x03, ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
  }

}
