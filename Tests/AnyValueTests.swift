//
//  AnyValueTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import OrderedCollections
@testable import PotentCodables
import XCTest


class AnyValueTests: XCTestCase {

  func testLiterals() {
    XCTAssertEqual(nil as AnyValue, .nil)
    XCTAssertEqual(true as AnyValue, .bool(true))
    XCTAssertEqual("test" as AnyValue, .string("test"))
    XCTAssertEqual(123 as AnyValue, .int(123))
    XCTAssertEqual(1.5 as AnyValue, .double(1.5))
    XCTAssertEqual([1, 2, 3] as AnyValue, .array([1, 2, 3]))
    XCTAssertEqual(["a": 1, "b": 2, "c": 3] as AnyValue, .dictionary(["a": 1, "b": 2, "c": 3]))
  }

  func testAnyValueSubscript() {
    let value: AnyValue = ["a": 1]
    XCTAssertEqual(value["a"], 1)
    XCTAssertNil(value["b"])
    XCTAssertNil(([1, 2, 3] as AnyValue)["a"])
  }

  func testIntSubscript() {
    let value: AnyValue = ["a", "b", "c"]
    XCTAssertEqual(value[1], "b")
    XCTAssertNil(value[4])
  }

  func testDynamicMemberAccess() {
    let value: AnyValue = ["aaa": 1]
    XCTAssertEqual(value.aaa, 1)
    XCTAssertNil(value.bbb)
    XCTAssertNil(([1, 2, 3] as AnyValue).aaa)
  }

  func testIsNullAccessor() {
    XCTAssertTrue(AnyValue.nil.isNull)
    XCTAssertFalse(AnyValue.bool(false).isNull)
  }

  func testBoolAccessor() {
    XCTAssertEqual(AnyValue.bool(true).boolValue, true)
    XCTAssertNil(AnyValue.int(1).boolValue)
  }

  func testIntAccessor() {
    XCTAssertEqual(AnyValue.int(123).intValue, 123)
    XCTAssertNil(AnyValue.bool(false).intValue)
  }

  func testInt8Accessor() {
    XCTAssertEqual(AnyValue.int8(123).int8Value, 123)
    XCTAssertNil(AnyValue.bool(false).int8Value)
  }

  func testInt16Accessor() {
    XCTAssertEqual(AnyValue.int16(123).int16Value, 123)
    XCTAssertNil(AnyValue.bool(false).int16Value)
  }

  func testInt32Accessor() {
    XCTAssertEqual(AnyValue.int32(123).int32Value, 123)
    XCTAssertNil(AnyValue.bool(false).int32Value)
  }

  func testInt64Accessor() {
    XCTAssertEqual(AnyValue.int64(123).int64Value, 123)
    XCTAssertNil(AnyValue.bool(false).int64Value)
  }

  func testUIntAccessor() {
    XCTAssertEqual(AnyValue.uint(123).uintValue, 123)
    XCTAssertNil(AnyValue.bool(false).uintValue)
  }

  func testUInt8Accessor() {
    XCTAssertEqual(AnyValue.uint8(123).uint8Value, 123)
    XCTAssertNil(AnyValue.bool(false).uint8Value)
  }

  func testUInt16Accessor() {
    XCTAssertEqual(AnyValue.uint16(123).uint16Value, 123)
    XCTAssertNil(AnyValue.bool(false).uint16Value)
  }

  func testUInt32Accessor() {
    XCTAssertEqual(AnyValue.uint32(123).uint32Value, 123)
    XCTAssertNil(AnyValue.bool(false).uint32Value)
  }

  func testUInt64Accessor() {
    XCTAssertEqual(AnyValue.uint64(123).uint64Value, 123)
    XCTAssertNil(AnyValue.bool(false).uint64Value)
  }

