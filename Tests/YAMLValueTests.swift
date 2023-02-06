//
//  YAMLValueTests.swift
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


class YAMLValueTests: XCTestCase {

  func testNilLiteralInitializer() {
    let json: YAML = nil
    XCTAssertTrue(json.isNull)
  }

  func testBoolLiteralInitializer() {
    let json: YAML = true
    XCTAssertEqual(json.boolValue, true)
  }

  func testStringLiteralInitializer() {
    let json: YAML = "Hello World!"
    XCTAssertEqual(json.stringValue, "Hello World!")
  }

  func testFloatLiteralInitializer() {
    let json: YAML = 1.234
    XCTAssertEqual(json.doubleValue, 1.234)
  }

  func testArrayLiteralInitializer() {
    let json: YAML = [1, 2, 3]
    XCTAssertEqual(json.sequenceValue, [1, 2, 3])
  }

  func testDictionaryLiteralInitializer() {
    let json: YAML = ["b": 1, "a": 2, "c": 3]
    XCTAssertEqual(json.mappingValue, (["b": 1, "a": 2, "c": 3] as YAML).mappingValue)
  }

  func testYAMLNumberStringLiteralInitializer() {
    let number: YAML.Number = "1.234"
    XCTAssertEqual(number.doubleValue, 1.234)
  }

  func testYAMLNumberFloatLiteralInitializer() {
    let number: YAML.Number = 1.234
    XCTAssertEqual(number.doubleValue, 1.234)
  }

  func testYAMLNumberIntegerLiteralInitializer() {
    let number: YAML.Number = 1234
    XCTAssertEqual(number.integerValue, 1234)
  }

  func testDynamicMemberSubscript() {
    let object: YAML = [
      "aaa": 1,
    ]
    XCTAssertEqual(object.aaa, .integer(1))
    XCTAssertEqual(object.bbb, nil)
    XCTAssertEqual(YAML.null().aaa, nil)
  }

  func testIntSubscript() {
    let array: YAML = [
      "a", "b", "c"
    ]
    XCTAssertEqual(array[1], .string("b"))
    XCTAssertEqual(array[3], nil)
    XCTAssertEqual(YAML.null()[1], nil)
  }

  func testStringSubscript() {
    let object: YAML = [
      "aaa": 1,
    ]
    XCTAssertEqual(object["aaa"], .integer(1))
    XCTAssertEqual(object["bbb"], nil)
    XCTAssertEqual(YAML.null()["aaa"], nil)
  }

  func testYAMLSubscript() {
    let object: YAML = [
      "aaa": 1,
    ]
    XCTAssertEqual(object[.string("aaa")], .integer(1))
    XCTAssertEqual(object[.string("bbb")], nil)
    XCTAssertEqual(YAML.null()[.string("aaa")], nil)
  }

  func testNullAccessor() {
    XCTAssertTrue(YAML.null().isNull)
    XCTAssertFalse(YAML.integer(5).isNull)
  }

  func testStringAccessor() {
    XCTAssertEqual(YAML.string("Hello World!").stringValue, "Hello World!")
    XCTAssertNil(YAML.integer(5).stringValue)
  }

  func testBoolAccessor() {
    XCTAssertEqual(YAML.bool(true).boolValue, true)
    XCTAssertNil(YAML.integer(5).boolValue)
  }

  func testNumberAccessor() {
    XCTAssertEqual(YAML.integer(5).numberValue as? Int, 5)
    XCTAssertEqual(YAML.float(5.5).numberValue as? Double, 5.5)
    XCTAssertNil(YAML.bool(false).numberValue)
  }

  func testIntegerAccessor() {
    XCTAssertEqual(YAML.integer(5).integerValue, 5)
    XCTAssertEqual(YAML.integer(-5).integerValue, -5)
    XCTAssertNil(YAML.float(5.3).integerValue)
    XCTAssertNil(YAML.bool(false).integerValue)
  }

  func testUnsignedIntegerAccessor() {
    XCTAssertEqual(YAML.integer(5).unsignedIntegerValue, 5)
    XCTAssertNil(YAML.float(5.3).unsignedIntegerValue)
    XCTAssertNil(YAML.bool(false).unsignedIntegerValue)
  }

