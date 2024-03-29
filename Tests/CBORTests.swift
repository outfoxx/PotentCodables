//
//  CBORTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

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

    let nestedMap: CBOR.Map = [
      "joe": "schmoe",
      "age": 56,
    ]

    cbor["tags"]?[2] = CBOR.map(nestedMap)
    XCTAssertEqual(cbor["tags"]?[2], CBOR.map(nestedMap))
  }

  func testMapKeySerializationOrder() throws {

    let cbor = try CBORSerialization.data(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ])

    XCTAssertEqual(cbor, Data([0xA3, 0x61, 0x63, 0x01, 0x61, 0x61, 0x02, 0x61, 0x62, 0x03]))
  }

  func testMapKeyDeserializationOrder() throws {

    let map: CBOR = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(map, try CBORSerialization.cbor(from: Data([0xA3, 0x61, 0x63, 0x01, 0x61, 0x61, 0x02, 0x61, 0x62, 0x03])))
  }

  func testRandomData() throws {

    struct TestStruct: Codable {
      var id: [Int]
      var data: Data
    }

    let encoded = try CBOR.Encoder.default.encode(TestStruct(id: [1, 2, 3, 4, 5], data: Data(count: 16)))

    for _ in 0 ..< 10000 {

      var random = Data(capacity: encoded.count)
      for _ in 0 ..< encoded.count {
        random.append(UInt8.random(in: 0 ..< .max))
      }

      XCTAssertThrowsError(try CBOR.Decoder.default.decode(TestStruct.self, from: random))
    }
  }

}
