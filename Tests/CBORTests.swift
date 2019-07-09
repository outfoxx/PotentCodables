//
//  CBORTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

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

