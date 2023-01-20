//
//  ASN1ValueTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentASN1
import PotentJSON
import PotentCodables
import XCTest


class ASN1ValueTests: XCTestCase {

  func testAbsoluteAccessor() {
    XCTAssertEqual(ASN1.default(.boolean(true)).absolute, ASN1.boolean(true))
    XCTAssertEqual(ASN1.boolean(true).absolute, ASN1.boolean(true))
  }

  func testBooleanAccessor() {
    XCTAssertEqual(ASN1.boolean(true).booleanValue, true)
    XCTAssertNil(ASN1.null.booleanValue)
  }

  func testIntegerAccessor() {
    XCTAssertEqual(ASN1.integer(123).integerValue, 123)
    XCTAssertNil(ASN1.null.integerValue)
  }

  func testBitStringAccessor() {
    XCTAssertEqual(ASN1.bitString(8, Data([0xff])).bitStringValue, BitString(length: 8, bytes: Data([0xff])))
    XCTAssertNil(ASN1.null.bitStringValue)
  }

  func testOctetStringAccessor() {
    XCTAssertEqual(ASN1.octetString(Data([1, 2, 3])).octetStringValue, Data([1, 2, 3]))
    XCTAssertNil(ASN1.null.octetStringValue)
  }

  func testObjectIdentifierAccessor() {
    XCTAssertEqual(ASN1.objectIdentifier([1, 2, 3, 4]).objectIdentifierValue, ObjectIdentifier([1, 2, 3, 4]))
    XCTAssertNil(ASN1.null.objectIdentifierValue)
  }

  func testRealAccessor() {
    XCTAssertEqual(ASN1.real(Decimal(1.23)).realValue, Decimal(1.23))
    XCTAssertNil(ASN1.null.realValue)
  }

  func testUT8StringAccessor() {
    XCTAssertEqual(ASN1.utf8String("test").utf8StringValue, AnyString("test", kind: .utf8))
    XCTAssertNil(ASN1.null.utf8StringValue)
  }

  func testNumericStringAccessor() {
    XCTAssertEqual(ASN1.numericString("test").numericStringValue, AnyString("test", kind: .numeric))
    XCTAssertNil(ASN1.null.numericStringValue)
  }

  func testPrintableStringAccessor() {
    XCTAssertEqual(ASN1.printableString("test").printableStringValue, AnyString("test", kind: .printable))
    XCTAssertNil(ASN1.null.printableStringValue)
  }

  func testTeletexStringAccessor() {
    XCTAssertEqual(ASN1.teletexString("test").teletexStringValue, AnyString("test", kind: .teletex))
    XCTAssertNil(ASN1.null.teletexStringValue)
  }

  func testVideotextStringAccessor() {
    XCTAssertEqual(ASN1.videotexString("test").videotexStringValue, AnyString("test", kind: .videotex))
    XCTAssertNil(ASN1.null.videotexStringValue)
  }

  func testIA5StringAccessor() {
    XCTAssertEqual(ASN1.ia5String("test").ia5StringValue, AnyString("test", kind: .ia5))
    XCTAssertNil(ASN1.null.ia5StringValue)
  }

  func testUTCTimeAccessor() {
    let zd = ZonedDate(date: Date(), timeZone: .utc)
    XCTAssertEqual(ASN1.utcTime(zd).utcTimeValue, AnyTime(zd, kind: .utc))
    XCTAssertNil(ASN1.null.utcTimeValue)
  }

  func testGeneralizedTimeAccessor() {
    let zd = ZonedDate(date: Date(), timeZone: .utc)
    XCTAssertEqual(ASN1.generalizedTime(zd).generalizedTimeValue, AnyTime(zd, kind: .generalized))
      XCTAssertNil(ASN1.null.generalizedTimeValue)
  }

  func testGraphicStringAccessor() {
    XCTAssertEqual(ASN1.graphicString("test").graphicStringValue, AnyString("test", kind: .graphic))
    XCTAssertNil(ASN1.null.graphicStringValue)
  }

  func testVisibleStringAccessor() {
    XCTAssertEqual(ASN1.visibleString("test").visibleStringValue, AnyString("test", kind: .visible))
    XCTAssertNil(ASN1.null.visibleStringValue)
  }

  func testGeneralStringAccessor() {
    XCTAssertEqual(ASN1.generalString("test").generalStringValue, AnyString("test", kind: .general))
    XCTAssertNil(ASN1.null.generalStringValue)
  }

