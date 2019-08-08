//
//  RefTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import XCTest
@testable import PotentCodables
@testable import PotentJSON


protocol RefTestValue {}

final class AValue: RefTestValue, Codable {
  let name: String

  init(name: String) {
    self.name = name
  }
}

final class BValue: RefTestValue, Codable {
  let values: [String]
}


class RefTests: XCTestCase {

  func testRef() throws {

    let src = AValue(name: "test")

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(AValue(name: "test")))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json.value?.name, "test")

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testCustomRef() throws {

    struct MyTypeKeys: TypeKeyProvider, ValueKeyProvider {
      static var typeKey: AnyCodingKey = "_type"
      static var valueKey: AnyCodingKey = "_value"
    }
    typealias MyRef = CustomRef<MyTypeKeys, MyTypeKeys>

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(MyRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json._type)
    XCTAssertEqual(json._value?.name, "test")

    let ref = try JSONDecoder.default.decodeTree(MyRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testEmbeddedRef() throws {

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(EmbeddedRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json.name, "test")

    let ref = try JSONDecoder.default.decodeTree(EmbeddedRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testCustomEmbeddedRef() throws {

    struct MyTypeKey: TypeKeyProvider {
      static var typeKey: AnyCodingKey = "_type"
    }
    typealias MyRef = CustomEmbeddedRef<MyTypeKey>

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(MyRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json._type)
    XCTAssertEqual(json.name, "test")

    let ref = try JSONDecoder.default.decodeTree(MyRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

}