  func testFloatAccessor() {
    XCTAssertEqual(YAML.float(5.3).floatValue, 5.3)
    XCTAssertNil(YAML.bool(false).floatValue)
  }

  func testDoubleAccessor() {
    XCTAssertEqual(YAML.float(5.3).doubleValue, 5.3)
    XCTAssertNil(YAML.bool(false).doubleValue)
  }

  func testSequenceAccessor() {
    XCTAssertEqual(YAML.sequence([1, 2, 3]).sequenceValue, [1, 2, 3] as YAML.Sequence)
    XCTAssertNil(YAML.bool(false).sequenceValue)
  }

  func testMappingAccessor() {
    XCTAssertEqual(
      (["a": 1, "b": 2, "c": 3] as YAML).mappingValue,
      YAML.Mapping([.init(key: "a", value: 1), .init(key: "b", value: 2), .init(key: "c", value: 3)])
    )
    XCTAssertNil(YAML.bool(false).mappingValue)
  }

  func testUnwrap() {
    XCTAssertNil(YAML.null().unwrapped)
    XCTAssertEqual(YAML.bool(true).unwrapped as? Bool, true)
    XCTAssertEqual(YAML.string("Hello World!").unwrapped as? String, "Hello World!")
    XCTAssertEqual(YAML.integer(5).unwrapped as? Int, 5)
    XCTAssertEqual(YAML.float(5.5).unwrapped as? Double, 5.5)
    XCTAssertEqual(YAML.sequence([1, 2, 3]).unwrapped as? [Int], [1, 2, 3])
    XCTAssertEqual((["a": 1, "b": 2, "c": 3] as YAML).unwrapped as? [String: Int], ["a": 1, "b": 2, "c": 3])
  }

  func testEquatable() {
    XCTAssertEqual(YAML.null(anchor: "a"), YAML.null())
    XCTAssertEqual(YAML.bool(true, anchor: "a"), YAML.bool(true))
    XCTAssertEqual(YAML.string("aaa", anchor: "a"), YAML.string("aaa"))
    XCTAssertEqual(YAML.integer(3, anchor: "a"), YAML.integer(3))
    XCTAssertEqual(YAML.float(1.23, anchor: "a"), YAML.float(1.23))
    XCTAssertEqual(YAML.sequence([1, 2, 3], anchor: "a"), YAML.sequence([1, 2, 3]))
    XCTAssertEqual(
      YAML.mapping(YAML.Mapping([.init(key: "a", value: 1), .init(key: "b", value: 2), .init(key: "c", value: 3)]), anchor: "a"),
      YAML.mapping(YAML.Mapping([.init(key: "a", value: 1), .init(key: "b", value: 2), .init(key: "c", value: 3)]))
    )
    XCTAssertEqual(YAML.alias("token"), YAML.alias("token"))
    XCTAssertNotEqual(YAML.string("aaa"), YAML.null())
  }

  func testTags() {
    XCTAssertEqual(YAML.Tag(rawValue: "test")?.rawValue, "test")
    XCTAssertEqual(YAML.Tag("test").rawValue, "test")
    XCTAssertEqual(YAML.Tag("test" as String?)?.rawValue, "test")
    XCTAssertEqual(YAML.Tag(nil), nil)
  }

  func testNumberAccessors() {
    XCTAssertTrue(YAML.Number("123").isInteger)
    XCTAssertTrue(YAML.Number("-123").isInteger)
    XCTAssertFalse(YAML.Number("123.456").isInteger)

    XCTAssertEqual(YAML.Number("123").integerValue, 123)
    XCTAssertEqual(YAML.Number("123").unsignedIntegerValue, 123)
    XCTAssertEqual(YAML.Number("-123").integerValue, -123)
    XCTAssertNil(YAML.Number("-123").unsignedIntegerValue)
    XCTAssertNil(YAML.Number("123.456").integerValue)
    XCTAssertNil(YAML.Number("123.456").unsignedIntegerValue)

    XCTAssertFalse(YAML.Number("123.456").isInteger)

    XCTAssertEqual(YAML.Number("123.456").floatValue, 123.456)
    XCTAssertEqual(YAML.Number("-123.456").floatValue, -123.456)
    XCTAssertTrue(YAML.Number("-123").isInteger)
  }

}