  func testUniversalStringAccessor() {
    XCTAssertEqual(ASN1.universalString("test").universalStringValue, AnyString("test", kind: .universal))
    XCTAssertNil(ASN1.null.universalStringValue)
  }

  func testCharacterStringAccessor() {
    XCTAssertEqual(ASN1.characterString("test").characterStringValue, AnyString("test", kind: .character))
    XCTAssertNil(ASN1.null.characterStringValue)
  }

  func testBMPStringAccessor() {
    XCTAssertEqual(ASN1.bmpString("test").bmpStringValue, AnyString("test", kind: .bmp))
    XCTAssertNil(ASN1.null.bmpStringValue)
  }

  func testtringAccessor() {
    XCTAssertEqual(ASN1.utf8String("test").stringValue, AnyString("test", kind: .utf8))
    XCTAssertEqual(ASN1.numericString("test").stringValue, AnyString("test", kind: .numeric))
    XCTAssertEqual(ASN1.printableString("test").stringValue, AnyString("test", kind: .printable))
    XCTAssertEqual(ASN1.teletexString("test").stringValue, AnyString("test", kind: .teletex))
    XCTAssertEqual(ASN1.videotexString("test").stringValue, AnyString("test", kind: .videotex))
    XCTAssertEqual(ASN1.ia5String("test").stringValue, AnyString("test", kind: .ia5))
    XCTAssertEqual(ASN1.graphicString("test").stringValue, AnyString("test", kind: .graphic))
    XCTAssertEqual(ASN1.visibleString("test").stringValue, AnyString("test", kind: .visible))
    XCTAssertEqual(ASN1.generalString("test").stringValue, AnyString("test", kind: .general))
    XCTAssertEqual(ASN1.universalString("test").stringValue, AnyString("test", kind: .universal))
    XCTAssertEqual(ASN1.characterString("test").stringValue, AnyString("test", kind: .character))
    XCTAssertEqual(ASN1.bmpString("test").stringValue, AnyString("test", kind: .bmp))
    XCTAssertNil(ASN1.boolean(false).stringValue)
  }

  func testTimeAccesor() {
    let zd = ZonedDate(date: Date(), timeZone: .utc)
    XCTAssertEqual(ASN1.utcTime(zd).timeValue, AnyTime(zd, kind: .utc))
    XCTAssertEqual(ASN1.generalizedTime(zd).timeValue, AnyTime(zd, kind: .generalized))
    XCTAssertNil(ASN1.null.timeValue)
  }

  func testCollectionAccessor() {
    XCTAssertEqual(ASN1.sequence([.integer(1), .integer(2)]).collectionValue, [.integer(1), .integer(2)])
    XCTAssertEqual(ASN1.set([.integer(1), .integer(2)]).collectionValue, [.integer(1), .integer(2)])
    XCTAssertNil(ASN1.null.collectionValue)
  }

  func testTaggedValueAccessor() {
    XCTAssertEqual(ASN1.tagged(ASN1.Tag.integer.rawValue, Data([1, 1])).taggedValue,
                   TaggedValue(tag: ASN1.Tag.integer.rawValue, data: Data([1, 1])))
    XCTAssertNil(ASN1.null.taggedValue)
  }

  func testTagName() {
    XCTAssertEqual(ASN1.boolean(true).tagName, "BOOLEAN")
    XCTAssertEqual(ASN1.default(.boolean(true)).tagName, "BOOLEAN")
    XCTAssertEqual(ASN1.tagged(3, Data()).tagName, "IMPLICIT TAGGED (3)")
  }

