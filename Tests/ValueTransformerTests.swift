//
//  ValueTransformerTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
@testable import PotentJSON
import XCTest


class ValueTransformerTests: XCTestCase {

  func testTopLevel() throws {

    struct Uncodable: Equatable {
      var int: Int
    }

    enum UncodableTransformer: ValueCodingTransformer {
      case instance

      func decode(_ value: Data) throws -> Uncodable {
        Uncodable(int: try JSONDecoder.default.decode(Int.self, from: value))
      }
      func encode(_ value: Uncodable) throws -> Data {
        return try JSONEncoder.default.encode(value.int)
      }
    }

    let encoded = Uncodable(int: 123)
    let data = try JSONEncoder.default.encode(encoded, using: UncodableTransformer.instance)
    let decoded = try JSONDecoder.default.decode(from: data, using: UncodableTransformer.instance)
    XCTAssertEqual(encoded, decoded)
  }

  func testKeyed() throws {

    let tree: JSON = [
      "trueValueBool": true,
      "falseValueBool": false,
      "trueValueInt": 1,
      "falseValueInt": 0,
      "trueValueInt8": 1,
      "falseValueInt8": 0,
      "trueValueInt16": 1,
      "falseValueInt16": 0,
      "trueValueInt32": 1,
      "falseValueInt32": 0,
      "trueValueInt64": 1,
      "falseValueInt64": 0,
      "trueValueUInt": 1,
      "falseValueUInt": 0,
      "trueValueUInt8": 1,
      "falseValueUInt8": 0,
      "trueValueUInt16": 1,
      "falseValueUInt16": 0,
      "trueValueUInt32": 1,
      "falseValueUInt32": 0,
      "trueValueUInt64": 1,
      "falseValueUInt64": 0,
      "trueValueFloat": 1.0,
      "falseValueFloat": 0.0,
      "trueValueDouble": 1.0,
      "falseValueDouble": 0.0,
      "trueValueString": "true",
      "falseValueString": "false",
      "trueValueStruct": true,
      "falseValueStruct": false,
      "someValueBool": true,
      "someValueInt": 1,
      "someValueInt8": 1,
      "someValueInt16": 1,
      "someValueInt32": 1,
      "someValueInt64": 1,
      "someValueUInt": 1,
      "someValueUInt8": 1,
      "someValueUInt16": 1,
      "someValueUInt32": 1,
      "someValueUInt64": 1,
      "someValueFloat": 1.0,
      "someValueDouble": 1.0,
      "someValueString": "true",
      "someValueStruct": true,
    ]

    let value = TestKeyed()

    XCTAssertEqual(
      try JSON.Encoder.default.encodeTree(value),
      tree
    )

    XCTAssertEqual(
      try JSON.Decoder.default.decodeTree(TestKeyed.self, from: tree),
      value
    )
  }

  func testUnkeyed() throws {

    let tree: JSON = [
      true, false, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1.0, 0.0, 1.0, 0.0, "true", "false",
      true, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1, nil, 1.0, nil, 1.0, nil, "true", nil,
    ]

    let value = TestUnkeyed()

    XCTAssertEqual(
      try JSON.Encoder.default.encodeTree(value),
      tree
    )

    XCTAssertEqual(
      try JSON.Decoder.default.decodeTree(TestUnkeyed.self, from: tree),
      value
    )
  }

