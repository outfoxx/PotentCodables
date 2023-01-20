//
//  AnyValueCoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import OrderedCollections
import Foundation
import PotentCodables
import XCTest


class AnyValueCoderTests: XCTestCase {

  func testDecodeBoolFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Bool.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int8.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int32.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int64.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt8.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt32.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt64.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloatFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDoubleFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Double.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeStringFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(String.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUIDFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UUID.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURLFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(URL.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDateFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Date.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDataFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Data.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimalFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Decimal.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigUInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testCoding() throws {

    struct TestValue: Codable, Equatable {
      var bool: Bool = true
      var string: String = "test"
      var int: Int = 123
      var int8: Int8 = 123
      var int16: Int16 = 123
      var int32: Int32 = 123
      var int64: Int64 = 123
      var uint: UInt = 123
      var uint8: UInt8 = 123
      var uint16: UInt16 = 123
      var uint32: UInt32 = 123
      var uint64: UInt64 = 123
      var integer: BigInt = 123
      var unsignedInteger: BigUInt = 123
      var float16: Float16 = 1.5
      var float: Float = 1.5
      var double: Double = 1.5
      var decimal: Decimal = 1.5
      var data: Data = Data([1, 2, 3])
      var url: URL = URL(string: "https://example.com")!
      var uuid: UUID = UUID()
      var date: Date = Date()
      var array: [Int] = [1, 2, 3]
      var dictionary: OrderedDictionary<String, Int> = ["a": 1, "b": 2, "c": 3]
    }
    let value = TestValue()

    let tree: AnyValue = [
      "bool": true,
      "string": "test",
      "int": .int(123),
      "int8": .int8(123),
      "int16": .int16(123),
      "int32": .int32(123),
      "int64": .int64(123),
      "uint": .uint(123),
      "uint8": .uint8(123),
      "uint16": .uint16(123),
      "uint32": .uint32(123),
      "uint64": .uint64(123),
      "integer": .integer(123),
      "unsignedInteger": .unsignedInteger(123),
      "float16": .float16(1.5),
      "float": .float(1.5),
      "double": .double(1.5),
      "decimal": .decimal(1.5),
      "data": .data(Data([1, 2, 3])),
      "url": .url(value.url),
      "uuid": .uuid(value.uuid),
      "date": .date(value.date),
      "array": .array([1, 2, 3]),
      "dictionary": .dictionary(["a": 1, "b": 2, "c": 3]),
    ]

    XCTAssertEqual(try AnyValue.Encoder.default.encodeTree(value), tree)
    XCTAssertEqual(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: tree), value)
  }

}
