//
//  JSONParser.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/13/19.
//

import XCTest
@testable import PotentCodables
import class PotentCodables.JSONEncoder
import class PotentCodables.JSONDecoder


class JSONFragmentTests : XCTestCase {

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
    """

  fileprivate let objects = TestValue(
    a: 1,
    b: "2",
    c: [true, false, true],
    d: TestValue(
      a: 1,
      b: "2",
      c: [false, false, true],
      d: TestValue(
        a: 1,
        b: "2",
        c: [true, true, false]
      )
    ),
    e: [
      TestValue(
        a: 5,
        b: "6",
        c: [true]
      ),
      TestValue(
        a: 5,
        b: "6",
        c: [true]
      )
    ]
  )

  let values : JSON = [
    "a": 1,
    "b": "2",
    "c": [true, false, true],
    "d": [
      "a": 1,
      "b": "2",
      "c": [false, false, true],
      "d": [
        "a": 1,
        "b": "2",
        "c": [true, true, false],
      ]
    ],
    "e": [
      [
        "a": 5,
        "b": "6",
        "c": [true]
      ],
      [
        "a": 5,
        "b": "6",
        "c": [true]
      ]
    ]
  ]

  func testDecodingChildContainers() {
    let json = self.json.data(using: .utf8)!
    let jsonValue = try! JSONDecoder().decode(JSON.self, from: json)
    let _ = try! JSONDecoder().decodeTree(TestValue.self, from: jsonValue)
  }

  func testEncodingChildContainers() {
    let values = try! JSONEncoder().encodeTree(objects)
    XCTAssertEqual(values.stableText, self.values.stableText)
  }

}


private class TestValue : Codable {
  let a: Int
  let b: String
  let c: [Bool]
  let d: TestValue?
  let e: [TestValue]?

  init(a: Int, b: String, c: [Bool], d: TestValue? = nil, e: [TestValue]? = nil) {
    self.a = a
    self.b = b
    self.c = c
    self.d = d
    self.e = e
  }

}
