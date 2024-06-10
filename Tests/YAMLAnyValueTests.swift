//
//  YAMLAnyValueTests.swift
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
import PotentYAML
import XCTest


class YAMLAnyValueTests: XCTestCase {

  func testDecode() throws {

    struct TestValue: Codable {
      var `nil`: AnyValue
      var bool: AnyValue
      var number: AnyValue
      var string: AnyValue
      var array: AnyValue
      var object: AnyValue
    }

    let yaml =
    """
    ---
    nil: null
    bool: true
    number: 123.456
    string: "Hello World!"
    array:
    - null
    - false
    - 456
    - "a"
    object:
      c: 1
      a: 2
      d: 3
      b: 4
    """

    let value = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(value.nil, AnyValue.nil)
    XCTAssertEqual(value.bool, AnyValue.bool(true))
    XCTAssertEqual(value.number, AnyValue.double(123.456))
    XCTAssertEqual(value.string, AnyValue.string("Hello World!"))
    XCTAssertEqual(value.array, AnyValue.array([.nil, .bool(false), .int64(456), .string("a")]))
    XCTAssertEqual(value.object, AnyValue.dictionary(["c": 1, "a": 2, "d": 3, "b": 4]))
  }

  func testEncode() throws {

    struct TestValue: Codable {
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
      var f32: AnyValue = .float(12.34567)
      var f64: AnyValue = .double(123.4567)
      var pdec: AnyValue = .decimal(Decimal(sign: .plus, exponent: -3, significand: 1234567))
      var ndec: AnyValue = .decimal(Decimal(sign: .minus, exponent: -3, significand: 1234567))
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
      var intObject: AnyValue = .dictionary([
        2: "a",
        1: "b",
        4: "c",
        3: "d",
      ])
    }
    let srcValue = TestValue()

    let yaml =
    """
    nil: null
    bool: true
    string: Hello World!
    pi8: 2
    pi16: 500
    pi32: 70000
    pi64: 5000000000
    ni8: -2
    ni16: -500
    ni32: -70000
    ni64: -5000000000
    u8: 255
    u16: 65535
    u32: 4294967295
    u64: 18446744073709551615
    nint: -999000000000000000000000000000
    pint: 999000000000000000000000000000
    uint: 999000000000000000000000000000
    f16: 1.5
    f32: 12.34567
    f64: 123.4567
    pdec: 1234.567
    ndec: -1234.567
    data: QmluYXJ5IERhdGE=
    url: https://example.com/some/thing
    uuid: 46076D06-86E8-4B3B-80EF-B24115D4C609
    date: 1234567.89
    array:
    - null
    - false
    - 456
    - a
    object:
      c: 1
      a: 2
      d: 3
      b: 4
    intObject:
      2: a
      1: b
      4: c
      3: d

    """

    XCTAssertEqual(try YAMLEncoder.default.encodeString(TestValue()), yaml)

    let dstValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(dstValue.nil, srcValue.nil)
    XCTAssertEqual(dstValue.bool, srcValue.bool)
    XCTAssertEqual(dstValue.string, srcValue.string)
    XCTAssertEqual(dstValue.pi8, .int64(2))
    XCTAssertEqual(dstValue.pi16, .int64(500))
    XCTAssertEqual(dstValue.pi32, .int64(70_000))
    XCTAssertEqual(dstValue.pi64, srcValue.pi64)
    XCTAssertEqual(dstValue.ni8, .int64(-2))
    XCTAssertEqual(dstValue.ni16, .int64(-500))
    XCTAssertEqual(dstValue.ni32, .int64(-70_000))
    XCTAssertEqual(dstValue.ni64, srcValue.ni64)
    XCTAssertEqual(dstValue.u8, .int64(Int64(UInt8.max)))
    XCTAssertEqual(dstValue.u16, .int64(Int64(UInt16.max)))
    XCTAssertEqual(dstValue.u32, .int64(Int64(UInt32.max)))
    XCTAssertEqual(dstValue.u64, .uint64(UInt64.max))
    XCTAssertEqual(dstValue.pint, srcValue.pint)
    XCTAssertEqual(dstValue.nint, srcValue.nint)
    XCTAssertEqual(dstValue.uint, .integer(BigInt("999000000000000000000000000000")))
    XCTAssertEqual(dstValue.f16, .double(1.5))
    XCTAssertEqual(dstValue.f32, .double(12.34567))
    XCTAssertEqual(dstValue.f64, srcValue.f64)
    XCTAssertEqual(dstValue.pdec, .double(1234.567))
    XCTAssertEqual(dstValue.ndec, .double(-1234.567))
    XCTAssertEqual(dstValue.data, .string(srcValue.data.dataValue!.base64EncodedString()))
    XCTAssertEqual(dstValue.url, .string(srcValue.url.urlValue!.absoluteString))
    XCTAssertEqual(dstValue.uuid, .string(srcValue.uuid.uuidValue!.uuidString))
    XCTAssertEqual(dstValue.date, .double(srcValue.date.dateValue!.timeIntervalSinceReferenceDate))
    XCTAssertEqual(dstValue.array, .array([nil, false, .int64(456), "a"]))
    XCTAssertEqual(dstValue.object, .dictionary(["c": .int64(1), "a": .int64(2), "d": .int64(3), "b": .int64(4)]))
    XCTAssertEqual(dstValue.intObject, .dictionary([.int64(2): "a", .int64(1): "b", .int64(4): "c", .int64(3): "d"]))
  }

}
