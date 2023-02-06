//
//  ASN1SchemaTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentASN1
import XCTest


class ASN1SchemaTests: XCTestCase {

  func testPossibleTags() {
    XCTAssertEqual(Schema.sequenceOf(.integer()).possibleTags, [ASN1.Tag.sequence.universal])
    XCTAssertEqual(Schema.setOf(.integer()).possibleTags, [ASN1.Tag.set.universal])
    XCTAssertEqual(Schema.choiceOf([.integer(), .boolean()]).possibleTags, [ASN1.Tag.integer.universal,
                                                                            ASN1.Tag.boolean.universal])
    XCTAssertEqual(Schema.choiceOf([.nothing]).possibleTags, [])
    XCTAssertEqual(Schema.type(.integer()).possibleTags, [ASN1.Tag.integer.universal])
    XCTAssertEqual(Schema.version(.integer()).possibleTags, [ASN1.Tag.integer.universal])
    XCTAssertEqual(Schema.versioned(range: 1...3, .integer()).possibleTags, [ASN1.Tag.integer.universal])
    XCTAssertEqual(Schema.optional(.integer()).possibleTags, [ASN1.Tag.integer.universal])
    XCTAssertEqual(Schema.implicit(1, .integer()).possibleTags,
                   [ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: false)])
    XCTAssertEqual(Schema.implicit(1, .sequenceOf(.integer())).possibleTags,
                   [ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: true)])
    XCTAssertEqual(Schema.explicit(1, .integer()).possibleTags,
                   [ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: true)])
    XCTAssertEqual(Schema.explicit(1, .sequenceOf(.integer())).possibleTags,
                   [ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: true)])
    XCTAssertEqual(Schema.boolean().possibleTags, [ASN1.Tag.boolean.universal])
    XCTAssertEqual(Schema.integer().possibleTags, [ASN1.Tag.integer.universal])
    XCTAssertEqual(Schema.real.possibleTags, [ASN1.Tag.real.universal])
    XCTAssertEqual(Schema.bitString().possibleTags, [ASN1.Tag.bitString.universal])
    XCTAssertEqual(Schema.octetString().possibleTags, [ASN1.Tag.octetString.universal])
    XCTAssertEqual(Schema.objectIdentifier().possibleTags, [ASN1.Tag.objectIdentifier.universal])
    XCTAssertEqual(Schema.string(kind: .utf8).possibleTags, [ASN1.Tag.utf8String.universal])
    XCTAssertEqual(Schema.string(kind: .numeric).possibleTags, [ASN1.Tag.numericString.universal])
    XCTAssertEqual(Schema.string(kind: .printable).possibleTags, [ASN1.Tag.printableString.universal])
    XCTAssertEqual(Schema.string(kind: .teletex).possibleTags, [ASN1.Tag.teletexString.universal])
    XCTAssertEqual(Schema.string(kind: .videotex).possibleTags, [ASN1.Tag.videotexString.universal])
    XCTAssertEqual(Schema.string(kind: .ia5).possibleTags, [ASN1.Tag.ia5String.universal])
    XCTAssertEqual(Schema.string(kind: .graphic).possibleTags, [ASN1.Tag.graphicString.universal])
    XCTAssertEqual(Schema.string(kind: .visible).possibleTags, [ASN1.Tag.visibleString.universal])
    XCTAssertEqual(Schema.string(kind: .general).possibleTags, [ASN1.Tag.generalString.universal])
    XCTAssertEqual(Schema.string(kind: .universal).possibleTags, [ASN1.Tag.universalString.universal])
    XCTAssertEqual(Schema.string(kind: .character).possibleTags, [ASN1.Tag.characterString.universal])
    XCTAssertEqual(Schema.string(kind: .bmp).possibleTags, [ASN1.Tag.bmpString.universal])
    XCTAssertEqual(Schema.time(kind: .utc).possibleTags, [ASN1.Tag.utcTime.universal])
    XCTAssertEqual(Schema.time(kind: .generalized).possibleTags, [ASN1.Tag.generalizedTime.universal])
    XCTAssertEqual(Schema.null.possibleTags, [ASN1.Tag.null.universal])
    XCTAssertEqual(Schema.any.possibleTags, nil)
    XCTAssertEqual(Schema.dynamic([.integer(1): .integer()]).possibleTags, nil)
    XCTAssertEqual(Schema.nothing.possibleTags, nil)
  }

  func testDefaultValues() {
    XCTAssertEqual(Schema.type(.integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.version(.integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.versioned(range: 1...3, .integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.optional(.integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.implicit(1, .integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.explicit(2, .integer(default: 5)).defaultValue, .integer(5))
    XCTAssertEqual(Schema.boolean(default: false).defaultValue, .boolean(false))
    XCTAssertEqual(Schema.integer(default: 5).defaultValue, .integer(5))
    XCTAssertNil(Schema.string(kind: .utf8).defaultValue)
  }

  func testDefaultValueEncoded() {
    XCTAssertEqual(try Schema.integer(default: 5).defaultValueEncoded(), .default(.integer(5)))
  }

  func testUnwrapDirectives() {
    XCTAssertEqual(Schema.type(.integer()).unwrapDirectives, .integer())
    XCTAssertEqual(Schema.version(.integer()).unwrapDirectives, .integer())
    XCTAssertEqual(Schema.versioned(range: 1...3, .integer()).unwrapDirectives, .integer())
    XCTAssertEqual(Schema.integer().unwrapDirectives, .integer())
  }

  func testIsVersionedAccessor() {
    XCTAssertTrue(Schema.versioned(range: 1...3, .integer()).isVersioned)
    XCTAssertFalse(Schema.integer().isVersioned)
  }

  func testIsDynamicAccessor() {
    XCTAssertTrue(Schema.dynamic([.integer(1): .integer()]).isDynamic)
    XCTAssertFalse(Schema.integer().isDynamic)
  }

  func testIsOptionalAccessor() {
    XCTAssertTrue(Schema.type(.optional(.integer())).isOptional)
    XCTAssertTrue(Schema.version(.optional(.integer())).isOptional)
    XCTAssertTrue(Schema.versioned(range: 1...3, .optional(.integer())).isOptional)
    XCTAssertTrue(Schema.optional(.integer()).isOptional)
    XCTAssertTrue(Schema.implicit(1, .optional(.integer())).isOptional)
    XCTAssertTrue(Schema.explicit(1, .optional(.integer())).isOptional)
    XCTAssertFalse(Schema.integer().isOptional)
  }

  func testIsBooleanAccessor() {
    XCTAssertTrue(Schema.boolean().isBoolean)
    XCTAssertFalse(Schema.integer().isBoolean)
  }

  func testIsIntegerAccessor() {
    XCTAssertTrue(Schema.integer().isInteger)
    XCTAssertFalse(Schema.boolean().isInteger)
  }

  func testIsRealAccessor() {
    XCTAssertTrue(Schema.real.isReal)
    XCTAssertFalse(Schema.integer().isReal)
  }

  func testIsBitStringAccessor() {
    XCTAssertTrue(Schema.bitString().isBitString)
    XCTAssertFalse(Schema.integer().isBitString)
  }

  func testIsOctetStringAccessor() {
    XCTAssertTrue(Schema.octetString().isOctetString)
    XCTAssertFalse(Schema.integer().isOctetString)
  }

  func testIsObjectIdentifierAccessor() {
    XCTAssertTrue(Schema.objectIdentifier().isObjectIdentifier)
    XCTAssertFalse(Schema.integer().isObjectIdentifier)
  }

  func testIsStringAccessor() {
    XCTAssertTrue(Schema.string(kind: .utf8).isString)
    XCTAssertFalse(Schema.integer().isString)
  }

  func testIsTimeAccessor() {
    XCTAssertTrue(Schema.time(kind: .utc).isTime)
    XCTAssertFalse(Schema.integer().isTime)
  }

  func testIsNullAccessor() {
    XCTAssertTrue(Schema.null.isNull)
    XCTAssertFalse(Schema.integer().isNull)
  }

  func testIsSequenceAccessor() {
    XCTAssertTrue(Schema.sequence().isSequence)
    XCTAssertFalse(Schema.integer().isSequence)
  }

  func testIsSequenceOfAccessor() {
    XCTAssertTrue(Schema.sequenceOf(.integer()).isSequenceOf)
    XCTAssertFalse(Schema.integer().isSequenceOf)
  }

  func testIsSetOfAccessor() {
    XCTAssertTrue(Schema.setOf(.integer()).isSetOf)
    XCTAssertFalse(Schema.integer().isSetOf)
  }

  func testIsCollectionAccessor() {
    XCTAssertTrue(Schema.sequence().isCollection)
    XCTAssertTrue(Schema.sequenceOf(.integer()).isCollection)
    XCTAssertTrue(Schema.setOf(.integer()).isCollection)
    XCTAssertFalse(Schema.integer().isCollection)
  }

  func testDescription() {

    XCTAssertEqual(
      Schema.sequence(["a": .integer(), "b": .boolean()]).description,
      """
      SEQUENCE ::= {
        a INTEGER
        b BOOLEAN
      }
      """
    )

    XCTAssertEqual(
      Schema.sequenceOf(.integer()).description,
      """
      SEQUENCE OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.sequenceOf(.integer(), size: .min(3)).description,
      """
      SEQUENCE SIZE (3..MAX) OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.sequenceOf(.integer(), size: .max(3)).description,
      """
      SEQUENCE SIZE (0..3) OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.sequenceOf(.integer(), size: .range(2, 4)).description,
      """
      SEQUENCE SIZE (2..4) OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.sequenceOf(.integer(), size: .is(2)).description,
      """
      SEQUENCE SIZE (2) OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.setOf(.integer()).description,
      """
      SET OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.setOf(.integer(), size: .min(3)).description,
      """
      SET SIZE (3..MAX) OF
        INTEGER
      """
    )

    XCTAssertEqual(
      Schema.choiceOf([.integer(), .boolean()]).description,
      """
      CHOICE ::= {
        INTEGER
        BOOLEAN
      }
      """
    )

    XCTAssertEqual(
      Schema.any.description,
      """
      ANY
      """
    )

    XCTAssertEqual(
      Schema.type(.integer()).description,
      """
      INTEGER
      """
    )

    XCTAssertEqual(
      Schema.dynamic(unknownTypeSchema: .boolean(), [.integer(1): .integer()]).description,
      """
      DYNAMIC {
        CASE 1 (INTEGER): INTEGER
        ELSE: BOOLEAN
      }
      """
    )

    XCTAssertEqual(
      Schema.version(.integer()).description,
      """
      INTEGER
      """
    )

    XCTAssertEqual(
      Schema.versioned(range: 1...3, .integer()).description,
      """
      INTEGER -- for version (1..3)
      """
    )

    XCTAssertEqual(
      Schema.optional(.integer()).description,
      """
      INTEGER OPTIONAL
      """
    )

    XCTAssertEqual(
      Schema.implicit(1, .integer()).description,
      """
      [1] IMPLICIT INTEGER
      """
    )

    XCTAssertEqual(
      Schema.explicit(1, .integer()).description,
      """
      [1] EXPLICIT INTEGER
      """
    )

    XCTAssertEqual(
      Schema.boolean().description,
      """
      BOOLEAN
      """
    )

    XCTAssertEqual(
      Schema.boolean(default: false).description,
      """
      BOOLEAN DEFAULT FALSE
      """
    )

    XCTAssertEqual(
      Schema.integer().description,
      """
      INTEGER
      """
    )

    XCTAssertEqual(
      Schema.integer(allowed: ASN1.Integer(1)..<ASN1.Integer(4)).description,
      """
      INTEGER { 1, 2, 3 }
      """
    )

    XCTAssertEqual(
      Schema.integer(default: 1).description,
      """
      INTEGER DEFAULT 1
      """
    )

    XCTAssertEqual(
      Schema.integer(allowed: ASN1.Integer(1)..<ASN1.Integer(4), default: 3).description,
      """
      INTEGER { 1, 2, 3 } DEFAULT 3
      """
    )

    XCTAssertEqual(
      Schema.real.description,
      """
      REAL
      """
    )

    XCTAssertEqual(
      Schema.bitString().description,
      """
      BIT STRING
      """
    )

    XCTAssertEqual(
      Schema.bitString(size: .min(3)).description,
      """
      BIT STRING (3..MAX)
      """
    )

    XCTAssertEqual(
      Schema.octetString().description,
      """
      OCTET STRING
      """
    )

    XCTAssertEqual(
      Schema.octetString(size: .min(3)).description,
      """
      OCTET STRING (3..MAX)
      """
    )

    XCTAssertEqual(
      Schema.objectIdentifier().description,
      """
      OBJECT IDENTIFIER
      """
    )

    XCTAssertEqual(
      Schema.objectIdentifier(allowed: [[1, 2, 3, 4], [4, 5, 6]]).description,
      """
      OBJECT IDENTIFIER { 1.2.3.4 , 4.5.6 }
      """
    )

    XCTAssertEqual(
      Schema.string(kind: .utf8).description,
      """
      UTF8String
      """
    )

    XCTAssertEqual(
      Schema.string(kind: .utf8, size: .max(5)).description,
      """
      UTF8String (0..5)
      """
    )

    XCTAssertEqual(
      Schema.string(kind: .printable).description,
      """
      PRINTABLEString
      """
    )

    XCTAssertEqual(
      Schema.time(kind: .utc).description,
      """
      UTCTime
      """
    )

    XCTAssertEqual(
      Schema.time(kind: .generalized).description,
      """
      GeneralizedTime
      """
    )

    XCTAssertEqual(
      Schema.null.description,
      """
      NULL
      """
    )

    XCTAssertEqual(Schema.nothing.description, "")

  }

  func testSchemaStateDescription() {
    XCTAssertEqual(SchemaState.State.schema(.integer()).description, "INTEGER")
    XCTAssertEqual(SchemaState.State.nothing.description, "NONE")
    XCTAssertEqual(SchemaState.State.disallowed(.integer()).description, "INTEGER DISALLOWED")
  }

  func testSizeId() {
    XCTAssertTrue(Schema.Size.is(2).contains(2))
    XCTAssertFalse(Schema.Size.is(2).contains(1))
    XCTAssertEqual(Schema.Size.is(2).description, "2")
  }

  func testSizeMin() {
    XCTAssertTrue(Schema.Size.min(2).contains(2))
    XCTAssertFalse(Schema.Size.min(2).contains(1))
    XCTAssertEqual(Schema.Size.min(2).description, "2..MAX")
  }

  func testSizeMax() {
    XCTAssertTrue(Schema.Size.max(2).contains(2))
    XCTAssertFalse(Schema.Size.max(2).contains(3))
    XCTAssertEqual(Schema.Size.max(2).description, "0..2")
  }

  func testSizeRange() {
    XCTAssertEqual(Schema.Size.in(2...4), .range(2, 4))
    XCTAssertTrue(Schema.Size.range(2, 4).contains(2))
    XCTAssertTrue(Schema.Size.range(2, 4).contains(4))
    XCTAssertFalse(Schema.Size.range(2, 4).contains(1))
    XCTAssertFalse(Schema.Size.range(2, 4).contains(5))
    XCTAssertEqual(Schema.Size.range(2, 4).description, "2..4")
  }

}
