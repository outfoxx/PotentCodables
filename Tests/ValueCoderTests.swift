//
//  ValueCoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables
import PotentJSON
import XCTest


class ValueCoderTests: XCTestCase {

  func testUnkeyedContainerDecodeFromEmptyNil() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decodeNil()
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyBool() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Bool.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsBool() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Bool.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyInt() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsInt() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyInt8() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int8.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsInt8() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int8.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyInt16() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int16.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsInt16() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int16.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyInt32() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int32.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsInt32() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int32.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyInt64() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int64.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsInt64() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Int64.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyUInt() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsUInt() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyUInt8() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt8.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsUInt8() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt8.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyUInt16() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt16.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsUInt16() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt16.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyUInt32() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt32.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsUInt32() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt32.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyUInt64() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt64.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsUInt64() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(UInt64.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyFloat() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Float.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsFloat() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Float.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyDouble() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Double.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsDouble() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Double.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyString() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(String.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsString() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(String.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyCodable() throws {

    struct Sub: Codable {
      var bool: Bool
    }

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Sub.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsCodable() throws {

    struct Sub: Codable {
      var bool: Bool
    }

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.decode(Sub.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyNestedKeyed() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.nestedContainer(keyedBy: AnyCodingKey.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsNestedKeyed() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.nestedContainer(keyedBy: AnyCodingKey.self)
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyNestedUnkeyed() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.nestedUnkeyedContainer()
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecoderNilAsNestedUnkeyed() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.nestedUnkeyedContainer()
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testUnkeyedContainerDecodeFromEmptyNestedSuper() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var decoder = try decoder.unkeyedContainer()
        _ = try decoder.superDecoder()
      }

      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testKeyedContainerDecoderNilAsNestedKeyed() throws {

    struct TestValue: Codable {
      enum CodingKeys: CodingKey {
        case nested
      }
      init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)
        _ = try decoder.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .nested)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .object([:]))) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testKeyedContainerDecoderNilAsNestedUnkeyed() throws {

    struct TestValue: Codable {
      enum CodingKeys: CodingKey {
        case nested
      }
      init(from decoder: Decoder) throws {
        let decoder = try decoder.container(keyedBy: CodingKeys.self)
        _ = try decoder.nestedUnkeyedContainer(forKey: .nested)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .object([:]))) { error in
      AssertDecodingKeyNotFound(error)
    }
  }

  func testUnkeyedContainer() throws {

    struct TestValue: Codable, Equatable {
      var bool: Bool
      var string: String
      var int: Int
      var int8: Int8
      var int16: Int16
      var int32: Int32
      var int64: Int64
      var uint: UInt
      var uint8: UInt8
      var uint16: UInt16
      var uint32: UInt32
      var uint64: UInt64
      var float: Float
      var double: Double


      init() {
        self.bool = true
        self.string = "test"
        self.int = 1
        self.int8 = 2
        self.int16 = 3
        self.int32 = 4
        self.int64 = 5
        self.uint = 6
        self.uint8 = 7
        self.uint16 = 8
        self.uint32 = 9
        self.uint64 = 10
        self.float = 11.0
        self.double = 12.0
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decodeNil()
        bool = try container.decode(Bool.self)
        string = try container.decode(String.self)
        int = try container.decode(Int.self)
        int8 = try container.decode(Int8.self)
        int16 = try container.decode(Int16.self)
        int32 = try container.decode(Int32.self)
        int64 = try container.decode(Int64.self)
        uint = try container.decode(UInt.self)
        uint8 = try container.decode(UInt8.self)
        uint16 = try container.decode(UInt16.self)
        uint32 = try container.decode(UInt32.self)
        uint64 = try container.decode(UInt64.self)
        float = try container.decode(Float.self)
        double = try container.decode(Double.self)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encodeNil()
        try container.encode(bool)
        try container.encode(string)
        try container.encode(int)
        try container.encode(int8)
        try container.encode(int16)
        try container.encode(int32)
        try container.encode(int64)
        try container.encode(uint)
        try container.encode(uint8)
        try container.encode(uint16)
        try container.encode(uint32)
        try container.encode(uint64)
        try container.encode(float)
        try container.encode(double)
      }
    }

    let value = TestValue()
    let tree: JSON = [
      nil,
      true,
      "test",
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11.0,
      12.0,
    ]

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: tree), value)
  }

  func testSuperContainerForKeyedContainer() throws {

    class BaseValue: Codable {

      var id: String

      init(id: String) {
        self.id = id
      }

      enum CodingKeys: CodingKey {
        case id
      }

      required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
      }

    }

    class TestValue: BaseValue {

      var firstName: String
      var lastName: String

      init(id: String, firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        super.init(id: id)
      }

      enum CodingKeys: CodingKey {
        case firstName
        case lastName
      }

      required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        try super.init(from: try container.superDecoder())
      }

      override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try super.encode(to: container.superEncoder())
      }

    }