  func testUnwrapped() {

    let date = Date()

    XCTAssertEqual(ASN1.boolean(true).unwrapped as? Bool, true)
    XCTAssertEqual(ASN1.integer(123).unwrapped as? BigInt, BigInt(123))
    XCTAssertEqual(ASN1.bitString(8, Data([0xff])).unwrapped as? [Bool], [true, true, true, true, true, true, true, true])
    XCTAssertEqual(ASN1.octetString(Data([1, 2, 3])).unwrapped as? Data, Data([1, 2, 3]))
    XCTAssertNil(ASN1.null.unwrapped)
    XCTAssertEqual(ASN1.objectIdentifier([1, 2, 3, 4]).unwrapped as? [UInt64], [1, 2, 3, 4])
    XCTAssertEqual(ASN1.real(1.234).unwrapped as? Decimal, Decimal(1.234))
    XCTAssertEqual(ASN1.utf8String("test").unwrapped as? String, "test")
    XCTAssertEqual(ASN1.sequence([.integer(1), .integer(2), .integer(3)]).unwrapped as? [BigInt], [1, 2, 3])
    XCTAssertEqual(ASN1.set([.integer(1), .integer(2), .integer(3)]).unwrapped as? [BigInt], [1, 2, 3])
    XCTAssertEqual(ASN1.numericString("123").unwrapped as? String, "123")
    XCTAssertEqual(ASN1.printableString("test").unwrapped as? String, "test")
    XCTAssertEqual(ASN1.teletexString("tel").unwrapped as? String, "tel")
    XCTAssertEqual(ASN1.videotexString("vid").unwrapped as? String, "vid")
    XCTAssertEqual(ASN1.ia5String("ia5").unwrapped as? String, "ia5")
    XCTAssertEqual(ASN1.utcTime(ZonedDate(date: date, timeZone: .utc)).unwrapped as? Date, date)
    XCTAssertEqual(ASN1.generalizedTime(ZonedDate(date: date, timeZone: .utc)).unwrapped as? Date, date)
    XCTAssertEqual(ASN1.graphicString("gr").unwrapped as? String, "gr")
    XCTAssertEqual(ASN1.visibleString("vis").unwrapped as? String, "vis")
    XCTAssertEqual(ASN1.generalString("gen").unwrapped as? String, "gen")
    XCTAssertEqual(ASN1.universalString("uni").unwrapped as? String, "uni")
    XCTAssertEqual(ASN1.characterString("char").unwrapped as? String, "char")
    XCTAssertEqual(ASN1.bmpString("bmp").unwrapped as? String, "bmp")
    XCTAssertEqual(ASN1.tagged(ASN1.Tag.integer.rawValue, Data([0x7f])).unwrapped as? BigInt, 0x7f)
    XCTAssertEqual(ASN1.default(.boolean(true)).unwrapped as? Bool, true)
  }

  func testCurrentValue() {

    let date = Date()

    XCTAssertEqual(ASN1.boolean(true).currentValue as? Bool, true)
    XCTAssertEqual(ASN1.integer(123).currentValue as? BigInt, BigInt(123))
    XCTAssertEqual(ASN1.bitString(8, Data([0xff])).currentValue as? BitString, BitString(length: 8, bytes: Data([0xff])))
    XCTAssertEqual(ASN1.octetString(Data([1, 2, 3])).currentValue as? Data, Data([1, 2, 3]))
    XCTAssertNil(ASN1.null.currentValue)
    XCTAssertEqual(ASN1.objectIdentifier([1, 2, 3, 4]).currentValue as? ObjectIdentifier, [1, 2, 3, 4])
    XCTAssertEqual(ASN1.real(1.234).currentValue as? Decimal, Decimal(1.234))
    XCTAssertEqual(ASN1.utf8String("test").currentValue as? AnyString, AnyString("test", kind: .utf8))
    XCTAssertEqual(ASN1.sequence([.integer(1), .integer(2), .integer(3)]).currentValue as? [ASN1],
                   [ASN1.integer(1), ASN1.integer(2), ASN1.integer(3)])
    XCTAssertEqual(ASN1.set([.integer(1), .integer(2), .integer(3)]).currentValue as? [ASN1],
                   [ASN1.integer(1), ASN1.integer(2), ASN1.integer(3)])
    XCTAssertEqual(ASN1.numericString("123").currentValue as? AnyString, AnyString("123", kind: .numeric))
    XCTAssertEqual(ASN1.printableString("test").currentValue as? AnyString, AnyString("test", kind: .printable))
    XCTAssertEqual(ASN1.teletexString("tel").currentValue as? AnyString, AnyString("tel", kind: .teletex))
    XCTAssertEqual(ASN1.videotexString("vid").currentValue as? AnyString, AnyString("vid", kind: .videotex))
    XCTAssertEqual(ASN1.ia5String("ia5").currentValue as? AnyString, AnyString("ia5", kind: .ia5))
    XCTAssertEqual(ASN1.utcTime(ZonedDate(date: date, timeZone: .utc)).currentValue as? AnyTime,
                   AnyTime(date: date, timeZone: .utc, kind: .utc))
    XCTAssertEqual(ASN1.generalizedTime(ZonedDate(date: date, timeZone: .utc)).currentValue as? AnyTime,
                   AnyTime(date: date, timeZone: .utc, kind: .generalized))
    XCTAssertEqual(ASN1.graphicString("gr").currentValue as? AnyString, AnyString("gr", kind: .graphic))
    XCTAssertEqual(ASN1.visibleString("vis").currentValue as? AnyString, AnyString("vis", kind: .visible))
    XCTAssertEqual(ASN1.generalString("gen").currentValue as? AnyString, AnyString("gen", kind: .general))
    XCTAssertEqual(ASN1.universalString("uni").currentValue as? AnyString, AnyString("uni", kind: .universal))
    XCTAssertEqual(ASN1.characterString("char").currentValue as? AnyString, AnyString("char", kind: .character))
    XCTAssertEqual(ASN1.bmpString("bmp").currentValue as? AnyString, AnyString("bmp", kind: .bmp))
    XCTAssertNotNil(ASN1.tagged(ASN1.Tag.integer.rawValue, Data([0x7f])).currentValue)
    XCTAssertEqual(ASN1.default(.boolean(true)).currentValue as? Bool, true)
  }

