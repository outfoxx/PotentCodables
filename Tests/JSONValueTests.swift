//
//  JSONValueTests.swift
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


class JSONValueTests: XCTestCase {

  func testNilLiteralInitializer() {
    let json: JSON = nil
    XCTAssertTrue(json.isNull)
  }

  func testBoolLiteralInitializer() {
    let json: JSON = true
    XCTAssertEqual(json.boolValue, true)
  }

  func testStringLiteralInitializer() {
    let json: JSON = "Hello World!"
    XCTAssertEqual(json.stringValue, "Hello World!")
  }

  func testFloatLiteralInitializer() {
    let json: JSON = 1.234
    XCTAssertEqual(json.doubleValue, 1.234)
  }

  func testArrayLiteralInitializer() {
    let json: JSON = [1, 2, 3]
    XCTAssertEqual(json.arrayValue, [1, 2, 3])
  }

  func testDictionaryLiteralInitializer() {
    let json: JSON = ["b": 1, "a": 2, "c": 3]
    XCTAssertEqual(json.objectValue, ["b": 1, "a": 2, "c": 3])
  }

  func testJSONNumberStringLiteralInitializer() {
    let number: JSON.Number = "1.234"
    XCTAssertEqual(number.doubleValue, 1.234)
  }

  func testJSONNumberFloatLiteralInitializer() {
    let number: JSON.Number = 1.234
    XCTAssertEqual(number.doubleValue, 1.234)
  }

  func testJSONNumberIntegerLiteralInitializer() {
    let number: JSON.Number = 1234
    XCTAssertEqual(number.integerValue, 1234)
  }

  func testDynamicMemberSubscript() {
    let object: JSON = [
      "aaa": 1,
    ]
    XCTAssertEqual(object.aaa, .number(1))
    XCTAssertEqual(object.bbb, nil)
    XCTAssertEqual(JSON.null.aaa, nil)
  }

  func testIntSubscript() {
    let array: JSON = [
      "a", "b", "c"
    ]
    XCTAssertEqual(array[1], .string("b"))
    XCTAssertEqual(array[3], nil)
    XCTAssertEqual(JSON.null[1], nil)
  }

  func testStringSubscript() {
    let object: JSON = [
      "aaa": 1,
    ]
    XCTAssertEqual(object["aaa"], .number(1))
    XCTAssertEqual(object["bbb"], nil)
    XCTAssertEqual(JSON.null["aaa"], nil)
  }

  func testNullAccessor() {
    XCTAssertTrue(JSON.null.isNull)
    XCTAssertFalse(JSON.number(5).isNull)
  }

  func testStringAccessor() {
    XCTAssertEqual(JSON.string("Hello World!").stringValue, "Hello World!")
    XCTAssertNil(JSON.number(5).stringValue)
  }

  func testBoolAccessor() {
    XCTAssertEqual(JSON.bool(true).boolValue, true)
    XCTAssertNil(JSON.number(5).boolValue)
  }

  func testNumberAccessor() {
    XCTAssertEqual(JSON.number(5).numberValue as? Int, 5)
    XCTAssertNil(JSON.bool(false).numberValue)
  }

  func testIntegerAccessor() {
    XCTAssertEqual(JSON.number(5).integerValue, 5)
    XCTAssertEqual(JSON.number(-5).integerValue, -5)
    XCTAssertNil(JSON.number(5.3).integerValue)
    XCTAssertNil(JSON.bool(false).integerValue)
  }

  func testUnsignedIntegerAccessor() {
    XCTAssertEqual(JSON.number(5).unsignedIntegerValue, 5)
    XCTAssertNil(JSON.number(5.3).unsignedIntegerValue)
    XCTAssertNil(JSON.bool(false).unsignedIntegerValue)
  }

  func testFloatAccessor() {
    XCTAssertEqual(JSON.number(5.3).floatValue, 5.3)
    XCTAssertNil(JSON.bool(false).floatValue)
  }

  func testDoubleAccessor() {
    XCTAssertEqual(JSON.number(5.3).doubleValue, 5.3)
    XCTAssertNil(JSON.bool(false).doubleValue)
  }

  func testArrayAccessor() {
    XCTAssertEqual(JSON.array([1, 2, 3]).arrayValue, [1, 2, 3] as JSON.Array)
    XCTAssertNil(JSON.bool(false).arrayValue)
  }

  func testObjectAccessor() {
    XCTAssertEqual(JSON.object(["a": 1, "b": 2, "c": 3]).objectValue, ["a": 1, "b": 2, "c": 3] as JSON.Object)
    XCTAssertNil(JSON.bool(false).objectValue)
  }

  func testUnwrap() {
    XCTAssertNil(JSON.null.unwrapped)
    XCTAssertEqual(JSON.bool(true).unwrapped as? Bool, true)
    XCTAssertEqual(JSON.string("Hello World!").unwrapped as? String, "Hello World!")
    XCTAssertEqual(JSON.number(5).unwrapped as? Int, 5)
    XCTAssertEqual(JSON.array([1, 2, 3]).unwrapped as? [Int], [1, 2, 3])
    XCTAssertEqual(JSON.object(["a": 1, "b": 2, "c": 3]).unwrapped as? [String: Int], ["a": 1, "b": 2, "c": 3])
  }

}
