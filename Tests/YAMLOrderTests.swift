//
//  YAMLOrderTests.swift
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
import PotentYAML
import XCTest


class YAMLOrderTests: XCTestCase {

  func testObjectKeySerializationExplicitOrder() throws {

    let yaml = try YAMLSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ])

    XCTAssertEqual(
      yaml.description,
      """
      ---
      c: 1
      a: 2
      b: 3
      ...

      """
    )
  }

  func testObjectKeySerializationSortedOrder() throws {

    let yaml = try YAMLSerialization.string(from: [
      "c": 1,
      "a": 2,
      "b": 3,
    ], options: .sortedKeys)

    XCTAssertEqual(
      yaml.description,
      """
      ---
      a: 2
      b: 3
      c: 1
      ...

      """
    )
  }

  func testObjectKeyDeserializationOrder() throws {

    let mapping: YAML = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(
      mapping,
      try YAMLSerialization.yaml(from:
        """
        ---
        c: 1
        a: 2
        b: 3
        ...

        """
      )
    )
  }

  func testDescriptionOrder() throws {

    let yaml: YAML = [
      "c": 1,
      "a": 2,
      "b": 3,
    ]

    XCTAssertEqual(
      yaml.description,
      """
      ---
      c: 1
      a: 2
      b: 3
      ...

      """
    )
  }

}