  func testTagDesciption() {

    XCTAssertEqual(ASN1.Tag.boolean.description, "BOOLEAN")
    XCTAssertEqual(ASN1.Tag.integer.description, "INTEGER")
    XCTAssertEqual(ASN1.Tag.bitString.description, "BIT STRING")
    XCTAssertEqual(ASN1.Tag.octetString.description, "OCTET STRING")
    XCTAssertEqual(ASN1.Tag.null.description, "NULL")
    XCTAssertEqual(ASN1.Tag.objectIdentifier.description, "OBJECT IDENTIFIER")
    XCTAssertEqual(ASN1.Tag.objectDescriptor.description, "OBJECT DESCRIPTOR")
    XCTAssertEqual(ASN1.Tag.external.description, "EXTERNAL")
    XCTAssertEqual(ASN1.Tag.real.description, "REAL")
    XCTAssertEqual(ASN1.Tag.enumerated.description, "ENUMERATED")
    XCTAssertEqual(ASN1.Tag.embedded.description, "EMBEDDED")
    XCTAssertEqual(ASN1.Tag.utf8String.description, "UTF8String")
    XCTAssertEqual(ASN1.Tag.relativeOID.description, "RELATIVE OID")
    XCTAssertEqual(ASN1.Tag.sequence.description, "SEQUENCE")
    XCTAssertEqual(ASN1.Tag.set.description, "SET")
    XCTAssertEqual(ASN1.Tag.numericString.description, "NumericString")
    XCTAssertEqual(ASN1.Tag.printableString.description, "PrintableString")
    XCTAssertEqual(ASN1.Tag.teletexString.description, "TeletexString")
    XCTAssertEqual(ASN1.Tag.videotexString.description, "VideotexString")
    XCTAssertEqual(ASN1.Tag.ia5String.description, "IA5String")
    XCTAssertEqual(ASN1.Tag.utcTime.description, "UTCTime")
    XCTAssertEqual(ASN1.Tag.generalizedTime.description, "GeneralizedTime")
    XCTAssertEqual(ASN1.Tag.graphicString.description, "GraphicString")
    XCTAssertEqual(ASN1.Tag.visibleString.description, "VisibleString")
    XCTAssertEqual(ASN1.Tag.generalString.description, "GeneralString")
    XCTAssertEqual(ASN1.Tag.universalString.description, "UniversalString")
    XCTAssertEqual(ASN1.Tag.characterString.description, "CharacterString")
    XCTAssertEqual(ASN1.Tag.bmpString.description, "BMPString")
  }

