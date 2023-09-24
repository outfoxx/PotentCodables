//
//  ValueTransformerProvidingTests.swift
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


class ValueTransformableTests: XCTestCase {

  func testTopLevel() throws {
    let encoded = Uncodable(data: Data([1, 2, 3, 4, 5]))
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Uncodable.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testKeyContainer() throws {

    struct Test: Codable, Equatable {
      var value: Uncodable

      init(value: Uncodable) {
        self.value = value
      }

      enum CodingKeys: CodingKey {
        case value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Uncodable.self, forKey: .value)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
      }
    }

    let encoded = Test(value: Uncodable(data: Data([1, 2, 3, 4, 5])))
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Test.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testUnkeyedContainerContents() throws {

    struct Test: Codable, Equatable {
      var value: [Uncodable]

      init(value: [Uncodable]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.value = try container.decodeContents(Uncodable.self)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: value)
      }
    }

    let encoded = Test(value: [Uncodable(data: Data([1, 2, 3, 4, 5])), Uncodable(data: Data([6, 7, 8, 9, 0]))])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Test.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testUnkeyedContainer() throws {

    struct Test: Codable, Equatable {
      var value: [Uncodable]

      init(value: [Uncodable]) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var value: [Uncodable] = []
        while !container.isAtEnd {
          value.append(try container.decode(Uncodable.self))
        }
        self.value = value
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in value {
          try container.encode(element)
        }
      }
    }

    let encoded = Test(value: [Uncodable(data: Data([1, 2, 3, 4, 5])), Uncodable(data: Data([6, 7, 8, 9, 0]))])
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Test.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

  func testSingleValueContainer() throws {

    struct Test: Codable, Equatable {
      var value: Uncodable

      init(value: Uncodable) {
        self.value = value
      }

      init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        self.value = try container.decode(Uncodable.self)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
      }
    }

    let encoded = Test(value: Uncodable(data: Data([1, 2, 3, 4, 5])))
    let data = try JSONEncoder.default.encode(encoded)
    let decoded = try JSONDecoder.default.decode(Test.self, from: data)
    XCTAssertEqual(encoded, decoded)
  }

}


struct Uncodable: Equatable {
  var data: Data
}

extension Uncodable: ValueCodingTransformerProviding {

  struct CodingTransformer: InitializableValueCodingTransformer {
    func decode(_ value: Data) throws -> Uncodable {
      return Uncodable(data: try JSONDecoder.default.decode(Data.self, from: value))
    }
    func encode(_ value: Uncodable) throws -> Data {
      return try JSONEncoder.default.encode(value.data)
    }
  }
}
