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

  let intNumericValues: AnyValue = [
    .int8(1),
    .int16(2),
    .int32(3),
    .int64(4),
    .uint8(5),
    .uint16(6),
    .uint32(7),
    .uint64(8),
    .float16(9),
    .float(10),
    .double(11),
    .decimal(12),
    .integer(13),
    .unsignedInteger(14),
  ]

  func testDecodeBoolFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Bool.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(Int.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeIntOverflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int64.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntUnderflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int64.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int8.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(Int8.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeInt8Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int8.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int8.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int8.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int8.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int16.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(Int16.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeInt16Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int16.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int16.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int16.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int16.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int32.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(Int32.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeInt32Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int32.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int32.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int32.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int32.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int64.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(Int64.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeInt64Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int64.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int64.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int64.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(Int64.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUIntFromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(UInt.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeUIntOverflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntUnderflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt8.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(UInt8.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeUInt8Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt8.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt8.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt8.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt8.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt16.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(UInt16.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeUInt16Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt16.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt16.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt16.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt16.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt32.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(UInt32.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeUInt32Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt32.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt32.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt32.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt32.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt64.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index = 1
        while !container.isAtEnd {
          let value = try container.decode(UInt64.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeUInt64Overflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt64.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt64.max) + 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64Underflow() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt64.self)
      }
    }

    XCTAssertThrowsError(
      try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([.integer(BigInt(UInt64.min) - 1)]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloat16FromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float16.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat16FromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index: Float16 = 1
        while !container.isAtEnd {
          let value = try container.decode(Float16.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeFloatFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloatFromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index: Float = 1
        while !container.isAtEnd {
          let value = try container.decode(Float.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeDoubleFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Double.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDoubleFromNumerics() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var index: Double = 1
        while !container.isAtEnd {
          let value = try container.decode(Double.self)
          XCTAssert(value == index)
          index += 1
        }
      }
    }

    XCTAssertNoThrow(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: intNumericValues))
  }

  func testDecodeStringFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(String.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUIDFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UUID.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURLFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(URL.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDateFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Date.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDataFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Data.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimalFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Decimal.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigIntFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigInt.self)
      }
    }

    XCTAssertThrowsError(try AnyValue.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUIntFromNullItem() throws {

    struct TestValue: Decodable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigUInt.self)
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