  func testEncodable() {
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.boolean(true)),
                   .array([ASN1.Tag.boolean.json, true]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.integer(123)),
                   .array([ASN1.Tag.integer.json, 123]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.bitString(3, Data([0xff]))),
                   .array([ASN1.Tag.bitString.json, "111"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.octetString(Data([1, 2]))),
                   .array([ASN1.Tag.octetString.json, "AQI="]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.null),
                   .array([ASN1.Tag.null.json, nil]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.objectIdentifier([1, 2, 3, 4])),
                   .array([ASN1.Tag.objectIdentifier.json, "1.2.3.4"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.real(Decimal(1.5))),
                   .array([ASN1.Tag.real.json, 1.5]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.utf8String("test")),
                   .array([ASN1.Tag.utf8String.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.sequence([.utf8String("test"), .boolean(true)])),
                   .array([ASN1.Tag.sequence.json, [[ASN1.Tag.utf8String.json, "test"], [ASN1.Tag.boolean.json, true]]]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.set([.utf8String("test"), .boolean(true)])),
                   .array([ASN1.Tag.set.json, [[ASN1.Tag.utf8String.json, "test"], [ASN1.Tag.boolean.json, true]]]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.numericString("test")),
                   .array([ASN1.Tag.numericString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.printableString("test")),
                   .array([ASN1.Tag.printableString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.teletexString("test")),
                   .array([ASN1.Tag.teletexString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.videotexString("test")),
                   .array([ASN1.Tag.videotexString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.ia5String("test")),
                   .array([ASN1.Tag.ia5String.json, "test"]))

    let zd = ZonedDate(date: Date(), timeZone: .utc)

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.utcTime(zd)),
                   .array([ASN1.Tag.utcTime.json, .string(zd.iso8601EncodedString())]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.generalizedTime(zd)),
                   .array([ASN1.Tag.generalizedTime.json, .string(zd.iso8601EncodedString())]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.graphicString("test")),
                   .array([ASN1.Tag.graphicString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.visibleString("test")),
                   .array([ASN1.Tag.visibleString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.generalString("test")),
                   .array([ASN1.Tag.generalString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.universalString("test")),
                   .array([ASN1.Tag.universalString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.characterString("test")),
                   .array([ASN1.Tag.characterString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.bmpString("test")),
                   .array([ASN1.Tag.bmpString.json, "test"]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.tagged(ASN1.Tag.integer.rawValue, Data([2]))),
                   .array([ASN1.Tag.integer.json, 2]))

    let tag = ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: false)

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.tagged(tag, Data([1, 2]))),
                   .array([.number(.init(tag)), "AQI="]))

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(ASN1.default(.bmpString("test"))),
                   .array([ASN1.Tag.bmpString.json, "test"]))
  }

  func testDecodable() {
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.boolean.json, true])),
                   .boolean(true))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.integer.json, 123])),
                   .integer(123))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.bitString.json, "111"])),
                   .bitString(3, Data([0xE0])))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.octetString.json, "AQI="])),
                   .octetString(Data([1, 2])))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.null.json, nil])),
                   .null)

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self,
                                                       from: .array([ASN1.Tag.objectIdentifier.json, "1.2.3.4"])),
                   .objectIdentifier([1, 2, 3, 4]))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.real.json, 1.5])),
                   .real(Decimal(1.5)))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.utf8String.json, "test"])),
                   .utf8String("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.sequence.json,
                                                                                [[ASN1.Tag.utf8String.json, "test"],
                                                                                 [ASN1.Tag.boolean.json, true]]])),
                   .sequence([.utf8String("test"), .boolean(true)]))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.set.json,
                                                                                [[ASN1.Tag.utf8String.json, "test"],
                                                                                 [ASN1.Tag.boolean.json, true]]])),
                   .set([.utf8String("test"), .boolean(true)]))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.numericString.json, "test"])),
                   .numericString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.printableString.json, "test"])),
                   .printableString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.teletexString.json, "test"])),
                   .teletexString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.videotexString.json, "test"])),
                   .videotexString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.ia5String.json, "test"])),
                   .ia5String("test"))

    let zd = ZonedDate(date: Date().truncatedToSecs, timeZone: .utc)

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.utcTime.json,
                                                                                .string(zd.iso8601EncodedString())])),
                   .utcTime(zd))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.generalizedTime.json,
                                                                                .string(zd.iso8601EncodedString())])),
                   .generalizedTime(zd))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.graphicString.json, "test"])),
                   .graphicString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.visibleString.json, "test"])),
                   .visibleString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.generalString.json, "test"])),
                   .generalString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.universalString.json, "test"])),
                   .universalString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.characterString.json, "test"])),
                   .characterString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.bmpString.json, "test"])),
                   .bmpString("test"))

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([ASN1.Tag.integer.json, .number(2)])),
                   .integer(BigInt(2)))

    let tag = ASN1.Tag.tag(from: 1, in: .contextSpecific, constructed: false)

    XCTAssertEqual(try JSON.Decoder.default.decodeTree(ASN1.self, from: .array([.number(.init(tag)), "AQI="])),
                   .tagged(tag, Data([1, 2])))
  }

}

private extension ASN1.Tag {
  var json: JSON { .number(JSON.Number(rawValue)) }
}
