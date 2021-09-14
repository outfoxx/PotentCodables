//
//  AnyValueTests.swift
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


class AnyValueTests: XCTestCase {

  let json = """
  {
    "a": 1,
    "b": "2",
    "c": [true, false, true],
    "d": {
      "a": 3,
      "b": "4",
      "c": [false, false, true],
      "d": {
        "a": 5,
        "b": "6",
        "c": [true, true, false]
      }
    },
    "e": [
      {
        "aaa": 7,
        "bbb": "8",
        "ccc": [true]
      },
      {
        "aaaa": 9,
        "bbbb": "10",
        "cccc": [true]
      }
    ]
  }
  """.data(using: .utf8)!

  let e = AnyValue.array([
    .dictionary([
      "aaa": .int64(7),
      "bbb": .string("8"),
      "ccc": .array([.bool(true)]),
    ]),
    .dictionary([
      "aaaa": .int64(9),
      "bbbb": .string("10"),
      "cccc": .array([.bool(true)]),
    ]),
  ])

  let f: AnyValue = [
    [
      "a": 7,
      "b": "8",
      "c": [true],
    ],
    [
      "a": 9,
      "b": "10",
      "c": [true],
    ],
  ]

  func testSimple() throws {
    let tree = try JSONSerialization.json(from: json)
    let value = try JSON.Decoder().decode(TestValue.self, from: json)
    let recoded = try JSON.Encoder().encodeTree(value)
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
    a = try container.decode(Int.self, forKey: .a)
    b = try container.decode(String.self, forKey: .b)
    c = try container.decode([Bool].self, forKey: .c)
    d = try container.decodeIfPresent(TestValue.self, forKey: .d)
    e = try container.decodeIfPresent(AnyValue.self, forKey: .e)
  }

}