    let value = TestValue(id: "1", firstName: "Some", lastName: "Guy")
    let tree = JSON.object([
      "firstName": "Some",
      "lastName": "Guy",
      "super": [
        "id": "1",
      ]
    ])

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)

    let testValue = try JSON.Decoder.default.decodeTree(TestValue.self, from: tree)
    XCTAssertEqual(testValue.id, value.id)
    XCTAssertEqual(testValue.firstName, value.firstName)
    XCTAssertEqual(testValue.lastName, value.lastName)
  }

  func testSuperContainerForKeyedContainerWithCustomKey() throws {

    class BaseValue: Codable {

      var id: String

      init(id: String) {
        self.id = id
      }

      enum CodingKeys: CodingKey {
        case id
      }

      required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
      }

    }

    class TestValue: BaseValue {

      var firstName: String
      var lastName: String

      init(id: String, firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        super.init(id: id)
      }

      enum CodingKeys: CodingKey {
        case firstName
        case lastName
        case base
      }

      required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        try super.init(from: try container.superDecoder(forKey: .base))
      }

      override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try super.encode(to: container.superEncoder(forKey: .base))
      }

    }

    let value = TestValue(id: "1", firstName: "Some", lastName: "Guy")
    let tree = JSON.object([
      "firstName": "Some",
      "lastName": "Guy",
      "base": [
        "id": "1",
      ]
    ])

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)

    let testValue = try JSON.Decoder.default.decodeTree(TestValue.self, from: tree)
    XCTAssertEqual(testValue.id, value.id)
    XCTAssertEqual(testValue.firstName, value.firstName)
    XCTAssertEqual(testValue.lastName, value.lastName)
  }

  func testSuperContainerForUnkeyedContainer() throws {

    class BaseValue: Codable {

      var id: String

      init(id: String) {
        self.id = id
      }

      enum CodingKeys: CodingKey {
        case id
      }

      required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.id = try container.decode(String.self)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.id)
      }

    }

    class TestValue: BaseValue {

      var firstName: String
      var lastName: String

      init(id: String, firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        super.init(id: id)
      }

      enum CodingKeys: CodingKey {
        case firstName
        case lastName
      }

      required init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        firstName = try container.decode(String.self)
        lastName = try container.decode(String.self)
        try super.init(from: try container.superDecoder())
      }

      override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(firstName)
        try container.encode(lastName)
        try super.encode(to: container.superEncoder())
      }

    }

    let value = TestValue(id: "1", firstName: "Some", lastName: "Guy")
    let tree = JSON.array([
      "Some",
      "Guy",
      [
        "1",
      ]
    ])

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)

    let testValue = try JSON.Decoder.default.decodeTree(TestValue.self, from: tree)
    XCTAssertEqual(testValue.id, value.id)
    XCTAssertEqual(testValue.firstName, value.firstName)
    XCTAssertEqual(testValue.lastName, value.lastName)
  }

  func testNestedContainersForKeyedContainer() {

    struct TestValue: Codable, Equatable {

      var id: String
      var names: [String]
      var socialNames: [String]

      init(id: String, names: [String], socialNames: [String]) {
        self.id = id
        self.names = names
        self.socialNames = socialNames
      }

      enum CodingKeys: CodingKey {
        case id
        case name
        case socialNames
      }

      enum NameCodingKeys: CodingKey {
        case first
        case last
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)

        self.names = []
        let nameContainer = try container.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        self.names.append(try nameContainer.decode(String.self, forKey: .first))
        self.names.append(try nameContainer.decode(String.self, forKey: .last))

        self.socialNames = []
        var socialNamesContainer = try container.nestedUnkeyedContainer(forKey: .socialNames)
        while !socialNamesContainer.isAtEnd {
          self.socialNames.append(try socialNamesContainer.decode(String.self))
        }
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)

        var nameContainer = container.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
        try nameContainer.encode(names.first!, forKey: .first)
        try nameContainer.encode(names.last!, forKey: .last)

        var socialNamesContainer = container.nestedUnkeyedContainer(forKey: .socialNames)
        try socialNamesContainer.encode(contentsOf: socialNames)
      }
    }

    let value = TestValue(id: "1", names: ["Some", "Guy"], socialNames: ["@some_guy"])
    let tree = JSON.object([
      "id": "1",
      "name": .object([
        "first": "Some",
        "last": "Guy",
      ]),
      "socialNames": .array([
        "@some_guy"
      ]),
    ])

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: tree), value)
  }

  func testNestedContainersForUnkeyedContainer() {

    struct TestValue: Codable, Equatable {

      var id: String
      var names: [String]
      var socialNames: [String]

      init(id: String, names: [String], socialNames: [String]) {
        self.id = id
        self.names = names
        self.socialNames = socialNames
      }

      enum NameCodingKeys: CodingKey {
        case first
        case last
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.id = try container.decode(String.self)

        self.names = []
        let nameContainer = try container.nestedContainer(keyedBy: NameCodingKeys.self)
        self.names.append(try nameContainer.decode(String.self, forKey: .first))
        self.names.append(try nameContainer.decode(String.self, forKey: .last))

        self.socialNames = []
        var socialNamesContainer = try container.nestedUnkeyedContainer()
        while !socialNamesContainer.isAtEnd {
          self.socialNames.append(try socialNamesContainer.decode(String.self))
        }
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.id)

        var nameContainer = container.nestedContainer(keyedBy: NameCodingKeys.self)
        try nameContainer.encode(names.first!, forKey: .first)
        try nameContainer.encode(names.last!, forKey: .last)

        var socialNamesContainer = container.nestedUnkeyedContainer()
        try socialNamesContainer.encode(contentsOf: socialNames)
      }
    }

    let value = TestValue(id: "1", names: ["Some", "Guy"], socialNames: ["@some_guy"])
    let tree = JSON.array([
      "1",
      .object([
        "first": "Some",
        "last": "Guy",
      ]),
      .array([
        "@some_guy"
      ]),
    ])

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(value), tree)
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: tree), value)
  }

}
