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

@testable import PotentCodables
@testable import PotentJSON
import XCTest


class JSONTests: XCTestCase {

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
      ),
    ]
  )

  let values: JSON = [
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
    _ = try JSONDecoder().decode(TestValue.self, from: json)
  }

  func testEncodingChildContainers() throws {
    let json = try JSONEncoder().encodeTree(objects).stableText
    XCTAssertEqual(json, values.stableText)
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
