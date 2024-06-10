//
//  YAMLErrorTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentYAML
import XCTest


/// Tests covering *fixed* errors in libfyaml or its usage.
///
class YAMLErrorTests: XCTestCase {

  public func testEmitNumberInPlainString() throws {

    let scalarYaml1: YAML = "1924."
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml1),
      #"""
      "1924."

      """#
    )
  }

  public func testSimpleScalarNotOnDocMarkerLinePretty() throws {

    let scalarYaml1: YAML = "simple"
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml1, options: [.pretty]),
      #"""
      ---
      simple
      ...

      """#
    )
  }

  public func testSimpleScalarNotOnDocMarkerLineExplicit() throws {

    let scalarYaml1: YAML = "simple"
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml1, options: [.explictDocumentMarkers]),
      #"""
      ---
      simple
      ...

      """#
    )
  }

  public func testSimpleScalarNoDocMarkers() throws {

    let scalarYaml1: YAML = "simple"
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml1, options: []),
      #"""
      simple

      """#
    )
  }

  public func testOutputWhitespaceOnlyString() throws {

    let scalarYaml1: YAML = .string(.init(repeating: " ", count: 1))
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml1),
      #"""
      " "

      """#
    )

    let scalarYaml2: YAML = .string(.init(repeating: " ", count: 2))
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml2),
      #"""
      "  "

      """#
    )

    let scalarYaml3: YAML = .string(.init(repeating: " ", count: 3))
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml3),
      #"""
      "   "

      """#
    )

    let scalarYaml9: YAML = .string(.init(repeating: " ", count: 9))
    XCTAssertEqual(
      try YAMLSerialization.string(from: scalarYaml9),
      #"""
      "         "

      """#
    )
  }

}
