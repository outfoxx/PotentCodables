/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
@testable import PotentYAML
import XCTest


class YAMLTests: XCTestCase {

  func testParse() throws {

    let data = """
    test1: null
    test2: ~
    test3:
    test4: false
    test5: true
    test6: 123
    test7: 123.456
    test8: "a string"
    test9:
      - null
      - false
      - 123
      - 123.456
      - "a string in an array"
    test10:
      a: null
      b: false
      c: 123
      d: 123.456
      e: "a string in a map"
    """.data(using: .utf8)!

    guard let yaml = try YAMLReader.read(data: data).first else {
      XCTFail("No document in stream")
      return
    }

    XCTAssertEqual(yaml["test1"]!, nil)
    XCTAssertEqual(yaml["test2"]!, nil)
    XCTAssertEqual(yaml["test3"]!, nil)
    XCTAssertEqual(yaml["test4"]!, false)
    XCTAssertEqual(yaml["test5"]!, true)
    XCTAssertEqual(yaml["test6"]!, 123)
    XCTAssertEqual(yaml["test7"]!, 123.456)
    XCTAssertEqual(yaml["test8"]!, "a string")
    XCTAssertEqual(yaml["test9"]!, [nil, false, 123, 123.456, "a string in an array"])
    XCTAssertEqual(yaml["test10"]!, ["a": nil, "b": false, "c": 123, "d": 123.456, "e": "a string in a map"])
  }

  let yaml =
    """
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
      ),
    ]
  )


  let values: YAML = [
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
      ],
    ],
    "e": [
      [
        "a": 5,
        "b": "6",
        "c": [true],
      ],
      [
        "a": 5,
        "b": "6",
        "c": [true],
      ],
    ],
  ]

  func testDecodingChildContainers() throws {
    _ = try YAMLDecoder().decode(TestValue.self, from: yaml)
  }

  func testEncodingChildContainers() throws {
    let yamlText = try YAMLEncoder().encodeTree(objects).stableText
    XCTAssertEqual(yamlText, values.stableText)
  }

}


private class TestValue: Codable {
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
