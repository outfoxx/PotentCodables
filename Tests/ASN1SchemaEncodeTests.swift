//
//  ASN1SchemaEncodeTests.swift
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


class ASN1SchemaEncodeTests: XCTestCase {

  func testEncodeStructureWithDynamic() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int
      var b: ASN1?

      static var asn1Schema: Schema = .sequence([
        "a": .type(.integer()),
        "b": .dynamic(unknownTypeSchema: .nothing, [
          .integer(1): .integer(),
          .integer(2): .boolean(),
        ]),
      ])
    }

    XCTAssertEqual(
      try ASN1Encoder.encode(TestValue(a: 1, b: .integer(123))),
      Data(hexEncoded: "300602010102017b")
    )

    XCTAssertEqual(
      try ASN1Encoder.encode(TestValue(a: 2, b: .boolean(true))),
      Data(hexEncoded: "30060201020101ff")
    )

    XCTAssertEqual(
      try ASN1Encoder.encode(TestValue(a: 3, b: nil)),
      Data(hexEncoded: "3003020103")
    )
  }

  func testEncodeStructureWithDynamicToNothing() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int
      var b: ASN1?

      static var asn1Schema: Schema = .sequence([
        "a": .type(.integer()),
        "b": .dynamic([
          .integer(1): .integer(),
          .integer(2): .nothing,
        ]),
      ])
    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3003020102"))

    XCTAssertEqual(testValue.a, 2)
    XCTAssertEqual(testValue.b, nil)
  }

  func testEncodeStructureWithDynamicNoTypeDefinedFails() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int
      var b: ASN1?

      static var asn1Schema: Schema = .sequence([
        "a": .integer(),
        "b": .dynamic(unknownTypeSchema: .nothing, [
          .integer(1): .integer(),
          .integer(2): .boolean(),
        ]),
      ])
    }

    XCTAssertThrowsError(try TestValue(a: 1).encoded()) { error in
      AssertNoDynamicTypeDefined(error)
    }
  }

  func testEncodeStructureWithUnkownDynamicValue() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int
      var b: ASN1?

      static var asn1Schema: Schema = .sequence([
        "a": .type(.integer()),
        "b": .dynamic([
          .integer(1): .integer(),
          .integer(2): .boolean(),
        ]),
      ])
    }

    XCTAssertThrowsError(try TestValue(a: 5).encoded()) { error in
      AssertUnknownDynamicValue(error)
    }
  }

  func testEncodeStructure() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: true, b: 123).encoded(),
      Data(hexEncoded: "30060101ff02017b")
    )
  }

  func testEncodeStructureWithDefault() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(default: false),
        "b": .integer(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: false, b: 123).encoded(),
      Data(hexEncoded: "300302017b")
    )
  }

  func testEncodeStructureWithDefaultReversed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(default: ASN1.Integer(1)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: true, b: 1).encoded(),
      Data(hexEncoded: "30030101ff")
    )
  }

  func testEncodeStructureWithDefaultedMissingValue() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(default: 123),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: true).encoded(),
      Data(hexEncoded: "30030101ff")
    )
  }

  func testEncodeStructureOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer()),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300b3009020101020102020103")
    )
  }

  func testEncodeStructureOfWithMaxAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .max(3)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300b3009020101020102020103")
    )
  }

  func testEncodeStructureOfWithMaxNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .max(2)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: [1, 2, 3]).encoded()
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testEncodeSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer()),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300b3109020101020102020103")
    )
  }

  func testEncodeSetOfWithMaxAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .max(3)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300b3109020101020102020103")
    )
  }

  func testEncodeSetOfWithMaxNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .max(2)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: [1, 2, 3]).encoded()
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testEncodeObjectIdentifier() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3, 4]).encoded(),
      Data(hexEncoded: "300506032a0304")
    )
  }

  func testEncodeObjectIdentifierWithAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(allowed: [ObjectIdentifier([1, 2, 3, 4])]),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3, 4]).encoded(),
      Data(hexEncoded: "300506032a0304")
    )
  }

  func testEncodeObjectIdentifierWithAllowedInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(allowed: [ObjectIdentifier([2, 3, 4])]),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: [1, 2, 3, 4]).encoded()
    ) { error in
      AssertDisallowedValue(error)
    }
  }

  func testEncodeBitString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: BitString

      static var asn1Schema: Schema = .sequence([
        "a": .bitString(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: BitString(octets: [1, 2])).encoded(),
      Data(hexEncoded: "30050303068040")
    )

    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(Data([0x7f, 0xfe])),
      Data(hexEncoded: "0303007ffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(Int8(bitPattern: 0xfe)),
      Data(hexEncoded: "0302007f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(Int16(bitPattern: 0xfe7f)),
      Data(hexEncoded: "030300fe7f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(Int32(bitPattern: 0xfeffff7f)),
      Data(hexEncoded: "030500feffff7f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(Int64(bitPattern: 0xfeffffffffffff7f)),
      Data(hexEncoded: "030900feffffffffffff7f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(UInt8(0xfe)),
      Data(hexEncoded: "0302007f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(UInt16(0xfe7f)),
      Data(hexEncoded: "030300fe7f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(UInt32(0xfeffff7f)),
      Data(hexEncoded: "030500feffff7f")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .bitString()).encode(UInt64(0xfeffffffffffff7f)),
      Data(hexEncoded: "030900feffffffffffff7f")
    )
  }

  func testEncodeBitStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: BitString

      static var asn1Schema: Schema = .sequence([
        "a": .bitString(size: .min(17)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: BitString(octets: [1, 2])).encoded()
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testEncodeOctetString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: Data([1, 2])).encoded(),
      Data(hexEncoded: "300404020102")
    )

    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Data([0x7f, 0xfe])),
      Data(hexEncoded: "04027ffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Int8(bitPattern: 0xfe)),
      Data(hexEncoded: "0401fe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Int16(bitPattern: 0xfe7f)),
      Data(hexEncoded: "04027ffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Int32(bitPattern: 0xfeffff7f)),
      Data(hexEncoded: "04047ffffffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(Int64(bitPattern: 0xfeffffffffffff7f)),
      Data(hexEncoded: "04087ffffffffffffffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(UInt8(0xfe)),
      Data(hexEncoded: "0401fe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(UInt16(0xfe7f)),
      Data(hexEncoded: "04027ffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(UInt32(0xfeffff7f)),
      Data(hexEncoded: "04047ffffffe")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .octetString()).encode(UInt64(0xfeffffffffffff7f)),
      Data(hexEncoded: "04087ffffffffffffffe")
    )
  }

  func testEncodeOctetStringWithSize() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(size: .range(1, 2)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: Data([1, 2])).encoded(),
      Data(hexEncoded: "300404020102")
    )
  }

  func testEncodeOctetStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(size: .min(5)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: Data([1, 2])).encoded()
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testEncodeInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: 123).encoded(),
      Data(hexEncoded: "300302017b")
    )
  }

  func testEncodeIntegerWithAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(allowed: ASN1.Integer(123) ..< ASN1.Integer(124)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: 123).encoded(),
      Data(hexEncoded: "300302017b")
    )
  }

  func testEncodeIntegerWithAllowedInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(allowed: ASN1.Integer(0) ..< ASN1.Integer(10)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: 123).encoded()
    ) { error in
      AssertDisallowedValue(error)
    }
  }

  func testEncodeGeneralizedTime() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .generalized),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: Date(timeIntervalSince1970: 1675364376.709)).encoded(),
      Data(hexEncoded: "3015181332303233303230323138353933362e3730395a")
    )
  }

  func testEncodeUTCTime() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .utc),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: Date(timeIntervalSince1970: 1675365671.0)).encoded(),
      Data(hexEncoded: "300f170d3233303230323139323131315a")
    )
  }

  func testEncodeZonedTime() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .time(kind: .utc))
        .encode(ZonedDate(date: Date(timeIntervalSince1970: 1675365671.0), timeZone: .utc)),
      Data(hexEncoded: "170d3233303230323139323131315a")
    )
  }

  func testEncodeAnyTime() throws {

    XCTAssertEqual(
      try ASN1Encoder(schema: .time(kind: .utc))
        .encode(AnyTime(ZonedDate(date: Date(timeIntervalSince1970: 1675365671.0), timeZone: .utc), kind: .utc)),
      Data(hexEncoded: "170d3233303230323139323131315a")
    )
  }

  func testEncodeString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: "Hello World").encoded(),
      Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64")
    )

    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .numeric)).encode("123"),
      Data(hexEncoded: "1203313233")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .printable)).encode("test"),
      Data(hexEncoded: "130474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .teletex)).encode("test"),
      Data(hexEncoded: "140474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .videotex)).encode("test"),
      Data(hexEncoded: "150474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .ia5)).encode("test"),
      Data(hexEncoded: "160474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .graphic)).encode("test"),
      Data(hexEncoded: "190474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .visible)).encode("test"),
      Data(hexEncoded: "1a0474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .general)).encode("test"),
      Data(hexEncoded: "1b0474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .universal)).encode("test"),
      Data(hexEncoded: "1c0474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .character)).encode("test"),
      Data(hexEncoded: "1d0474657374")
    )
    XCTAssertEqual(
      try ASN1Encoder(schema: .string(kind: .bmp)).encode("test"),
      Data(hexEncoded: "1e0474657374")
    )
  }

  func testEncodeStringWithSize() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8, size: .min(3)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: "Hello World").encoded(),
      Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64")
    )
  }

  func testEncodeStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8, size: .max(3)),
      ])

    }

    XCTAssertThrowsError(
      try TestValue(a: "Hello World").encoded()
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testEncodeImplictTaggedInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .integer()),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: 123).encoded(),
      Data(hexEncoded: "300381017b")
    )
  }

  func testEncodeImplictTaggedSequenceOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .sequenceOf(.integer())),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300ba109020101020102020103")
    )
  }

  func testEncodeImplictTaggedSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .sequenceOf(.integer())),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300ba109020101020102020103")
    )
  }

  func testEncodeExplictTaggedInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .integer()),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: 123).encoded(),
      Data(hexEncoded: "3005a10302017b")
    )
  }

  func testEncodeExplictTaggedSequenceOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .sequenceOf(.integer())),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300da10b3009020101020102020103")
    )
  }

  func testEncodeExplictTaggedSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .setOf(.integer())),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: [1, 2, 3]).encoded(),
      Data(hexEncoded: "300da10b3109020101020102020103")
    )
  }

  func testEncodeChoiceWithLotsOfOptions() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .choiceOf([
          .sequenceOf(.integer()),
          .setOf(.integer()),
          .null,
          .objectIdentifier(),
          .boolean(),
          .bitString(),
          .octetString(),
          .boolean(),
          .integer(),
          .time(kind: .utc),
          .real,
          .implicit(1, .integer()),
          .explicit(2, .integer()),
          .string(kind: .utf8),
        ])
      ])

    }

    XCTAssertEqual(
      try TestValue(a: "abc").encoded(),
      Data(hexEncoded: "30050c03616263")
    )
  }

  func testEncodeChoiceWithLotsOfOptions2() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool

      static var asn1Schema: Schema = .sequence([
        "a": .choiceOf([
          .sequence([:]),
          .sequenceOf(.integer()),
          .setOf(.integer()),
          .null,
          .objectIdentifier(),
          .bitString(),
          .octetString(),
          .integer(),
          .time(kind: .utc),
          .string(kind: .utf8),
          .real,
          .implicit(1, .integer()),
          .explicit(2, .integer()),
          .boolean(),
        ])
      ])

    }

    XCTAssertEqual(
      try TestValue(a: true).encoded(),
      Data(hexEncoded: "30030101ff")
    )
  }

  func testEncodeChoiceWithStringKinds() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: AnyString

      static var asn1Schema: Schema = .sequence([
        "a": .choiceOf([
          .string(kind: .utf8),
          .string(kind: .printable),
        ])
      ])

    }

    XCTAssertEqual(
      try TestValue(a: AnyString("abc", kind: .printable)).encoded(),
      Data(hexEncoded: "30051303616263")
    )
  }

  func testEncodeChoiceWithTimeKinds() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: AnyTime

      static var asn1Schema: Schema = .sequence([
        "a": .choiceOf([
          .time(kind: .utc),
          .time(kind: .generalized),
        ])
      ])

    }

    XCTAssertEqual(
      try TestValue(a: AnyTime(ZonedDate(date: Date(timeIntervalSince1970: 1675364376.709),
                                         timeZone: .utc), kind: .generalized)).encoded(),
      Data(hexEncoded: "3015181332303233303230323138353933362e3730395a")
    )
  }

  func testEncodeImplicitChoices() throws {

    struct TaggedInt: Equatable, Codable, Tagged {
      var tag: ASN1.AnyTag
      var int: BigInt

      init?(tag: ASN1.AnyTag, value: Any?) {
        guard let int = value as? BigInt else {
          return nil
        }
        self.tag = tag
        self.int = int
      }

      var value: Any? { int }

      func encode(schema: Schema) throws -> ASN1 {
        return .tagged(tag, try ASN1Encoder(schema: .integer()).encode(int))
      }

    }

    let schema: Schema =
      .choiceOf([
        .implicit(1, .integer()),
        .implicit(2, .integer()),
      ])

    XCTAssertEqual(
      try ASN1Encoder(schema: schema).encode(TaggedInt(tag: 2, value: BigInt(1))),
      Data([ASN1.Tag.tag(from: 2, in: .contextSpecific, constructed: false),
            0x03, ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
  }

  func testEncodeExplicitChoices() throws {

    struct TaggedInt: Equatable, Codable, Tagged {
      var tag: ASN1.AnyTag
      var int: BigInt

      init?(tag: ASN1.AnyTag, value: Any?) {
        guard let int = value as? BigInt else {
          return nil
        }
        self.tag = tag
        self.int = int
      }

      var value: Any? { int }

      func encode(schema: Schema) throws -> ASN1 {
        return .integer(int)
      }

    }

    let schema: Schema =
      .choiceOf([
        .explicit(1, .integer()),
        .explicit(2, .integer()),
      ])

    XCTAssertEqual(
      try ASN1Encoder(schema: schema).encode(TaggedInt(tag: 2, value: BigInt(1))),
      Data([ASN1.Tag.tag(from: 2, in: .contextSpecific, constructed: true), 0x03,
            ASN1.Tag.integer.rawValue, 0x01, 0x01])
    )
  }

  func testEncodeAny() {

    XCTAssertEqual(
      try ASN1Encoder(schema: .any).encode(ASN1.boolean(true)),
      Data(hexEncoded: "0101ff")
    )
  }

  func testEncodeVersioned() throws {

    struct TestValue: Codable, SchemaSpecified {
      var ver: Int
      var name1: String?
      var name2: String?

      static var asn1Schema: Schema = .sequence([
        "ver": .version(.integer(allowed: 1..<3)),
        "name1": .versioned(range: 1...1, .string(kind: .utf8)),
        "name2": .versioned(range: 2...2, .string(kind: .printable)),
      ])
    }

    XCTAssertEqual(
      try TestValue(ver: 1, name1: "test").encoded(),
      Data(hexEncoded: "30090201010c0474657374")
    )

    XCTAssertEqual(
      try TestValue(ver: 2, name2: "test").encoded(),
      Data(hexEncoded: "3009020102130474657374")
    )
  }

  func testEncodeTaggedVersioned() throws {

    struct TestValue: Codable, SchemaSpecified {
      var ver: Int
      var name1: String?
      var name2: String?

      static var asn1Schema: Schema = .sequence([
        "ver": .version(.implicit(1, .integer(allowed: 1..<3))),
        "name1": .versioned(range: 1...1, .string(kind: .utf8)),
        "name2": .versioned(range: 2...2, .string(kind: .printable)),
      ])
    }

    XCTAssertEqual(
      try TestValue(ver: 1, name1: "test").encoded(),
      Data(hexEncoded: "30098101010c0474657374")
    )

    XCTAssertEqual(
      try TestValue(ver: 2, name2: "test").encoded(),
      Data(hexEncoded: "3009810102130474657374")
    )
  }

  func testEncodeTaggedVersionedDefault() throws {

    struct TestValue: Codable, SchemaSpecified {
      var ver: Int
      var name1: String?
      var name2: String?

      static var asn1Schema: Schema = .sequence([
        "ver": .version(.implicit(1, .integer(allowed: 1..<3, default: 1))),
        "name1": .versioned(range: 1...1, .string(kind: .utf8)),
        "name2": .versioned(range: 2...2, .string(kind: .printable)),
      ])
    }

    XCTAssertEqual(
      try TestValue(ver: 1, name1: "test").encoded(),
      Data(hexEncoded: "30060c0474657374")
    )
  }

  func testEncodeOptional() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String?

      static var asn1Schema: Schema = .sequence([
        "a": .optional(.string(kind: .utf8)),
      ])

    }

    XCTAssertEqual(
      try TestValue(a: "Hello World").encoded(),
      Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64")
    )

    XCTAssertEqual(
      try TestValue(a: nil).encoded().hexEncodedString(),
      Data(hexEncoded: "3000").hexEncodedString()
    )
  }

}


private func AssertBadValue(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.EncodingError.badValue = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}


private func AssertValueOutOfRange(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.EncodingError.valueOutOfRange = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

private func AssertDisallowedValue(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.EncodingError.disallowedValue = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

private func AssertNoDynamicTypeDefined(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.SchemaError.noDynamicTypeDefined = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

private func AssertUnknownDynamicValue(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.SchemaError.unknownDynamicValue = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}
