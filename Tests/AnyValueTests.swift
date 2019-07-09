//
//  AnyValueTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
import class PotentCodables.JSONDecoder
import class PotentCodables.JSONEncoder
import struct PotentCodables.JSONSerialization
import XCTest


class AnyValueTests: XCTestCase {

  let json = """
  {
    "a": 1,
    "b": "2",
    "c": [true, false, true],
    "d": {
      "a": 1,
      "b": "2",
      "c": [false, false, true],
      "d": {
        "a": 1,
        "b": "2",
        "c": [true, true, false]
      }
    },
    "e": [
      {
        "a": 5,
        "b": "6",
        "c": [true]
      },
      {
        "a": 5,
        "b": "6",
        "c": [true]
      }
    ]
  }
  """.data(using: .utf8)!

  let e = AnyValue.array([
    .dictionary([
      "a": .int64(5),
      "b": .string("6"),
      "c": .array([.bool(true)]),
    ]),
    .dictionary([
      "a": .int64(5),
      "b": .string("6"),
      "c": .array([.bool(true)]),
    ]),
  ])

  func testSimple() throws {
    let tree = try JSONSerialization.json(from: json)
    let value = try JSONDecoder().decode(TestValue.self, from: json)
    let recoded = try JSONEncoder().encodeTree(value)
    XCTAssertEqual(recoded.stableText, tree.stableText)
    XCTAssertEqual(value.e!, e)
  }

}


private class TestValue: Codable {
  let a: Int
  let b: String
  let c: [Bool]
  let d: TestValue?
  let e: AnyValue?

  init(a: Int, b: String, c: [Bool], d: TestValue? = nil, e: AnyValue? = nil) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = e
  }

  required init(from: Decoder) throws {
    let container = try from.container(keyedBy: Self.CodingKeys.self)
    self.a = try container.decode(Int.self, forKey: .a)
    self.b = try container.decode(String.self, forKey: .b)
    self.c = try container.decode([Bool].self, forKey: .c)
    self.d = try container.decodeIfPresent(TestValue.self, forKey: .d)
    self.e = try container.decodeIfPresent(AnyValue.self, forKey: .e)
  }

}