  func testArrayBoolStoredInt() throws {

    struct TestValue: Codable, Equatable {
      var value: [Int]

      init(value: [Int]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: IntToBool())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: IntToBool())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [1, 0])), JSON.array([true, false]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([true, false])), TestValue(value: [1, 0]))
  }

  func testArrayIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int8>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int16>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int32>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int64>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayUIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayUInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt8>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayUInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt16>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayUInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt32>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayUInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt64>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1, 0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1, 0])), TestValue(value: [true, false]))
  }

  func testArrayFloatStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToFloat<Float>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToFloat<Float>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1.0, 0.0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1.0, 0.0])), TestValue(value: [true, false]))
  }

  func testArrayDoubleStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToFloat<Double>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToFloat<Double>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([1.0, 0.0]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([1.0, 0.0])), TestValue(value: [true, false]))
  }

  func testArrayStringStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToString())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToString())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array(["true", "false"]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array(["true", "false"])), TestValue(value: [true, false]))
  }

  func testArrayBoolValueStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: [Bool]

      init(value: [Bool]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToBoolValue())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToBoolValue())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: [true, false])), JSON.array([true, false]))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.array([true, false])), TestValue(value: [true, false]))
  }

  func testSetBoolStoredInt() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Int>

      init(value: Set<Int>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: IntToBool())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: IntToBool())
      }
    }

    let encoded = TestValue(value: [1, 0])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int8>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int16>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int32>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<Int64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<Int64>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetUIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetUInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt8>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetUInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt16>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetUInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt32>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetUInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToInt<UInt64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToInt<UInt64>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetFloatStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToFloat<Float>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToFloat<Float>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetDoubleStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToFloat<Double>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToFloat<Double>())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetStringStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToString())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToString())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSetBoolValueStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Set<Bool>

      init(value: Set<Bool>) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        value = try container.decodeContents(using: BoolToBoolValue())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.unkeyedContainer()
        try contaier.encode(contentsOf: value, using: BoolToBoolValue())
      }
    }

    let encoded = TestValue(value: [true, false])
    let data = try JSON.Encoder.default.encode(encoded)
    let decoded = try JSON.Decoder.default.decode(TestValue.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSingleBoolStoredInt() throws {

    struct TestValue: Codable, Equatable {
      var value: Int

      init(value: Int) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: IntToBool())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: IntToBool())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: 1)), JSON.bool(true))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: 0)), JSON.bool(false))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.bool(true)), TestValue(value: 1))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.bool(false)), TestValue(value: 0))
  }

  func testSingleIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<Int>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<Int>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<Int8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<Int8>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<Int16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<Int16>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<Int32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<Int32>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<Int64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<Int64>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleUIntStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<UInt>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<UInt>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleUInt8StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<UInt8>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<UInt8>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleUInt16StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<UInt16>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<UInt16>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleUInt32StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<UInt32>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<UInt32>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleUInt64StoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToInt<UInt64>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToInt<UInt64>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0)), TestValue(value: false))
  }

  func testSingleStringStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToString())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToString())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.string("true"))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.string("false"))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.string("true")), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.string("false")), TestValue(value: false))
  }

  func testSingleFloatStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToFloat<Float>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToFloat<Float>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1.0))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0.0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1.0)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0.0)), TestValue(value: false))
  }

  func testSingleDoubleStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToFloat<Double>())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToFloat<Double>())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.number(1.0))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.number(0.0))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(1.0)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.number(0.0)), TestValue(value: false))
  }

  func testSingleBoolValueStoredBool() throws {

    struct TestValue: Codable, Equatable {
      var value: Bool

      init(value: Bool) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(using: BoolToBoolValue())
      }

      func encode(to encoder: Encoder) throws {
        var contaier = encoder.singleValueContainer()
        try contaier.encode(value, using: BoolToBoolValue())
      }
    }

    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: true)), JSON.bool(true))
    XCTAssertEqual(try JSON.Encoder.default.encodeTree(TestValue(value: false)), JSON.bool(false))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.bool(true)), TestValue(value: true))
    XCTAssertEqual(try JSON.Decoder.default.decodeTree(TestValue.self, from: JSON.bool(false)), TestValue(value: false))
  }

}


struct TestKeyed: Codable, Equatable {

  var trueValueBool: Int = 1
  var falseValueBool: Int = 0

  var trueValueInt: Bool = true
  var falseValueInt: Bool = false

  var trueValueInt8: Bool = true
  var falseValueInt8: Bool = false

  var trueValueInt16: Bool = true
  var falseValueInt16: Bool = false

  var trueValueInt32: Bool = true
  var falseValueInt32: Bool = false

  var trueValueInt64: Bool = true
  var falseValueInt64: Bool = false

  var trueValueUInt: Bool = true
  var falseValueUInt: Bool = false

  var trueValueUInt8: Bool = true
  var falseValueUInt8: Bool = false

  var trueValueUInt16: Bool = true
  var falseValueUInt16: Bool = false

  var trueValueUInt32: Bool = true
  var falseValueUInt32: Bool = false

  var trueValueUInt64: Bool = true
  var falseValueUInt64: Bool = false

  var trueValueFloat: Bool = true
  var falseValueFloat: Bool = false

  var trueValueDouble: Bool = true
  var falseValueDouble: Bool = false

  var trueValueString: Bool = true
  var falseValueString: Bool = false

  var trueValueStruct: Bool = true
  var falseValueStruct: Bool = false

  var someValueBool: Int? = 1
  var noneValueBool: Int?

  var someValueInt: Bool? = true
  var noneValueInt: Bool?

  var someValueInt8: Bool? = true
  var noneValueInt8: Bool?

  var someValueInt16: Bool? = true
  var noneValueInt16: Bool?

  var someValueInt32: Bool? = true
  var noneValueInt32: Bool?

  var someValueInt64: Bool? = true
  var noneValueInt64: Bool?

  var someValueUInt: Bool? = true
  var noneValueUInt: Bool?

  var someValueUInt8: Bool? = true
  var noneValueUInt8: Bool?

  var someValueUInt16: Bool? = true
  var noneValueUInt16: Bool?

