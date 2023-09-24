//
//  UnkeyedCodingContainerTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import PotentCodables
import PotentJSON
import XCTest


public class UnkeyedCodingContainerTests: XCTestCase {

  func testDecodeContentsBoolArray() throws {

    struct Bools: Codable, Equatable {
      var values: [Bool]
      init(values: [Bool]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Bool.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Bools(values: [true, false])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Bools.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsStringArray() throws {

    struct Strings: Codable, Equatable {
      var values: [String]
      init(values: [String]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(String.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Strings(values: ["a", "b"])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Strings.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt8Array() throws {

    struct Int8s: Codable, Equatable {
      var values: [Int8]
      init(values: [Int8]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int8.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int8s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int8s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt16Array() throws {

    struct Int16s: Codable, Equatable {
      var values: [Int16]
      init(values: [Int16]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int16.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int16s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int16s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt32Array() throws {

    struct Int32s: Codable, Equatable {
      var values: [Int32]
      init(values: [Int32]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int32.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int32s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int32s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt64Array() throws {

    struct Int64s: Codable, Equatable {
      var values: [Int64]
      init(values: [Int64]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int64.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int64s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int64s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt8Array() throws {

    struct UInt8s: Codable, Equatable {
      var values: [UInt8]
      init(values: [UInt8]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt8.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt8s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt8s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt16Array() throws {

    struct UInt16s: Codable, Equatable {
      var values: [UInt16]
      init(values: [UInt16]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt16.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt16s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt16s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt32Array() throws {

    struct UInt32s: Codable, Equatable {
      var values: [UInt32]
      init(values: [UInt32]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt32.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt32s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt32s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt64Array() throws {

    struct UInt64s: Codable, Equatable {
      var values: [UInt64]
      init(values: [UInt64]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt64.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt64s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt64s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsFloatArray() throws {

    struct Floats: Codable, Equatable {
      var values: [Float]
      init(values: [Float]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Float.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Floats(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Floats.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsDoubleArray() throws {

    struct Doubles: Codable, Equatable {
      var values: [Double]
      init(values: [Double]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Double.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Doubles(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Doubles.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsDecodableArray() throws {

    struct Test: Codable, Equatable {
      var int: Int
    }

    struct Tests: Codable, Equatable {
      var values: [Test]
      init(values: [Test]) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Test.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Tests(values: [Test(int: 1), Test(int: 2), Test(int: 3)])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Tests.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsBoolSet() throws {

    struct Bools: Codable, Equatable {
      var values: Set<Bool>
      init(values: Set<Bool>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Bool.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Bools(values: [true, false])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Bools.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsStringSet() throws {

    struct Strings: Codable, Equatable {
      var values: Set<String>
      init(values: Set<String>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(String.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Strings(values: ["a", "b"])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Strings.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt8Set() throws {

    struct Int8s: Codable, Equatable {
      var values: Set<Int8>
      init(values: Set<Int8>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int8.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int8s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int8s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt16Set() throws {

    struct Int16s: Codable, Equatable {
      var values: Set<Int16>
      init(values: Set<Int16>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int16.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int16s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int16s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt32Set() throws {

    struct Int32s: Codable, Equatable {
      var values: Set<Int32>
      init(values: Set<Int32>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int32.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int32s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int32s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsInt64Set() throws {

    struct Int64s: Codable, Equatable {
      var values: Set<Int64>
      init(values: Set<Int64>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Int64.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Int64s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Int64s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt8Set() throws {

    struct UInt8s: Codable, Equatable {
      var values: Set<UInt8>
      init(values: Set<UInt8>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt8.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt8s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt8s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt16Set() throws {

    struct UInt16s: Codable, Equatable {
      var values: Set<UInt16>
      init(values: Set<UInt16>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt16.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt16s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt16s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt32Set() throws {

    struct UInt32s: Codable, Equatable {
      var values: Set<UInt32>
      init(values: Set<UInt32>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt32.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt32s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt32s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsUInt64Set() throws {

    struct UInt64s: Codable, Equatable {
      var values: Set<UInt64>
      init(values: Set<UInt64>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(UInt64.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = UInt64s(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(UInt64s.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsFloatSet() throws {

    struct Floats: Codable, Equatable {
      var values: Set<Float>
      init(values: Set<Float>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Float.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Floats(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Floats.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsDoubleSet() throws {

    struct Doubles: Codable, Equatable {
      var values: Set<Double>
      init(values: Set<Double>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Double.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Doubles(values: [1, 2, 3])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Doubles.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testDecodeContentsDecodableSet() throws {

    struct Test: Codable, Equatable, Hashable {
      var int: Int
    }

    struct Tests: Codable, Equatable {
      var values: Set<Test>
      init(values: Set<Test>) {
        self.values = values
      }
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.values = try container.decodeContents(Test.self)
      }
      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: values)
      }
    }

    let encoded = Tests(values: [Test(int: 1), Test(int: 2), Test(int: 3)])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Tests.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

}
