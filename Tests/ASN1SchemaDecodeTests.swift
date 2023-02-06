//
//  ASN1SchemaDecodeTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables
import PotentASN1
import XCTest


class ASN1SchemaDecodeTests: XCTestCase {

  func testDecodeStructureWithDynamic() throws {

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

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300602010102017b"))

    XCTAssertEqual(testValue.a, 1)
    XCTAssertEqual(testValue.b, .integer(123))

    let testValue2 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30060201020101ff"))

    XCTAssertEqual(testValue2.a, 2)
    XCTAssertEqual(testValue2.b, .boolean(true))

    let testValue3 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3003020103"))

    XCTAssertEqual(testValue3.a, 3)
    XCTAssertNil(testValue3.b)
  }

  func testDecodeStructure() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30060101ff02017b"))

    XCTAssertEqual(testValue.a, true)
    XCTAssertEqual(testValue.b, 123)
  }

  func testDecodeStructureWhenFieldMissingWithDefault() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(default: false),
        "b": .integer(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300302017b"))

    XCTAssertEqual(testValue.a, false)
    XCTAssertEqual(testValue.b, 123)
  }

  func testDecodeStructureWhenFieldMissingWithDefaultReversed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(default: ASN1.Integer(1)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30030101ff"))

    XCTAssertEqual(testValue.a, true)
    XCTAssertEqual(testValue.b, 1)
  }

  func testDecodeStructureFailsWhenFieldMissingWithNoDefault() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Bool
      var b: Int

      static var asn1Schema: Schema = .sequence([
        "a": .boolean(),
        "b": .integer(),
      ])

    }

    XCTAssertThrowsError(try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300302017b"))) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testDecodeStructureOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer()),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeStructureOfWithMaxAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .max(3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeStructureOfWithMaxNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .max(2)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeStructureOfWithMinAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .min(2)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeStructureOfWithMinNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .min(4)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeStructureOfWithRangeAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .range(1, 3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeStructureOfWithRangeNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .range(4, 5)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeStructureOfWithExactAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .is(3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeStructureOfWithExactNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .sequenceOf(.integer(), size: .is(4)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3009020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer()),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeSetOfWithMaxAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .max(3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeSetOfWithMaxNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .max(2)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeSetOfWithMinAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .min(2)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeSetOfWithMinNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .min(4)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeSetOfWithRangeAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .range(1, 3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeSetOfWithRangeNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .range(4, 5)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeSetOfWithExactAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .is(3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeSetOfWithExactNotAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .setOf(.integer(), size: .is(4)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300b3109020101020102020103"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeObjectIdentifier() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300506032a0304"))

    XCTAssertEqual(testValue.a, [1, 2, 3, 4])
  }

  func testDecodeObjectIdentifierWithAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(allowed: [ObjectIdentifier([1, 2, 3, 4])]),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300506032a0304"))

    XCTAssertEqual(testValue.a, [1, 2, 3, 4])
  }

  func testDecodeObjectIdentifierWithAllowedInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: ObjectIdentifier

      static var asn1Schema: Schema = .sequence([
        "a": .objectIdentifier(allowed: [ObjectIdentifier([2, 3, 4])]),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300506032a0304"))
    ) { error in
      AssertDisallowedValue(error)
    }
  }

  func testDecodeBitString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: BitString

      static var asn1Schema: Schema = .sequence([
        "a": .bitString(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30050303068040"))

    XCTAssertEqual(testValue.a, BitString(octets: [1, 2]))
  }

  func testDecodeBitStringWithSize() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: BitString

      static var asn1Schema: Schema = .sequence([
        "a": .bitString(size: .range(1, 15)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30050303068040"))

    XCTAssertEqual(testValue.a, BitString(octets: [1, 2]))
  }

  func testDecodeBitStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: BitString

      static var asn1Schema: Schema = .sequence([
        "a": .bitString(size: .min(17)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30050303068040"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeOctetString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300404020102"))

    XCTAssertEqual(testValue.a, Data([1, 2]))
  }

  func testDecodeOctetStringWithSize() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(size: .range(1, 2)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300404020102"))

    XCTAssertEqual(testValue.a, Data([1, 2]))
  }

  func testDecodeOctetStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Data

      static var asn1Schema: Schema = .sequence([
        "a": .octetString(size: .min(5)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300404020102"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300302017b"))

    XCTAssertEqual(testValue.a, 123)
  }

  func testDecodeIntegerWithAllowed() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(allowed: ASN1.Integer(123) ..< ASN1.Integer(124)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300302017b"))

    XCTAssertEqual(testValue.a, 123)
  }

  func testDecodeIntegerWithAllowedInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .integer(allowed: ASN1.Integer(0) ..< ASN1.Integer(10)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300302017b"))
    ) { error in
      AssertDisallowedValue(error)
    }
  }

  func testDecodeGeneralizedTime() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .generalized),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self,
                                           from: Data(hexEncoded: "3015181332303233303230323138353933362e3730395a"))

    XCTAssertEqual(testValue.a, Date(timeIntervalSince1970: 1675364376.709))
  }

  func testDecodeGeneralizedTimeWrongKind() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .utc),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3015181332303233303230323138353933362e3730395a"))
    ) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testDecodeUTCTime() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .utc),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self,
                                           from: Data(hexEncoded: "300f170d3233303230323139323131315a"))

    XCTAssertEqual(testValue.a, Date(timeIntervalSince1970: 1675365671.0))
  }

  func testDecodeUTCTimeWrongKind() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Date

      static var asn1Schema: Schema = .sequence([
        "a": .time(kind: .generalized),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300f170d3233303230323139323131315a"))
    ) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testDecodeString() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self,
                                           from: Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64"))

    XCTAssertEqual(testValue.a, "Hello World")
  }

  func testDecodeStringWrongKind() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .printable),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64"))
    ) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testDecodeStringWithSize() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8, size: .min(3)),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self,
                                           from: Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64"))

    XCTAssertEqual(testValue.a, "Hello World")
  }

  func testDecodeStringWithSizeInvalid() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: String

      static var asn1Schema: Schema = .sequence([
        "a": .string(kind: .utf8, size: .max(3)),
      ])

    }

    XCTAssertThrowsError(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64"))
    ) { error in
      AssertValueOutOfRange(error)
    }
  }

  func testDecodeImplictTaggedInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .integer()),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300381017b"))

    XCTAssertEqual(testValue.a, 123)
  }

  func testDecodeImplictTaggedSequenceOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .sequenceOf(.integer())),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300ba109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeImplictTaggedSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .implicit(1, .setOf(.integer())),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300ba109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeExplictTaggedInteger() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: Int

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .integer()),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3005a10302017b"))

    XCTAssertEqual(testValue.a, 123)
  }

  func testDecodeExplictTaggedSequenceOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .sequenceOf(.integer())),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300da10b3009020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeExplictTaggedSetOf() throws {

    struct TestValue: Codable, SchemaSpecified {
      var a: [Int]

      static var asn1Schema: Schema = .sequence([
        "a": .explicit(1, .setOf(.integer())),
      ])

    }

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300da10b3109020101020102020103"))

    XCTAssertEqual(testValue.a, [1, 2, 3])
  }

  func testDecodeChoiceWithLotsOfOptions() throws {

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

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30050c03616263"))

    XCTAssertEqual(testValue.a, "abc")
  }

  func testDecodeChoiceWithLotsOfOptions2() throws {

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

    let testValue = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30030101ff"))

    XCTAssertEqual(testValue.a, true)
  }

  func testDecodeImplicitAmbiguousSchemaThrowsError() throws {

    let schema: Schema = .implicit(1, .choiceOf([.boolean(), .integer()]))

    XCTAssertThrowsError(
      try ASN1Decoder(schema: schema).decode(Bool.self, from: Data(hexEncoded: "8101ff"))
    ) { error in
      AssertAmbiguousImplicitTag(error)
    }
  }

  func testDecodeExplicitAmbiguousSchema() throws {

    let schema: Schema = .explicit(1, .choiceOf([.boolean(), .integer()]))

    let testValue = try ASN1Decoder(schema: schema).decode(Bool.self, from: Data(hexEncoded: "a1030101ff"))

    XCTAssertEqual(testValue, true)
  }

  func testDecodeExplicitWithDefault() throws {

    let schema: Schema = .explicit(1, .boolean(default: true))

    let testValue = try ASN1Decoder(schema: schema).decode(Bool.self, from: Data(hexEncoded: "a100"))

    XCTAssertEqual(testValue, true)
  }

  func testDecodeExplicitWithInvalidData() throws {

    let schema: Schema = .explicit(1, .boolean())

    XCTAssertThrowsError(
      try ASN1Decoder(schema: schema).decode(Bool.self, from: Data(hexEncoded: "a100"))
    ) { error in
      AssertBadValue(error)
    }
  }

  func testDecodeAny() throws {

    let testValue = try ASN1Decoder(schema: .any).decode(Bool.self, from: Data(hexEncoded: "0101ff"))

    XCTAssertEqual(testValue, true)
  }

  func testDecodeVersioned() throws {

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

    let testValue1 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30090201010c0474657374"))

    XCTAssertEqual(testValue1.ver, 1)
    XCTAssertEqual(testValue1.name1, "test")
    XCTAssertNil(testValue1.name2)

    let testValue2 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3009020102130474657374"))

    XCTAssertEqual(testValue2.ver, 2)
    XCTAssertEqual(testValue2.name2, "test")
    XCTAssertNil(testValue2.name1)
  }

  func testDecodeTaggedVersioned() throws {

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

    let testValue1 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30098101010c0474657374"))

    XCTAssertEqual(testValue1.ver, 1)
    XCTAssertEqual(testValue1.name1, "test")
    XCTAssertNil(testValue1.name2)
  }

  func testDecodeTaggedVersionedDefault() throws {

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

    let testValue1 = try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "30060c0474657374"))

    XCTAssertEqual(testValue1.ver, 1)
    XCTAssertEqual(testValue1.name1, "test")
    XCTAssertNil(testValue1.name2)
  }

  func testDecodeVersionedWithNoVersion() throws {

    struct TestValue: Codable, SchemaSpecified {
      var ver: Int
      var name1: String?
      var name2: String?

      static var asn1Schema: Schema = .sequence([
        "ver": .integer(allowed: 1..<3),
        "name1": .versioned(range: 1...1, .string(kind: .utf8)),
        "name2": .versioned(range: 2...2, .string(kind: .printable)),
      ])
    }

    XCTAssertThrowsError(try TestValue(ver: 1).encoded()) { error in
      AssertNoVersionDefined(error)
    }
  }

  func testDecodeOptional() throws {

    struct TestValue: Codable, Equatable, SchemaSpecified {
      var a: String?

      static var asn1Schema: Schema = .sequence([
        "a": .optional(.string(kind: .utf8)),
      ])

    }

    XCTAssertEqual(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "300d0c0b48656c6c6f20576f726c64")),
      TestValue(a: "Hello World")
    )

    XCTAssertEqual(
      try ASN1Decoder.decode(TestValue.self, from: Data(hexEncoded: "3000")),
      TestValue(a: nil)
    )
  }

}


private func AssertAmbiguousImplicitTag(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.SchemaError.ambiguousImplicitTag = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

private func AssertBadValue(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.DecodingError.badValue = error {
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
    if case SchemaState.DecodingError.valueOutOfRange = error {
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
    if case SchemaState.DecodingError.disallowedValue = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}

private func AssertNoVersionDefined(_ error: Error, file: StaticString = #file, line: UInt = #line) {
  func check() -> Bool {
    if case SchemaState.SchemaError.noVersionDefined = error {
      return true
    }
    else {
      return false
    }
  }
  XCTAssertTrue(check(), file: file, line: line)
}
