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


protocol RefTestValue {}

struct AValue: RefTestValue, Codable {
  let name: String

  init(name: String) {
    self.name = name
  }
}

struct BValue: RefTestValue, Codable {
  let values: [String]
}


class RefTests: XCTestCase {

  override class func setUp() {
    DefaultTypeIndex.setAllowedTypes([AValue.self, BValue.self])
  }

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
    typealias MyRef = CustomRef<MyTypeKeys, MyTypeKeys, DefaultTypeIndex>

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
    typealias MyRef = CustomEmbeddedRef<MyTypeKey, DefaultTypeIndex>

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(MyRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json._type)
    XCTAssertEqual(json.name, "test")

    let ref = try JSONDecoder.default.decodeTree(MyRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

}
