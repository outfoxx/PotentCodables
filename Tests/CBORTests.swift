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

@testable import PotentCBOR
@testable import PotentCodables
import XCTest


class CBORTests: XCTestCase {
  static var allTests = [
    ("testSubscriptSetter", testSubscriptSetter),
    ("testNestedSubscriptSetter", testNestedSubscriptSetter),
    ("testNestedSubscriptSetterWithNewMap", testNestedSubscriptSetterWithNewMap),
  ]

  func testSubscriptSetter() {
    var cbor: CBOR = [
      "foo": 1,
      "bar": "a",
      "zwii": "hd",
      "tags": [
        "a": "1",
        "b": 2,
      ],
    ]

    cbor["foo"] = "changed"
    XCTAssertEqual(cbor["foo"], "changed")
  }

  func testNestedSubscriptSetter() {
    var cbor: CBOR = [
      "foo": 1,
      "bar": "a",
      "zwii": "hd",
      "tags": [
        "a": "1",
        "b": 2,
      ],
    ]

    cbor["tags"]?[2] = "changed"
    XCTAssertEqual(cbor["tags"]?[2], "changed")
  }

  func testNestedSubscriptSetterWithNewMap() {
    var cbor: CBOR = [
      "foo": 1,
      "bar": "a",
      "zwii": "hd",
      "tags": [
        "a": "1",
        "b": 2,
      ],
    ]

    let nestedMap: [CBOR: CBOR] = [
      "joe": "schmoe",
      "age": 56,
    ]

    cbor["tags"]?[2] = CBOR.map(nestedMap)
    XCTAssertEqual(cbor["tags"]?[2], CBOR.map(nestedMap))
  }
}