  func testIntegerAccessor() {
    XCTAssertEqual(AnyValue.int8(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.int16(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.int32(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.int64(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.uint8(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.uint16(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.uint32(123).integerValue(Int.self), 123)
    XCTAssertEqual(AnyValue.uint64(123).integerValue(Int.self), 123)
    XCTAssertNil(AnyValue.float16(123).integerValue(Int.self))
  }

  func testFloat16Accessor() {
    XCTAssertEqual(AnyValue.float16(1.5).float16Value, 1.5)
    XCTAssertNil(AnyValue.bool(false).float16Value)
  }

  func testFloatAccessor() {
    XCTAssertEqual(AnyValue.float(1.5).floatValue, 1.5)
    XCTAssertNil(AnyValue.bool(false).floatValue)
  }

  func testDoubleAccessor() {
    XCTAssertEqual(AnyValue.double(1.5).doubleValue, 1.5)
    XCTAssertNil(AnyValue.bool(false).doubleValue)
  }

  func testDecimalAccessor() {
    XCTAssertEqual(AnyValue.decimal(1.5).decimalValue, 1.5)
    XCTAssertNil(AnyValue.bool(false).decimalValue)
  }

  func testFloatingPointAccessor() {
    XCTAssertEqual(AnyValue.int8(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.int16(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.int32(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.int64(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.uint8(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.uint16(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.uint32(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.uint64(123).floatingPointValue(Float.self), 123)
    XCTAssertEqual(AnyValue.float16(1.5).floatingPointValue(Float.self), 1.5)
    XCTAssertEqual(AnyValue.float(1.5).floatingPointValue(Float.self), 1.5)
    XCTAssertEqual(AnyValue.double(1.5).floatingPointValue(Float.self), 1.5)
    XCTAssertEqual(AnyValue.decimal(1.5).floatingPointValue(Float.self), 1.5)
    XCTAssertNil(AnyValue.bool(false).floatingPointValue(Float.self))
  }

  func testStringAccessor() {
    XCTAssertEqual(AnyValue.string("test").stringValue, "test")
    XCTAssertNil(AnyValue.int(1).stringValue)
  }

  func testUrlAccessor() {
    XCTAssertEqual(AnyValue.url(URL(string: "https://example.com")!).urlValue, URL(string: "https://example.com"))
    XCTAssertNil(AnyValue.int(1).urlValue)
  }

  func testUUIDAccessor() {
    let uuid = UUID()
    XCTAssertEqual(AnyValue.uuid(uuid).uuidValue, uuid)
    XCTAssertNil(AnyValue.int(1).uuidValue)
  }

  func testDataAccessor() {
    XCTAssertEqual(AnyValue.data(Data([1, 2, 3])).dataValue, Data([1, 2, 3]))
    XCTAssertNil(AnyValue.int(1).dataValue)
  }

  func testDat3Accessor() {
    let date = Date()
    XCTAssertEqual(AnyValue.date(date).dateValue, date)
    XCTAssertNil(AnyValue.int(1).dateValue)
  }

  func testArrayAccessor() {
    XCTAssertEqual(AnyValue.array([1, 2, 3]).arrayValue, [1, 2, 3] as AnyValue.AnyArray)
    XCTAssertNil(AnyValue.int(1).arrayValue)
  }

  func testDictionaryAccessor() {
    XCTAssertEqual(AnyValue.dictionary(["a": 1, "b": 2]).dictionaryValue, ["a": 1, "b": 2] as AnyValue.AnyDictionary)
    XCTAssertNil(AnyValue.int(1).dictionaryValue)
  }

  func testDescription() {
    XCTAssertEqual(AnyValue.nil.description, "nil")
    XCTAssertEqual(AnyValue.bool(true).description, "true")
    XCTAssertEqual(AnyValue.int8(123).description, "123")
    XCTAssertEqual(AnyValue.int16(123).description, "123")
    XCTAssertEqual(AnyValue.int32(123).description, "123")
    XCTAssertEqual(AnyValue.int64(123).description, "123")
    XCTAssertEqual(AnyValue.uint8(123).description, "123")
    XCTAssertEqual(AnyValue.uint16(123).description, "123")
    XCTAssertEqual(AnyValue.uint32(123).description, "123")
    XCTAssertEqual(AnyValue.uint64(123).description, "123")
    XCTAssertEqual(AnyValue.integer(123).description, "123")
    XCTAssertEqual(AnyValue.unsignedInteger(123).description, "123")
    XCTAssertEqual(AnyValue.float16(1.5).description, "1.5")
    XCTAssertEqual(AnyValue.float(1.5).description, "1.5")
    XCTAssertEqual(AnyValue.double(1.5).description, "1.5")
    XCTAssertEqual(AnyValue.decimal(123.45).description, "123.45")
    XCTAssertEqual(AnyValue.string("test").description, "test")
    let date = Date()
    XCTAssertEqual(
      AnyValue.date(date).description,
      ZonedDate(date: date, timeZone: .utc).iso8601EncodedString()
    )
    XCTAssertEqual(AnyValue.data(Data([1, 2, 3, 4, 5])).description, "5 bytes")
    let uuid = UUID()
    XCTAssertEqual(
      AnyValue.uuid(uuid).description,
      uuid.uuidString
    )
    let url = URL(string: "https://example.com/some/thing")!
    XCTAssertEqual(
      AnyValue.url(url).description,
      url.absoluteString
    )
    XCTAssertEqual(AnyValue.array([1, 2, 3, 4, 5]).description, "[1, 2, 3, 4, 5]")
    XCTAssertEqual(
      AnyValue.dictionary(["a": 1, "b": 2, "c": 3, "d": 4, "e": 5]).description,
      "[a: 1, b: 2, c: 3, d: 4, e: 5]"
    )
  }

  func testWrapped() {
    XCTAssertEqual(try AnyValue.wrapped(nil), .nil)
    XCTAssertEqual(try AnyValue.wrapped("test"), .string("test"))
    XCTAssertEqual(try AnyValue.wrapped(true), .bool(true))
    XCTAssertEqual(try AnyValue.wrapped(Int.max), .int(Int.max))
    XCTAssertEqual(try AnyValue.wrapped(Int.min), .int(Int.min))
    XCTAssertEqual(try AnyValue.wrapped(UInt.max), .uint(UInt.max))
    XCTAssertEqual(try AnyValue.wrapped(UInt.min), .uint(UInt.min))
    XCTAssertEqual(try AnyValue.wrapped(Int8.max), .int8(Int8.max))
    XCTAssertEqual(try AnyValue.wrapped(Int8.min), .int8(Int8.min))
    XCTAssertEqual(try AnyValue.wrapped(Int16.max), .int16(Int16.max))
    XCTAssertEqual(try AnyValue.wrapped(Int16.min), .int16(Int16.min))
    XCTAssertEqual(try AnyValue.wrapped(Int32.max), .int32(Int32.max))
    XCTAssertEqual(try AnyValue.wrapped(Int32.min), .int32(Int32.min))
    XCTAssertEqual(try AnyValue.wrapped(Int64.max), .int64(Int64.max))
    XCTAssertEqual(try AnyValue.wrapped(Int64.min), .int64(Int64.min))
    XCTAssertEqual(try AnyValue.wrapped(UInt8.max), .uint8(UInt8.max))
    XCTAssertEqual(try AnyValue.wrapped(UInt8.min), .uint8(UInt8.min))
    XCTAssertEqual(try AnyValue.wrapped(UInt16.max), .uint16(UInt16.max))
    XCTAssertEqual(try AnyValue.wrapped(UInt16.min), .uint16(UInt16.min))
    XCTAssertEqual(try AnyValue.wrapped(UInt32.max), .uint32(UInt32.max))
    XCTAssertEqual(try AnyValue.wrapped(UInt32.min), .uint32(UInt32.min))
    XCTAssertEqual(try AnyValue.wrapped(UInt64.max), .uint64(UInt64.max))
    XCTAssertEqual(try AnyValue.wrapped(UInt64.min), .uint64(UInt64.min))
    XCTAssertEqual(try AnyValue.wrapped(BigInt(1)), .integer(1))
    XCTAssertEqual(try AnyValue.wrapped(BigInt(-1)), .integer(-1))
    XCTAssertEqual(try AnyValue.wrapped(BigUInt(1)), .unsignedInteger(1))
    XCTAssertEqual(try AnyValue.wrapped(Float16(1.5)), .float16(1.5))
    XCTAssertEqual(try AnyValue.wrapped(Float(1.5)), .float(1.5))
    XCTAssertEqual(try AnyValue.wrapped(Double(1.5)), .double(1.5))
    XCTAssertEqual(try AnyValue.wrapped(Decimal(1.23)), .decimal(1.23))
    XCTAssertEqual(try AnyValue.wrapped(Data([1, 2, 3])), .data(Data([1, 2, 3])))
    let url = URL(string: "https://example.com")!
    XCTAssertEqual(try AnyValue.wrapped(url), .url(url))
    let uuid = UUID()
    XCTAssertEqual(try AnyValue.wrapped(uuid), .uuid(uuid))
    let date = Date()
    XCTAssertEqual(try AnyValue.wrapped(date), .date(date))
    XCTAssertEqual(try AnyValue.wrapped([1, "test", true]), .array([1, "test", true]))

    // Unorderd dictionaries
    XCTAssertEqual(
      try AnyValue.wrapped(["a": 1, "b": 2, "c": 3])
        .dictionaryValue.map { val in Dictionary(uniqueKeysWithValues: val.map { ($0, $1) }) },
      [.string("a"): .int(1), .string("b"): .int(2), .string("c"): .int(3)]
    )
    XCTAssertEqual(
      try AnyValue.wrapped([1: "a", 2: "b", 3: "c"])
        .dictionaryValue.map { val in Dictionary(uniqueKeysWithValues: val.map { ($0, $1) }) },
      [.int(1): .string("a"), .int(2): .string("b"), .int(3): .string("c")]
    )
    XCTAssertEqual(try AnyValue.wrapped(["a": 1, "b": "test", "c": true] as OrderedDictionary),
                   .dictionary(["a": 1, "b": "test", "c": true]))
    XCTAssertEqual(try AnyValue.wrapped([1: 1, 2: "test", 3: true] as OrderedDictionary),
                   .dictionary([1: 1, 2: "test", 3: true]))

    // Passthrough
    XCTAssertEqual(try AnyValue.wrapped(AnyValue.bool(true)), .bool(true))
    XCTAssertEqual(try AnyValue.wrapped([1, 2, 3] as AnyValue.AnyArray), .array([1, 2, 3]))
    XCTAssertEqual(try AnyValue.wrapped([1: "a", 2: "b", 3: "c"] as AnyValue.AnyDictionary), .dictionary([1: "a", 2: "b", 3: "c"]))
  }

  func testUnwrapped() throws {
    XCTAssertNil(AnyValue.nil.unwrapped)
    XCTAssertEqual(AnyValue.bool(true).unwrapped as? Bool, true)
    XCTAssertEqual(AnyValue.string("test").unwrapped as? String, "test")
    XCTAssertEqual(AnyValue.int8(123).unwrapped as? Int8, 123)
    XCTAssertEqual(AnyValue.int16(123).unwrapped as? Int16, 123)
    XCTAssertEqual(AnyValue.int32(123).unwrapped as? Int32, 123)
    XCTAssertEqual(AnyValue.int64(123).unwrapped as? Int64, 123)
    XCTAssertEqual(AnyValue.uint8(123).unwrapped as? UInt8, 123)
    XCTAssertEqual(AnyValue.uint16(123).unwrapped as? UInt16, 123)
    XCTAssertEqual(AnyValue.uint32(123).unwrapped as? UInt32, 123)
    XCTAssertEqual(AnyValue.uint64(123).unwrapped as? UInt64, 123)
    XCTAssertEqual(AnyValue.integer(123).unwrapped as? BigInt, 123)
    XCTAssertEqual(AnyValue.unsignedInteger(123).unwrapped as? BigUInt, 123)
    XCTAssertEqual(AnyValue.float16(1.5).unwrapped as? Float16, 1.5)
    XCTAssertEqual(AnyValue.float(1.5).unwrapped as? Float, 1.5)
    XCTAssertEqual(AnyValue.double(1.5).unwrapped as? Double, 1.5)
    XCTAssertEqual(AnyValue.decimal(1.5).unwrapped as? Decimal, 1.5)
    XCTAssertEqual(AnyValue.data(Data([1, 2, 3])).unwrapped as? Data, Data([1, 2, 3]))
    let url = URL(string: "http://example.com")!
    XCTAssertEqual(AnyValue.url(url).unwrapped as? URL, url)
    let uuid = UUID()
    XCTAssertEqual(AnyValue.uuid(uuid).unwrapped as? UUID, uuid)
    let date = Date()
    XCTAssertEqual(AnyValue.date(date).unwrapped as? Date, date)
    XCTAssertEqual(AnyValue.array([1, 2, 3]).unwrapped as? [Int64], [1, 2, 3])
    XCTAssertEqual(
      AnyValue.dictionary(["a": 1, "b": 2, "c": 3]).unwrapped as? [String: Int64],
      ["a": 1, "b": 2, "c": 3]
    )
  }

  func testEncodable() throws {
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.nil), #"null"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.string("test")), #""test""#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.bool(true)), #"true"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int8(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int8(-123)), #"-123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int16(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int16(-123)), #"-123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int32(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int32(-123)), #"-123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int64(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.int64(-123)), #"-123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.integer(123)), #"["+",123]"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.integer(-123)), #"["-",123]"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.uint8(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.uint16(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.uint32(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.uint64(123)), #"123"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.unsignedInteger(123)), #"["+",123]"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.float16(1.5)), #"1.5"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.float(1.5)), #"1.5"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.double(1.5)), #"1.5"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.decimal(1.5)), #"1.5"#)
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.data(Data([1, 2, 3]))), #""AQID""#)

    let url = URL(string: "https://example.com")!
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.url(url)), #""https:\/\/example.com""#)

    let uuid = UUID()
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.uuid(uuid)), #""\#(uuid.uuidString)""#)

    let date = Date().truncatedToSecs
    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.date(date)), #"\#(Int64(date.timeIntervalSinceReferenceDate))"#)

    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.array([1, 2, 3])), #"[1,2,3]"#)

    XCTAssertEqual(try JSONEncoder().encodeString(AnyValue.dictionary(["a": 1, "b": 2, "c": 3])), #"["a",1,"b",2,"c",3]"#)
  }

  func testDecodable() throws {
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"null"#), .nil)
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"true"#), .bool(true))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"123"#), .int(123))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"-123"#), .int(-123))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"\#(Int64.max)"#), .int64(Int64.max))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"\#(Int64.min)"#), .int64(Int64.min))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"\#(UInt64.max)"#), .uint64(UInt64.max))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"["+",123]"#), .integer(123))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"["-",123]"#), .integer(-123))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"1.5"#), .double(1.5))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #""test""#), .string("test"))
    XCTAssertEqual(try JSONDecoder().decodeString(AnyValue.self, from: #"[1,2,3]"#), .array([1, 2, 3]))
    XCTAssertEqual(
      try JSONDecoder().decodeString(AnyValue.self, from: #"{"a":1,"b":2,"c":3}"#).dictionaryValue?.unordered,
      AnyValue.dictionary(["a": 1, "b": 2, "c": 3]).dictionaryValue?.unordered
    )
  }

  func testRoundtripOrder() throws {

    struct TestValue: Codable, Equatable {
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
      var f16: AnyValue = .float16(1.234)
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
    }

    let srcValue = TestValue()

    let tree = try AnyValue.Encoder.default.encodeTree(srcValue)

    XCTAssertEqual(tree.nil, srcValue.nil)
    XCTAssertEqual(tree.bool, srcValue.bool)
    XCTAssertEqual(tree.string, srcValue.string)
    XCTAssertEqual(tree.pi8, srcValue.pi8)
    XCTAssertEqual(tree.pi16, srcValue.pi16)
    XCTAssertEqual(tree.pi32, srcValue.pi32)
    XCTAssertEqual(tree.pi64, srcValue.pi64)
    XCTAssertEqual(tree.ni8, srcValue.ni8)
    XCTAssertEqual(tree.ni16, srcValue.ni16)
    XCTAssertEqual(tree.ni32, srcValue.ni32)
    XCTAssertEqual(tree.ni64, srcValue.ni64)
    XCTAssertEqual(tree.u8, srcValue.u8)
    XCTAssertEqual(tree.u16, srcValue.u16)
    XCTAssertEqual(tree.u32, srcValue.u32)
    XCTAssertEqual(tree.u64, srcValue.u64)
    XCTAssertEqual(tree.pint, srcValue.pint)
    XCTAssertEqual(tree.nint, srcValue.nint)
    XCTAssertEqual(tree.uint, srcValue.uint)
    XCTAssertEqual(tree.f16, srcValue.f16)
    XCTAssertEqual(tree.f32, srcValue.f32)
    XCTAssertEqual(tree.f64, srcValue.f64)
    XCTAssertEqual(tree.pdec, srcValue.pdec)
    XCTAssertEqual(tree.ndec, srcValue.ndec)
    XCTAssertEqual(tree.data, srcValue.data)
    XCTAssertEqual(tree.url, srcValue.url)
    XCTAssertEqual(tree.uuid, srcValue.uuid)
    XCTAssertEqual(tree.date, srcValue.date)
    XCTAssertEqual(tree.array, srcValue.array)
    XCTAssertEqual(tree.object, srcValue.object)

    let dstValue = try AnyValue.Decoder.default.decodeTree(TestValue.self, from: tree)

    XCTAssertEqual(dstValue.nil, srcValue.nil)
    XCTAssertEqual(dstValue.bool, srcValue.bool)
    XCTAssertEqual(dstValue.string, srcValue.string)
    XCTAssertEqual(dstValue.pi8, srcValue.pi8)
    XCTAssertEqual(dstValue.pi16, srcValue.pi16)
    XCTAssertEqual(dstValue.pi32, srcValue.pi32)
    XCTAssertEqual(dstValue.pi64, srcValue.pi64)
    XCTAssertEqual(dstValue.ni8, srcValue.ni8)
    XCTAssertEqual(dstValue.ni16, srcValue.ni16)
    XCTAssertEqual(dstValue.ni32, srcValue.ni32)
    XCTAssertEqual(dstValue.ni64, srcValue.ni64)
    XCTAssertEqual(dstValue.u8, srcValue.u8)
    XCTAssertEqual(dstValue.u16, srcValue.u16)
    XCTAssertEqual(dstValue.u32, srcValue.u32)
    XCTAssertEqual(dstValue.u64, srcValue.u64)
    XCTAssertEqual(dstValue.pint, srcValue.pint)
    XCTAssertEqual(dstValue.nint, srcValue.nint)
    XCTAssertEqual(dstValue.uint, srcValue.uint)
    XCTAssertEqual(dstValue.f16, srcValue.f16)
    XCTAssertEqual(dstValue.f32, srcValue.f32)
    XCTAssertEqual(dstValue.f64, srcValue.f64)
    XCTAssertEqual(dstValue.pdec, srcValue.pdec)
    XCTAssertEqual(dstValue.ndec, srcValue.ndec)
    XCTAssertEqual(dstValue.data, srcValue.data)
    XCTAssertEqual(dstValue.url, srcValue.url)
    XCTAssertEqual(dstValue.uuid, srcValue.uuid)
    XCTAssertEqual(dstValue.date, srcValue.date)
    XCTAssertEqual(dstValue.array, srcValue.array)
    XCTAssertEqual(dstValue.object, srcValue.object)
  }

}


extension JSONEncoder {

  func encodeString<E: Encodable>(_ value: E?) throws -> String {
    return String(data: try encode(value), encoding: .utf8)!
  }

}

extension JSONDecoder {

  func decodeString<D: Decodable>(_ type: D.Type, from string: String) throws -> D {
    return try decode(type, from: string.data(using: .utf8)!)
  }

}

extension OrderedDictionary where Key == AnyValue, Value == AnyValue {

  var unordered: [AnyValue: AnyValue] {
    return Dictionary(uniqueKeysWithValues: self.map { ($0, $1) })
  }

}