  var someValueUInt32: Bool? = true
  var noneValueUInt32: Bool?

  var someValueUInt64: Bool? = true
  var noneValueUInt64: Bool?

  var someValueFloat: Bool? = true
  var noneValueFloat: Bool?

  var someValueDouble: Bool? = true
  var noneValueDouble: Bool?

  var someValueString: Bool? = true
  var noneValueString: Bool?

  var someValueStruct: Bool? = true
  var noneValueStruct: Bool?

  init() {}

  enum CodingKeys: CodingKey {
    case trueValueBool
    case falseValueBool
    case trueValueInt
    case falseValueInt
    case trueValueInt8
    case falseValueInt8
    case trueValueInt16
    case falseValueInt16
    case trueValueInt32
    case falseValueInt32
    case trueValueInt64
    case falseValueInt64
    case trueValueUInt
    case falseValueUInt
    case trueValueUInt8
    case falseValueUInt8
    case trueValueUInt16
    case falseValueUInt16
    case trueValueUInt32
    case falseValueUInt32
    case trueValueUInt64
    case falseValueUInt64
    case trueValueFloat
    case falseValueFloat
    case trueValueDouble
    case falseValueDouble
    case trueValueString
    case falseValueString
    case trueValueStruct
    case falseValueStruct
    case someValueBool
    case noneValueBool
    case someValueInt
    case noneValueInt
    case someValueInt8
    case noneValueInt8
    case someValueInt16
    case noneValueInt16
    case someValueInt32
    case noneValueInt32
    case someValueInt64
    case noneValueInt64
    case someValueUInt
    case noneValueUInt
    case someValueUInt8
    case noneValueUInt8
    case someValueUInt16
    case noneValueUInt16
    case someValueUInt32
    case noneValueUInt32
    case someValueUInt64
    case noneValueUInt64
    case someValueFloat
    case noneValueFloat
    case someValueDouble
    case noneValueDouble
    case someValueString
    case noneValueString
    case someValueStruct
    case noneValueStruct
  }

