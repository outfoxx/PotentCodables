//
//  ValueTransformerTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
@testable import PotentJSON
import XCTest

struct IntegerBoolTransformer: ValueCodingTransformer {

  func encode(_ value: Bool) throws -> Int {
    return value ? 1 : 0
  }

  func decode(_ value: Int) throws -> Bool {
    return value != 0
  }
}


struct Test {

  let boolValue: Bool

}

extension Test: Codable {

  enum CodingKeys: CodingKey {
    case boolValue
  }

  init(from: Decoder) throws {
    let container = try from.container(keyedBy: Self.CodingKeys.self)
    boolValue = try container.decode(forKey: .boolValue, using: IntegerBoolTransformer())
  }

  func encode(to: Encoder) throws {
    var container = to.container(keyedBy: Self.CodingKeys.self)
    try container.encode(boolValue, forKey: .boolValue, using: IntegerBoolTransformer())
  }

}


class ValueTransformerTests: XCTestCase {

  let encoder = JSON.Encoder()

  func testSimple() throws {

    let expected: JSON = [
      "boolValue": 1.0,
    ]

    XCTAssertEqual(try encoder.encodeTree(Test(boolValue: true)).stableText, expected.stableText)
  }

}
