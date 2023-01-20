//
//  JSONOrderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables
import PotentJSON
import XCTest


class JSONOrderTests: XCTestCase {

  func testObjectKeySerializationExplicitOrder() throws {

    let json = try JSONSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ])

    XCTAssertEqual(json, #"{"c":1,"a":2,"b":3}"#)
  }

  func testObjectKeySerializationSortedOrder() throws {

    let json = try JSONSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ], options: .sortedKeys)

    XCTAssertEqual(json, #"{"a":2,"b":3,"c":1}"#)
  }

  func testObjectKeyDeserializationOrder() throws {

    let object: JSON = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(object, try JSONSerialization.json(from: #"{"c":1,"a":2,"b":3}"#))
  }

  func testDescriptionOrder() throws {

    let json: JSON = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(
      json.description,
      """
      {
        "c" : 1,
        "a" : 2,
        "b" : 3
      }
      """
    )
  }

}
