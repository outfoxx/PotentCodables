//
//  YAMLReaderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentYAML
import XCTest


class YAMLReaderTests: XCTestCase {

  func testReadMultipleDocuments() throws {

    let yaml =
    """
    ---
    a: 1
    ---
    b: 2
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 2)
    XCTAssertEqual(values[0], ["a": 1] as YAML)
    XCTAssertEqual(values[1], ["b": 2] as YAML)
  }

  func testReadTaggedNull() throws {

    let yaml =
    """
    a: !!null null
    b: !!null "literall anything"
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"], YAML.null())
    XCTAssertEqual(values[0]["b"], YAML.null())
  }

  func testReadTaggedBool() throws {

    let yaml =
    """
    a: !!bool true
    b: !!bool false
    c: !!bool "true"
    d: !!bool "false"
    e: !!bool 1
    f: !!bool 0
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"], .bool(true))
    XCTAssertEqual(values[0]["b"], .bool(false))
    XCTAssertEqual(values[0]["c"], .bool(true))
    XCTAssertEqual(values[0]["d"], .bool(false))
    XCTAssertEqual(values[0]["e"], .bool(true))
    XCTAssertEqual(values[0]["f"], .bool(false))
  }

  func testReadInvalidTaggedBool() throws {

    let yaml =
    """
    a: !!bool something
    """

    XCTAssertThrowsError(try YAMLReader.read(data: yaml.data(using: .utf8)!))
  }

  func testReadTaggedInt() throws {

    let yaml =
    """
    a: !!int 123
    b: !!int "123"
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"]?.integerValue, 123)
    XCTAssertEqual(values[0]["b"]?.integerValue, 123)
  }

  func testReadTaggedFloat() throws {

    let yaml =
    """
    a: !!float 123.456
    b: !!float "123.456"
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"]?.doubleValue, 123.456)
    XCTAssertEqual(values[0]["b"]?.doubleValue, 123.456)
  }

  func testReadTaggedString() throws {

    let yaml =
    """
    a: !!str 123
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"]?.stringValue, "123")
  }

  func testReadAlias() throws {

    let yaml =
    """
    a: *num
    """

    let values = try YAMLReader.read(data: yaml.data(using: .utf8)!)

    XCTAssertEqual(values.count, 1)
    XCTAssertEqual(values[0]["a"], .alias("num"))
  }

  func testReaderThrowsParserErrors() throws {

    let yaml =
    """
    a: "a",
    b: 2
    """

    XCTAssertThrowsError(try YAMLReader.read(data: yaml.data(using: .utf8)!))
  }

}
