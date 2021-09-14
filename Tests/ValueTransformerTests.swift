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
