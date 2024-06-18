//
//  YAMLWriterTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentYAML
import XCTest


class YAMLWriterTests: XCTestCase {

  func testWriteScalarCompact() throws {

    let options = YAMLWriter.Options(pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple"], options: options),
      """
      simple

      """
    )

  }

  func testWriteScalarExplicitDocumentMarkers() throws {

    let options = YAMLWriter.Options(pretty: false, explicitDocumentMarkers: true)

    XCTAssertEqual(
      try YAMLWriter.write(["simple"], options: options),
      """
      ---
      simple
      ...

      """
    )

  }

  func testWriteScalarPretty() throws {

    let options = YAMLWriter.Options(pretty: true)

    XCTAssertEqual(
      try YAMLWriter.write(["simple"], options: options),
      """
      ---
      simple
      ...

      """
    )

  }

  func testWriteStringValidSpecialPlain() throws {

    let options = YAMLWriter.Options(pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple  :string"], options: options),
      """
      simple  :string

      """
    )

    XCTAssertEqual(
      try YAMLWriter.write(["simple# string"], options: options),
      """
      simple# string

      """
    )

  }

  func testWriteStringInvalidSpecialPlain() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .plain, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple: string"], options: options),
      """
      "simple: string"

      """
    )

    XCTAssertEqual(
      try YAMLWriter.write(["simple:\nstring"], options: options),
      #"""
      "simple:\nstring"

      """#
    )

    XCTAssertEqual(
      try YAMLWriter.write(["simple   #string"], options: options),
      """
      "simple   #string"

      """
    )

  }

  func testWriteStringPreferPlain() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .plain, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple\nstring"], options: options),
      """
      simple

      string

      """
    )

  }

  func testWriteStringPreferSingleQuoted() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .singleQuoted, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple\nstring"], options: options),
      """
      'simple

      string'

      """
    )

  }

  func testWriteStringPreferDoubleQuoted() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .doubleQuoted, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple\nstring"], options: options),
      """
      "simple\\nstring"

      """
    )

  }

  func testWriteStringPreferLiteral() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .literal, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple\nstring"], options: options),
      """
      |-
        simple
        string

      """
    )

  }

  func testWriteStringPreferFolded() throws {

    let options = YAMLWriter.Options(preferredStringStyle: .folded, pretty: false)

    XCTAssertEqual(
      try YAMLWriter.write(["simple\nstring"], options: options),
      """
      >-
        simple
        \

        string

      """
    )

  }

  func testWriteWidthNormal() throws {

    let yamlVal: YAML =
      "Long Text 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890"

    let options = YAMLWriter.Options(width: .normal)
    let yamlStr = try YAMLWriter.write([yamlVal], options: options)

    XCTAssertEqual(
      yamlStr,
      """
      ---
      Long Text 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
      1234567890
      ...

      """
    )

    XCTAssertEqual(try YAMLReader.read(data: Data(yamlStr.utf8)).first, yamlVal)
  }

  func testWriteWidthNormalInBlock() throws {

    let yamlVal: YAML = [
      "a": "Long Text 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890"
    ]

    let options = YAMLWriter.Options(preferredCollectionStyle: .block, width: .normal)
    let yamlStr = try YAMLWriter.write([yamlVal], options: options)

    XCTAssertEqual(
      yamlStr,
      """
      a: Long Text 123456789 123456789 123456789 123456789 123456789 123456789 123456789
        123456789 1234567890

      """
    )

    XCTAssertEqual(try YAMLReader.read(data: Data(yamlStr.utf8)).first, yamlVal)
  }

  func testWriteMultipleDocuments() throws {

    XCTAssertEqual(
      try YAMLWriter.write([.bool(true), .integer(123)]),
      """
      ---
      true
      ...
      ---
      123
      ...

      """
    )
  }

  func testWriteAliases() throws {

    XCTAssertEqual(
      try YAMLWriter.write([.alias("num")]),
      """
      *num

      """
    )
  }

}