  init(from: Decoder) throws {
    let container = try from.container(keyedBy: Self.CodingKeys.self)

    trueValueBool = try container.decode(forKey: .trueValueBool, using: IntToBool())
    falseValueBool = try container.decode(forKey: .falseValueBool, using: IntToBool())

    trueValueInt = try container.decode(forKey: .trueValueInt, using: BoolToInt<Int>())
    falseValueInt = try container.decode(forKey: .falseValueInt, using: BoolToInt<Int>())
    trueValueInt8 = try container.decode(forKey: .trueValueInt8, using: BoolToInt<Int8>())
    falseValueInt8 = try container.decode(forKey: .falseValueInt8, using: BoolToInt<Int8>())
    trueValueInt16 = try container.decode(forKey: .trueValueInt16, using: BoolToInt<Int16>())
    falseValueInt16 = try container.decode(forKey: .falseValueInt16, using: BoolToInt<Int16>())
    trueValueInt32 = try container.decode(forKey: .trueValueInt32, using: BoolToInt<Int32>())
    falseValueInt32 = try container.decode(forKey: .falseValueInt32, using: BoolToInt<Int32>())
    trueValueInt64 = try container.decode(forKey: .trueValueInt64, using: BoolToInt<Int64>())
    falseValueInt64 = try container.decode(forKey: .falseValueInt64, using: BoolToInt<Int64>())
    trueValueUInt = try container.decode(forKey: .trueValueUInt, using: BoolToInt<UInt>())
    falseValueUInt = try container.decode(forKey: .falseValueUInt, using: BoolToInt<UInt>())
    trueValueUInt8 = try container.decode(forKey: .trueValueUInt8, using: BoolToInt<UInt8>())
    falseValueUInt8 = try container.decode(forKey: .falseValueUInt8, using: BoolToInt<UInt8>())
    trueValueUInt16 = try container.decode(forKey: .trueValueUInt16, using: BoolToInt<UInt16>())
    falseValueUInt16 = try container.decode(forKey: .falseValueUInt16, using: BoolToInt<UInt16>())
    trueValueUInt32 = try container.decode(forKey: .trueValueUInt32, using: BoolToInt<UInt32>())
    falseValueUInt32 = try container.decode(forKey: .falseValueUInt32, using: BoolToInt<UInt32>())
    trueValueUInt64 = try container.decode(forKey: .trueValueUInt64, using: BoolToInt<UInt64>())
    falseValueUInt64 = try container.decode(forKey: .falseValueUInt64, using: BoolToInt<UInt64>())

    trueValueFloat = try container.decode(forKey: .trueValueFloat, using: BoolToFloat<Float>())
    falseValueFloat = try container.decode(forKey: .falseValueFloat, using: BoolToFloat<Float>())
    trueValueDouble = try container.decode(forKey: .trueValueDouble, using: BoolToFloat<Double>())
    falseValueDouble = try container.decode(forKey: .falseValueDouble, using: BoolToFloat<Double>())

    trueValueString = try container.decode(forKey: .trueValueString, using: BoolToString())
    falseValueString = try container.decode(forKey: .falseValueString, using: BoolToString())

    trueValueStruct = try container.decode(forKey: .trueValueStruct, using: BoolToBoolValue())
    falseValueStruct = try container.decode(forKey: .falseValueStruct, using: BoolToBoolValue())

    someValueBool = try container.decodeIfPresent(forKey: .someValueBool, using: IntToBool())
    noneValueBool = try container.decodeIfPresent(forKey: .noneValueBool, using: IntToBool())

    someValueInt = try container.decodeIfPresent(forKey: .someValueInt, using: BoolToInt<Int>())
    noneValueInt = try container.decodeIfPresent(forKey: .noneValueInt, using: BoolToInt<Int>())
    someValueInt8 = try container.decodeIfPresent(forKey: .someValueInt8, using: BoolToInt<Int8>())
    noneValueInt8 = try container.decodeIfPresent(forKey: .noneValueInt8, using: BoolToInt<Int8>())
    someValueInt16 = try container.decodeIfPresent(forKey: .someValueInt16, using: BoolToInt<Int16>())
    noneValueInt16 = try container.decodeIfPresent(forKey: .noneValueInt16, using: BoolToInt<Int16>())
    someValueInt32 = try container.decodeIfPresent(forKey: .someValueInt32, using: BoolToInt<Int32>())
    noneValueInt32 = try container.decodeIfPresent(forKey: .noneValueInt32, using: BoolToInt<Int32>())
    someValueInt64 = try container.decodeIfPresent(forKey: .someValueInt64, using: BoolToInt<Int64>())
    noneValueInt64 = try container.decodeIfPresent(forKey: .noneValueInt64, using: BoolToInt<Int64>())
    someValueUInt = try container.decodeIfPresent(forKey: .someValueUInt, using: BoolToInt<UInt>())
    noneValueUInt = try container.decodeIfPresent(forKey: .noneValueUInt, using: BoolToInt<UInt>())
    someValueUInt8 = try container.decodeIfPresent(forKey: .someValueUInt8, using: BoolToInt<UInt8>())
    noneValueUInt8 = try container.decodeIfPresent(forKey: .noneValueUInt8, using: BoolToInt<UInt8>())
    someValueUInt16 = try container.decodeIfPresent(forKey: .someValueUInt16, using: BoolToInt<UInt16>())
    noneValueUInt16 = try container.decodeIfPresent(forKey: .noneValueUInt16, using: BoolToInt<UInt16>())
    someValueUInt32 = try container.decodeIfPresent(forKey: .someValueUInt32, using: BoolToInt<UInt32>())
    noneValueUInt32 = try container.decodeIfPresent(forKey: .noneValueUInt32, using: BoolToInt<UInt32>())
    someValueUInt64 = try container.decodeIfPresent(forKey: .someValueUInt64, using: BoolToInt<UInt64>())
    noneValueUInt64 = try container.decodeIfPresent(forKey: .noneValueUInt64, using: BoolToInt<UInt64>())

    someValueFloat = try container.decodeIfPresent(forKey: .someValueFloat, using: BoolToFloat<Float>())
    noneValueFloat = try container.decodeIfPresent(forKey: .noneValueFloat, using: BoolToFloat<Float>())
    someValueDouble = try container.decodeIfPresent(forKey: .someValueDouble, using: BoolToFloat<Double>())
    noneValueDouble = try container.decodeIfPresent(forKey: .noneValueDouble, using: BoolToFloat<Double>())

    someValueString = try container.decodeIfPresent(forKey: .someValueString, using: BoolToString())
    noneValueString = try container.decodeIfPresent(forKey: .noneValueString, using: BoolToString())

    someValueStruct = try container.decodeIfPresent(forKey: .someValueStruct, using: BoolToBoolValue())
    noneValueStruct = try container.decodeIfPresent(forKey: .noneValueStruct, using: BoolToBoolValue())

  }

