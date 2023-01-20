//
//  ASN1AnyValueTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentASN1
import PotentCodables
import BigInt
import XCTest


class ASN1AnyValueTests: XCTestCase {

  func testDecode() throws {

    struct TestValue: Codable, SchemaSpecified {
      var boolean: AnyValue
      var integer: AnyValue
      var bitString: AnyValue
      var octetString: AnyValue
      var null: AnyValue
      var objectIdentifier: AnyValue
      var real: AnyValue
      var utf8String: AnyValue
      var sequence: AnyValue
      var set: AnyValue
      var numericString: AnyValue
      var printableString: AnyValue
      var teletexString: AnyValue
      var videotexString: AnyValue
      var ia5String: AnyValue
      var utcTime: AnyValue
      var generalizedTime: AnyValue
      var graphicString: AnyValue
      var visibleString: AnyValue
      var generalString: AnyValue
      var universalString: AnyValue
      var characterString: AnyValue
      var bmpString: AnyValue
      var tagged: AnyValue

      static var asn1Schema: Schema = .sequence([
        "boolean": .boolean(),
        "integer": .integer(),
        "bitString": .bitString(),
        "octetString": .octetString(),
        "null": .null,
        "objectIdentifier": .objectIdentifier(),
        "real": .real,
        "utf8String": .string(kind: .utf8),
        "sequence": .sequenceOf(.any),
        "set": .setOf(.any),
        "numericString": .string(kind: .numeric),
        "printableString": .string(kind: .printable),
        "teletexString": .string(kind: .teletex),
        "videotexString": .string(kind: .videotex),
        "ia5String": .string(kind: .ia5),
        "utcTime": .time(kind: .utc),
        "generalizedTime": .time(kind: .generalized),
        "graphicString": .string(kind: .graphic),
        "visibleString": .string(kind: .visible),
        "generalString": .string(kind: .general),
        "universalString": .string(kind: .universal),
        "characterString": .string(kind: .character),
        "bmpString": .string(kind: .bmp),
        "tagged": .integer(),
      ])

    }


    // swiftlint:disable:next line_length
    let asn1 = Data(hexEncoded: "30819e0101ff02017b0303007fff04050102030405050006042a030405090600312e3233340c0b48656c6c6f20576f726c6430060201010c016131060201021301621203313233130454657374140361626315036465661603676869170d3232313231313130303930385a181332303231313131303039303830372e3030305a19036a6b6c1a036d6e6f1b037071721c037374751d037677781e02797a02020101")

    let value = try ASN1Decoder.decode(TestValue.self, from: asn1)
    XCTAssertEqual(value.boolean, .bool(true))
    XCTAssertEqual(value.integer, .integer(123))
    XCTAssertEqual(value.bitString, .string("0111111111111111"))
    XCTAssertEqual(value.octetString, .data(Data([1, 2, 3, 4, 5])))
    XCTAssertEqual(value.null, .nil)
    XCTAssertEqual(value.objectIdentifier, .array([.uint64(1), .uint64(2), .uint64(3), .uint64(4), .uint64(5)]))
    XCTAssertEqual(value.real, .decimal(1.234))
    XCTAssertEqual(value.utf8String, .string("Hello World"))
    XCTAssertEqual(value.sequence, .array([.integer(1), .string("a")]))
    XCTAssertEqual(value.set, .array([.integer(2), .string("b")]))
    XCTAssertEqual(value.numericString, .string("123"))
    XCTAssertEqual(value.printableString, .string("Test"))
    XCTAssertEqual(value.teletexString, .string("abc"))
    XCTAssertEqual(value.videotexString, .string("def"))
    XCTAssertEqual(value.ia5String, .string("ghi"))
    XCTAssertEqual(value.utcTime, .date(ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")!.utcDate))
    XCTAssertEqual(value.generalizedTime, .date(ZonedDate(iso8601Encoded: "2021-11-10T09:08:07Z")!.utcDate))
    XCTAssertEqual(value.graphicString, .string("jkl"))
    XCTAssertEqual(value.visibleString, .string("mno"))
    XCTAssertEqual(value.generalString, .string("pqr"))
    XCTAssertEqual(value.universalString, .string("stu"))
    XCTAssertEqual(value.characterString, .string("vwx"))
    XCTAssertEqual(value.bmpString, .string("yz"))
    XCTAssertEqual(value.tagged, .integer(257))
  }

  func testEncode() throws {

    struct TestValue: Codable, Equatable, SchemaSpecified {
      var `nil`: AnyValue = .nil
      var bool: AnyValue = .bool(true)
      var string: AnyValue = .string("Hello World!")
      var pi8: AnyValue = .int8(2)
      var pi16: AnyValue = .int16(500)
      var pi32: AnyValue = .int32(70_000)
      var pi64: AnyValue = .int64(5_000_000_000)
      var ni8: AnyValue = .int8(-2)
      var ni16: AnyValue = .int16(-500)
      var ni32: AnyValue = .int32(-70_000)
      var ni64: AnyValue = .int64(-5_000_000_000)
      var u8: AnyValue = .uint8(UInt8.max)
      var u16: AnyValue = .uint16(UInt16.max)
      var u32: AnyValue = .uint32(UInt32.max)
      var u64: AnyValue = .uint64(UInt64.max)
      var nint: AnyValue = .integer(BigInt("-999000000000000000000000000000"))
      var pint: AnyValue = .integer(BigInt("999000000000000000000000000000"))
      var uint: AnyValue = .unsignedInteger(BigUInt("999000000000000000000000000000"))
      var f16: AnyValue = .float16(1.5)
      var f32: AnyValue = .float(1.5)
      var f64: AnyValue = .double(1.5)
      var ppdec: AnyValue = .decimal(Decimal(sign: .plus, exponent: 1, significand: 1234567))
      var pndec: AnyValue = .decimal(Decimal(sign: .plus, exponent: -3, significand: 1234567))
      var npdec: AnyValue = .decimal(Decimal(sign: .minus, exponent: 1, significand: 1234567))
      var nndec: AnyValue = .decimal(Decimal(sign: .minus, exponent: -3, significand: 1234567))
      var data: AnyValue = .data("Binary Data".data(using: .utf8)!)
      var url: AnyValue = .url(URL(string: "https://example.com/some/thing")!)
      var uuid: AnyValue = .uuid(UUID(uuidString: "46076D06-86E8-4B3B-80EF-B24115D4C609")!)
      var date: AnyValue = .date(Date(timeIntervalSinceReferenceDate: 1234567.89))
      var array: AnyValue = .array([nil, false, 456, "a"])
      var object: AnyValue = .dictionary([
        "c": 1,
        "a": 2,
        "d": 3,
        "b": 4,
      ])

      static var asn1Schema: Schema =
        .sequence([
          "nil": .null,
          "bool": .boolean(),
          "string": .string(kind: .utf8),
          "pi8": .integer(),
          "pi16": .integer(),
          "pi32": .integer(),
          "pi64": .integer(),
          "ni8": .integer(),
          "ni16": .integer(),
          "ni32": .integer(),
          "ni64": .integer(),
          "u8": .integer(),
          "u16": .integer(),
          "u32": .integer(),
          "u64": .integer(),
          "nint": .integer(),
          "pint": .integer(),
          "uint": .integer(),
          "f16": .real,
          "f32": .real,
          "f64": .real,
          "ppdec": .real,
          "pndec": .real,
          "npdec": .real,
          "nndec": .real,
          "data": .octetString(),
          "url": .string(kind: .utf8),
          "uuid": .string(kind: .utf8),
          "date": .time(kind: .generalized),
          "array": .sequenceOf(.choiceOf([.null, .boolean(), .integer(), .string(kind: .utf8)])),
          "object": .sequence([
            "c": .integer(),
            "a": .integer(),
            "d": .integer(),
            "b": .integer(),
          ]),
        ])
    }
    let srcValue = TestValue()

    // swiftlint:disable:next line_length
    let asn1 = Data(hexEncoded: "3082014505000101ff0c0c48656c6c6f20576f726c6421020102020201f402030111700205012a05f2000201fe0202fe0c0203feee900205fed5fa0e00020200ff020300ffff020500ffffffff020900ffffffffffffffff020df3640e916c595b9252a8000000020d0c9bf16e93a6a46dad58000000020d0c9bf16e93a6a46dad58000000090400312e35090400312e35090400312e350909003132333435363730090900313233342e353637090a002d3132333435363730090a002d313233342e353637040b42696e61727920446174610c1e68747470733a2f2f6578616d706c652e636f6d2f736f6d652f7468696e670c2434363037364430362d383645382d344233422d383045462d423234313135443443363039181332303031303131353036353630372e3839305a300c0500010100020201c80c0161300c020101020102020103020104")

    XCTAssertEqual(try srcValue.encoded(), asn1)

    let dstValue = try ASN1Decoder.decode(TestValue.self, from: asn1)
    XCTAssertEqual(dstValue.nil, srcValue.nil)
    XCTAssertEqual(dstValue.bool, srcValue.bool)
    XCTAssertEqual(dstValue.string, srcValue.string)
    XCTAssertEqual(dstValue.pi8, .integer(2))
    XCTAssertEqual(dstValue.pi16, .integer(500))
    XCTAssertEqual(dstValue.pi32, .integer(70_000))
    XCTAssertEqual(dstValue.pi64, .integer(5_000_000_000))
    XCTAssertEqual(dstValue.ni8, .integer(-2))
    XCTAssertEqual(dstValue.ni16, .integer(-500))
    XCTAssertEqual(dstValue.ni32, .integer(-70_000))
    XCTAssertEqual(dstValue.ni64, .integer(-5_000_000_000))
    XCTAssertEqual(dstValue.u8, .integer(BigInt(UInt8.max)))
    XCTAssertEqual(dstValue.u16, .integer(BigInt(UInt16.max)))
    XCTAssertEqual(dstValue.u32, .integer(BigInt(UInt32.max)))
    XCTAssertEqual(dstValue.u64, .integer(BigInt(UInt64.max)))
    XCTAssertEqual(dstValue.pint, .integer(BigInt("999000000000000000000000000000")))
    XCTAssertEqual(dstValue.nint, .integer(BigInt("-999000000000000000000000000000")))
    XCTAssertEqual(dstValue.uint, .integer(BigInt("999000000000000000000000000000")))
    XCTAssertEqual(dstValue.f16, .decimal(1.5))
    XCTAssertEqual(dstValue.f32, .decimal(1.5))
    XCTAssertEqual(dstValue.f64, .decimal(1.5))
    XCTAssertEqual(dstValue.ppdec, srcValue.ppdec)
    XCTAssertEqual(dstValue.pndec, srcValue.pndec)
    XCTAssertEqual(dstValue.npdec, srcValue.npdec)
    XCTAssertEqual(dstValue.nndec, srcValue.nndec)
    XCTAssertEqual(dstValue.data, srcValue.data)
    XCTAssertEqual(dstValue.url, srcValue.url.urlValue.map { .string($0.absoluteString) })
    XCTAssertEqual(dstValue.uuid, srcValue.uuid.uuidValue.map { .string($0.uuidString) })
    XCTAssertEqual(dstValue.date.dateValue?.timeIntervalSince1970, srcValue.date.dateValue?.timeIntervalSince1970)
    XCTAssertEqual(dstValue.array, .array([.nil, false, .integer(456), "a"]))
    XCTAssertEqual(dstValue.object, .array([.integer(1), .integer(2), .integer(3), .integer(4)]))
  }

}