  func encode(to: Encoder) throws {
    var container = to.container(keyedBy: Self.CodingKeys.self)

    try container.encode(trueValueBool, forKey: .trueValueBool, using: IntToBool())
    try container.encode(falseValueBool, forKey: .falseValueBool, using: IntToBool())

    try container.encode(trueValueInt, forKey: .trueValueInt, using: BoolToInt<Int>())
    try container.encode(falseValueInt, forKey: .falseValueInt, using: BoolToInt<Int>())
    try container.encode(trueValueInt8, forKey: .trueValueInt8, using: BoolToInt<Int8>())
    try container.encode(falseValueInt8, forKey: .falseValueInt8, using: BoolToInt<Int8>())
    try container.encode(trueValueInt16, forKey: .trueValueInt16, using: BoolToInt<Int16>())
    try container.encode(falseValueInt16, forKey: .falseValueInt16, using: BoolToInt<Int16>())
    try container.encode(trueValueInt32, forKey: .trueValueInt32, using: BoolToInt<Int32>())
    try container.encode(falseValueInt32, forKey: .falseValueInt32, using: BoolToInt<Int32>())
    try container.encode(trueValueInt64, forKey: .trueValueInt64, using: BoolToInt<Int64>())
    try container.encode(falseValueInt64, forKey: .falseValueInt64, using: BoolToInt<Int64>())
    try container.encode(trueValueUInt, forKey: .trueValueUInt, using: BoolToInt<UInt>())
    try container.encode(falseValueUInt, forKey: .falseValueUInt, using: BoolToInt<UInt>())
    try container.encode(trueValueUInt8, forKey: .trueValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(falseValueUInt8, forKey: .falseValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(trueValueUInt16, forKey: .trueValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(falseValueUInt16, forKey: .falseValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(trueValueUInt32, forKey: .trueValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(falseValueUInt32, forKey: .falseValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(trueValueUInt64, forKey: .trueValueUInt64, using: BoolToInt<UInt64>())
    try container.encode(falseValueUInt64, forKey: .falseValueUInt64, using: BoolToInt<UInt64>())

    try container.encode(trueValueFloat, forKey: .trueValueFloat, using: BoolToFloat<Float>())
    try container.encode(falseValueFloat, forKey: .falseValueFloat, using: BoolToFloat<Float>())
    try container.encode(trueValueDouble, forKey: .trueValueDouble, using: BoolToFloat<Double>())
    try container.encode(falseValueDouble, forKey: .falseValueDouble, using: BoolToFloat<Double>())

    try container.encode(trueValueString, forKey: .trueValueString, using: BoolToString())
    try container.encode(falseValueString, forKey: .falseValueString, using: BoolToString())

    try container.encode(trueValueStruct, forKey: .trueValueStruct, using: BoolToBoolValue())
    try container.encode(falseValueStruct, forKey: .falseValueStruct, using: BoolToBoolValue())

    try container.encodeIfPresent(someValueBool, forKey: .someValueBool, using: IntToBool())
    try container.encodeIfPresent(noneValueBool, forKey: .noneValueBool, using: IntToBool())

    try container.encodeIfPresent(someValueInt, forKey: .someValueInt, using: BoolToInt<Int>())
    try container.encodeIfPresent(noneValueInt, forKey: .noneValueInt, using: BoolToInt<Int>())
    try container.encodeIfPresent(someValueInt8, forKey: .someValueInt8, using: BoolToInt<Int8>())
    try container.encodeIfPresent(noneValueInt8, forKey: .noneValueInt8, using: BoolToInt<Int8>())
    try container.encodeIfPresent(someValueInt16, forKey: .someValueInt16, using: BoolToInt<Int16>())
    try container.encodeIfPresent(noneValueInt16, forKey: .noneValueInt16, using: BoolToInt<Int16>())
    try container.encodeIfPresent(someValueInt32, forKey: .someValueInt32, using: BoolToInt<Int32>())
    try container.encodeIfPresent(noneValueInt32, forKey: .noneValueInt32, using: BoolToInt<Int32>())
    try container.encodeIfPresent(someValueInt64, forKey: .someValueInt64, using: BoolToInt<Int64>())
    try container.encodeIfPresent(noneValueInt64, forKey: .noneValueInt64, using: BoolToInt<Int64>())
    try container.encodeIfPresent(someValueUInt, forKey: .someValueUInt, using: BoolToInt<UInt>())
    try container.encodeIfPresent(noneValueUInt, forKey: .noneValueUInt, using: BoolToInt<UInt>())
    try container.encodeIfPresent(someValueUInt8, forKey: .someValueUInt8, using: BoolToInt<UInt8>())
    try container.encodeIfPresent(noneValueUInt8, forKey: .noneValueUInt8, using: BoolToInt<UInt8>())
    try container.encodeIfPresent(someValueUInt16, forKey: .someValueUInt16, using: BoolToInt<UInt16>())
    try container.encodeIfPresent(noneValueUInt16, forKey: .noneValueUInt16, using: BoolToInt<UInt16>())
    try container.encodeIfPresent(someValueUInt32, forKey: .someValueUInt32, using: BoolToInt<UInt32>())
    try container.encodeIfPresent(noneValueUInt32, forKey: .noneValueUInt32, using: BoolToInt<UInt32>())
    try container.encodeIfPresent(someValueUInt64, forKey: .someValueUInt64, using: BoolToInt<UInt64>())
    try container.encodeIfPresent(noneValueUInt64, forKey: .noneValueUInt64, using: BoolToInt<UInt64>())

    try container.encodeIfPresent(someValueFloat, forKey: .someValueFloat, using: BoolToFloat<Float>())
    try container.encodeIfPresent(noneValueFloat, forKey: .noneValueFloat, using: BoolToFloat<Float>())
    try container.encodeIfPresent(someValueDouble, forKey: .someValueDouble, using: BoolToFloat<Double>())
    try container.encodeIfPresent(noneValueDouble, forKey: .noneValueDouble, using: BoolToFloat<Double>())

    try container.encodeIfPresent(someValueString, forKey: .someValueString, using: BoolToString())
    try container.encodeIfPresent(noneValueString, forKey: .noneValueString, using: BoolToString())

    try container.encodeIfPresent(someValueStruct, forKey: .someValueStruct, using: BoolToBoolValue())
    try container.encodeIfPresent(noneValueStruct, forKey: .noneValueStruct, using: BoolToBoolValue())
  }

}

struct TestUnkeyed: Codable, Equatable {

  var trueValueBool: Int = 1
  var falseValueBool: Int = 0

  var trueValueInt: Bool = true
  var falseValueInt: Bool = false

  var trueValueInt8: Bool = true
  var falseValueInt8: Bool = false

  var trueValueInt16: Bool = true
  var falseValueInt16: Bool = false

  var trueValueInt32: Bool = true
  var falseValueInt32: Bool = false

  var trueValueInt64: Bool = true
  var falseValueInt64: Bool = false

  var trueValueUInt: Bool = true
  var falseValueUInt: Bool = false

  var trueValueUInt8: Bool = true
  var falseValueUInt8: Bool = false

  var trueValueUInt16: Bool = true
  var falseValueUInt16: Bool = false

  var trueValueUInt32: Bool = true
  var falseValueUInt32: Bool = false

  var trueValueUInt64: Bool = true
  var falseValueUInt64: Bool = false

  var trueValueFloat: Bool = true
  var falseValueFloat: Bool = false

  var trueValueDouble: Bool = true
  var falseValueDouble: Bool = false

  var trueValueString: Bool = true
  var falseValueString: Bool = false

  var someValueBool: Int? = 1
  var noneValueBool: Int?

  var someValueInt: Bool? = true
  var noneValueInt: Bool?

  var someValueInt8: Bool? = true
  var noneValueInt8: Bool?

  var someValueInt16: Bool? = true
  var noneValueInt16: Bool?

  var someValueInt32: Bool? = true
  var noneValueInt32: Bool?

  var someValueInt64: Bool? = true
  var noneValueInt64: Bool?

  var someValueUInt: Bool? = true
  var noneValueUInt: Bool?

  var someValueUInt8: Bool? = true
  var noneValueUInt8: Bool?

  var someValueUInt16: Bool? = true
  var noneValueUInt16: Bool?

  var someValueUInt32: Bool? = true
  var noneValueUInt32: Bool?

  var someValueUInt64: Bool? = true
  var noneValueUInt64: Bool?

  var someValueFloat: Bool? = true
  var noneValueFloat: Bool?

  var someValueDouble: Bool? = true
  var noneValueDouble: Bool?

  var someValueString: Bool? = true
  var noneValueString: Bool?

  init() {}

  enum CodingKeys: CodingKey {
    case trueValueBool
    case falseValueBool
    case trueValueInt
    case falseValueInt
    case trueValueInt8
    case falseValueInt8
    case trueValueInt16
    case falseValueInt16
    case trueValueInt32
    case falseValueInt32
    case trueValueInt64
    case falseValueInt64
    case trueValueUInt
    case falseValueUInt
    case trueValueUInt8
    case falseValueUInt8
    case trueValueUInt16
    case falseValueUInt16
    case trueValueUInt32
    case falseValueUInt32
    case trueValueUInt64
    case falseValueUInt64
    case trueValueFloat
    case falseValueFloat
    case trueValueDouble
    case falseValueDouble
    case trueValueString
    case falseValueString
    case someValueBool
    case noneValueBool
    case someValueInt
    case noneValueInt
    case someValueInt8
    case noneValueInt8
    case someValueInt16
    case noneValueInt16
    case someValueInt32
    case noneValueInt32
    case someValueInt64
    case noneValueInt64
    case someValueUInt
    case noneValueUInt
    case someValueUInt8
    case noneValueUInt8
    case someValueUInt16
    case noneValueUInt16
    case someValueUInt32
    case noneValueUInt32
    case someValueUInt64
    case noneValueUInt64
    case someValueFloat
    case noneValueFloat
    case someValueDouble
    case noneValueDouble
    case someValueString
    case noneValueString
  }

  init(from: Decoder) throws {
    var container = try from.unkeyedContainer()

    trueValueBool = try container.decode(using: IntToBool())
    falseValueBool = try container.decode(using: IntToBool())

    trueValueInt = try container.decode(using: BoolToInt<Int>())
    falseValueInt = try container.decode(using: BoolToInt<Int>())
    trueValueInt8 = try container.decode(using: BoolToInt<Int8>())
    falseValueInt8 = try container.decode(using: BoolToInt<Int8>())
    trueValueInt16 = try container.decode(using: BoolToInt<Int16>())
    falseValueInt16 = try container.decode(using: BoolToInt<Int16>())
    trueValueInt32 = try container.decode(using: BoolToInt<Int32>())
    falseValueInt32 = try container.decode(using: BoolToInt<Int32>())
    trueValueInt64 = try container.decode(using: BoolToInt<Int64>())
    falseValueInt64 = try container.decode(using: BoolToInt<Int64>())
    trueValueUInt = try container.decode(using: BoolToInt<UInt>())
    falseValueUInt = try container.decode(using: BoolToInt<UInt>())
    trueValueUInt8 = try container.decode(using: BoolToInt<UInt8>())
    falseValueUInt8 = try container.decode(using: BoolToInt<UInt8>())
    trueValueUInt16 = try container.decode(using: BoolToInt<UInt16>())
    falseValueUInt16 = try container.decode(using: BoolToInt<UInt16>())
    trueValueUInt32 = try container.decode(using: BoolToInt<UInt32>())
    falseValueUInt32 = try container.decode(using: BoolToInt<UInt32>())
    trueValueUInt64 = try container.decode(using: BoolToInt<UInt64>())
    falseValueUInt64 = try container.decode(using: BoolToInt<UInt64>())
    trueValueFloat = try container.decode(using: BoolToFloat<Float>())
    falseValueFloat = try container.decode(using: BoolToFloat<Float>())
    trueValueDouble = try container.decode(using: BoolToFloat<Double>())
    falseValueDouble = try container.decode(using: BoolToFloat<Double>())
    trueValueString = try container.decode(using: BoolToString())
    falseValueString = try container.decode(using: BoolToString())

    someValueBool = try container.decodeIfPresent(using: IntToBool())
    noneValueBool = try container.decodeIfPresent(using: IntToBool())

    someValueInt = try container.decodeIfPresent(using: BoolToInt<Int>())
    noneValueInt = try container.decodeIfPresent(using: BoolToInt<Int>())
    someValueInt8 = try container.decodeIfPresent(using: BoolToInt<Int8>())
    noneValueInt8 = try container.decodeIfPresent(using: BoolToInt<Int8>())
    someValueInt16 = try container.decodeIfPresent(using: BoolToInt<Int16>())
    noneValueInt16 = try container.decodeIfPresent(using: BoolToInt<Int16>())
    someValueInt32 = try container.decodeIfPresent(using: BoolToInt<Int32>())
    noneValueInt32 = try container.decodeIfPresent(using: BoolToInt<Int32>())
    someValueInt64 = try container.decodeIfPresent(using: BoolToInt<Int64>())
    noneValueInt64 = try container.decodeIfPresent(using: BoolToInt<Int64>())
    someValueUInt = try container.decodeIfPresent(using: BoolToInt<UInt>())
    noneValueUInt = try container.decodeIfPresent(using: BoolToInt<UInt>())
    someValueUInt8 = try container.decodeIfPresent(using: BoolToInt<UInt8>())
    noneValueUInt8 = try container.decodeIfPresent(using: BoolToInt<UInt8>())
    someValueUInt16 = try container.decodeIfPresent(using: BoolToInt<UInt16>())
    noneValueUInt16 = try container.decodeIfPresent(using: BoolToInt<UInt16>())
    someValueUInt32 = try container.decodeIfPresent(using: BoolToInt<UInt32>())
    noneValueUInt32 = try container.decodeIfPresent(using: BoolToInt<UInt32>())
    someValueUInt64 = try container.decodeIfPresent(using: BoolToInt<UInt64>())
    noneValueUInt64 = try container.decodeIfPresent(using: BoolToInt<UInt64>())
    someValueFloat = try container.decodeIfPresent(using: BoolToFloat<Float>())
    noneValueFloat = try container.decodeIfPresent(using: BoolToFloat<Float>())
    someValueDouble = try container.decodeIfPresent(using: BoolToFloat<Double>())
    noneValueDouble = try container.decodeIfPresent(using: BoolToFloat<Double>())
    someValueString = try container.decodeIfPresent(using: BoolToString())
    noneValueString = try container.decodeIfPresent(using: BoolToString())
  }

  func encode(to: Encoder) throws {
    var container = to.unkeyedContainer()

    try container.encode(trueValueBool, using: IntToBool())
    try container.encode(falseValueBool, using: IntToBool())

    try container.encode(trueValueInt, using: BoolToInt<Int>())
    try container.encode(falseValueInt, using: BoolToInt<Int>())
    try container.encode(trueValueInt8, using: BoolToInt<Int8>())
    try container.encode(falseValueInt8, using: BoolToInt<Int8>())
    try container.encode(trueValueInt16, using: BoolToInt<Int16>())
    try container.encode(falseValueInt16, using: BoolToInt<Int16>())
    try container.encode(trueValueInt32, using: BoolToInt<Int32>())
    try container.encode(falseValueInt32, using: BoolToInt<Int32>())
    try container.encode(trueValueInt64, using: BoolToInt<Int64>())
    try container.encode(falseValueInt64, using: BoolToInt<Int64>())
    try container.encode(trueValueUInt, using: BoolToInt<UInt>())
    try container.encode(falseValueUInt, using: BoolToInt<UInt>())
    try container.encode(trueValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(falseValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(trueValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(falseValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(trueValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(falseValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(trueValueUInt64, using: BoolToInt<UInt64>())
    try container.encode(falseValueUInt64, using: BoolToInt<UInt64>())
    try container.encode(trueValueFloat, using: BoolToFloat<Float>())
    try container.encode(falseValueFloat, using: BoolToFloat<Float>())
    try container.encode(trueValueDouble, using: BoolToFloat<Double>())
    try container.encode(falseValueDouble, using: BoolToFloat<Double>())
    try container.encode(trueValueString, using: BoolToString())
    try container.encode(falseValueString, using: BoolToString())

    try container.encode(someValueBool, using: IntToBool())
    try container.encode(noneValueBool, using: IntToBool())

    try container.encode(someValueInt, using: BoolToInt<Int>())
    try container.encode(noneValueInt, using: BoolToInt<Int>())
    try container.encode(someValueInt8, using: BoolToInt<Int8>())
    try container.encode(noneValueInt8, using: BoolToInt<Int8>())
    try container.encode(someValueInt16, using: BoolToInt<Int16>())
    try container.encode(noneValueInt16, using: BoolToInt<Int16>())
    try container.encode(someValueInt32, using: BoolToInt<Int32>())
    try container.encode(noneValueInt32, using: BoolToInt<Int32>())
    try container.encode(someValueInt64, using: BoolToInt<Int64>())
    try container.encode(noneValueInt64, using: BoolToInt<Int64>())
    try container.encode(someValueUInt, using: BoolToInt<UInt>())
    try container.encode(noneValueUInt, using: BoolToInt<UInt>())
    try container.encode(someValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(noneValueUInt8, using: BoolToInt<UInt8>())
    try container.encode(someValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(noneValueUInt16, using: BoolToInt<UInt16>())
    try container.encode(someValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(noneValueUInt32, using: BoolToInt<UInt32>())
    try container.encode(someValueUInt64, using: BoolToInt<UInt64>())
    try container.encode(noneValueUInt64, using: BoolToInt<UInt64>())
    try container.encode(someValueFloat, using: BoolToFloat<Float>())
    try container.encode(noneValueFloat, using: BoolToFloat<Float>())
    try container.encode(someValueDouble, using: BoolToFloat<Double>())
    try container.encode(noneValueDouble, using: BoolToFloat<Double>())
    try container.encode(someValueString, using: BoolToString())
    try container.encode(noneValueString, using: BoolToString())
  }

}

struct BoolValue: Codable, Equatable {
  var value: Bool

  init(value: Bool) {
    self.value = value
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    value = try container.decode(Bool.self)
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }

}

struct BoolToBoolValue: ValueCodingTransformer {

  func encode(_ value: Bool) throws -> BoolValue {
    return BoolValue(value: value)
  }

  func decode(_ value: BoolValue) throws -> Bool {
    return value.value
  }

}

struct IntToBool: ValueCodingTransformer {

  func encode(_ value: Int) throws -> Bool {
    return value != 0
  }

  func decode(_ value: Bool) throws -> Int {
    return value ? 1 : 0
  }
}

struct BoolToInt<Value: FixedWidthInteger & Codable>: ValueCodingTransformer {

  func encode(_ value: Bool) throws -> Value {
    return value ? 1 : 0
  }

  func decode(_ value: Value) throws -> Bool {
    return value != 0
  }
}

struct BoolToFloat<Value: BinaryFloatingPoint & Codable>: ValueCodingTransformer {

  func encode(_ value: Bool) throws -> Value {
    return value ? 1.0 : 0.0
  }

  func decode(_ value: Value) throws -> Bool {
    return value != 0.0
  }
}

struct BoolToString: ValueCodingTransformer {

  func encode(_ value: Bool) throws -> String {
    return value ? "true" : "false"
  }

  func decode(_ value: String) throws -> Bool {
    return value == "true"
  }
}
