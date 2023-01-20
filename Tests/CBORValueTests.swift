//
//  CBORValueTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCBOR
import XCTest


class CBORValueTests: XCTestCase {

  func testNilLiteralInitializer() {
    let cbor: CBOR = nil
    XCTAssertTrue(cbor.isNull)
  }

  func testBoolLiteralInitializer() {
    let cbor: CBOR = true
    XCTAssertEqual(cbor.booleanValue, true)
  }

  func testStringLiteralInitializer() {
    let cbor: CBOR = "Hello World!"
    XCTAssertEqual(cbor.utf8StringValue, "Hello World!")
  }

  func testFloatLiteralInitializer() {
    let cbor: CBOR = 1.234
    XCTAssertEqual(cbor.doubleValue, 1.234)
  }

  func testArrayLiteralInitializer() {
    let cbor: CBOR = [1, 2, 3]
    XCTAssertEqual(cbor.arrayValue, [1, 2, 3])
  }

  func testDictionaryLiteralInitializer() {
    let cbor: CBOR = ["b": 1, "a": 2, "c": 3]
    XCTAssertEqual(cbor.mapValue, ["b": 1, "a": 2, "c": 3])
  }

  func testDataInitializer() {
    let cbor = CBOR(Data([1, 2, 3, 4]))
    XCTAssertEqual(cbor.bytesStringValue, Data([1, 2, 3, 4]))
  }

  func testUIntInitializer() {
    let cbor = CBOR(UInt(5))
    XCTAssertEqual(cbor.integerValue() as UInt?, 5)
  }

  func testHalfInitializer() {
    let cbor = CBOR(CBOR.Half(1.5))
    XCTAssertEqual(cbor.floatingPointValue() as CBOR.Half?, 1.5)
  }

  func testFloatInitializer() {
    let cbor = CBOR(Float(1.5))
    XCTAssertEqual(cbor.floatingPointValue() as Float?, 1.5)
  }

  func testCBORNumberFloatLiteralInitializer() {
    let number: CBOR = 1.234
    XCTAssertEqual(number.doubleValue, 1.234)
  }

  func testDynamicMemberSubscript() {
    let map: CBOR = [
      "aaa": 1,
    ]
    XCTAssertEqual(map.aaa, .unsignedInt(1))
    XCTAssertEqual(map.bbb, nil)
    XCTAssertEqual(CBOR.null.aaa, nil)
  }

  func testIntSubscript() {
    var array: CBOR = [
      "a", "b", "c"
    ]
    XCTAssertEqual(array[1], .utf8String("b"))
    XCTAssertEqual(array[3], nil)
    XCTAssertEqual(CBOR.null[1], nil)

    array[1] = .utf8String("d")
    XCTAssertEqual(array[1], .utf8String("d"))
  }

  func testStringSubscript() {
    var map: CBOR = [
      "aaa": 1,
    ]
    XCTAssertEqual(map["aaa"], .unsignedInt(1))
    XCTAssertEqual(map["bbb"], nil)
    XCTAssertEqual(CBOR.null["aaa"], nil)

    map["aaa"] = .unsignedInt(5)
    XCTAssertEqual(map["aaa"], .unsignedInt(5))
  }

  func testNullAccessor() {
    XCTAssertTrue(CBOR.null.isNull)
    XCTAssertFalse(CBOR.unsignedInt(5).isNull)
  }

  func testStringAccessor() {
    XCTAssertEqual(CBOR.utf8String("Hello World!").utf8StringValue, "Hello World!")
    XCTAssertNil(CBOR.unsignedInt(5).utf8StringValue)
  }

  func testByteStringAccessor() {
    XCTAssertEqual(CBOR.byteString(Data([1, 2, 3, 4])).bytesStringValue, Data([1, 2, 3, 4]))
    XCTAssertNil(CBOR.unsignedInt(5).bytesStringValue)
  }

  func testBoolAccessor() {
    XCTAssertEqual(CBOR.boolean(true).booleanValue, true)
    XCTAssertNil(CBOR.unsignedInt(5).booleanValue)
  }

  func testIntegerAccessor() {
    XCTAssertEqual(CBOR.unsignedInt(5).integerValue() as Int?, 5)
    XCTAssertEqual(CBOR.negativeInt(4).integerValue() as Int?, -5)
    XCTAssertNil(CBOR.double(5.3).integerValue() as Int?)
    XCTAssertNil(CBOR.boolean(false).integerValue() as Int?)
  }

  func testSimpleAccessor() {
    XCTAssertEqual(CBOR.simple(5).simpleValue, 5)
    XCTAssertNil(CBOR.boolean(false).simpleValue)
  }

  func testHalfAccessor() {
    XCTAssertEqual(CBOR.half(5.3).halfValue, 5.3)
    XCTAssertNil(CBOR.boolean(false).halfValue)
  }

  func testFloatAccessor() {
    XCTAssertEqual(CBOR.float(5.3).floatValue, 5.3)
    XCTAssertNil(CBOR.boolean(false).floatValue)
  }

  func testDoubleAccessor() {
    XCTAssertEqual(CBOR.double(5.3).doubleValue, 5.3)
    XCTAssertNil(CBOR.boolean(false).doubleValue)
  }

  func testFloatingAccessor() {
    XCTAssertEqual(CBOR.unsignedInt(5).floatingPointValue() as Float?, 5.0)
    XCTAssertEqual(CBOR.negativeInt(4).floatingPointValue() as Float?, -5.0)
    XCTAssertEqual(CBOR.half(5.3).floatingPointValue() as CBOR.Half?, 5.3)
    XCTAssertEqual(CBOR.float(5.3).floatingPointValue() as Float?, 5.3)
    XCTAssertEqual(CBOR.double(5.3).floatingPointValue() as Double?, 5.3)
    XCTAssertNil(CBOR.boolean(false).floatingPointValue() as Double?)
  }

  func testArrayAccessor() {
    XCTAssertEqual(CBOR.array([1, 2, 3]).arrayValue, [1, 2, 3] as CBOR.Array)
    XCTAssertNil(CBOR.boolean(false).arrayValue)
  }

  func testObjectAccessor() {
    XCTAssertEqual(CBOR.map(["a": 1, "b": 2, "c": 3]).mapValue, ["a": 1, "b": 2, "c": 3] as CBOR.Map)
    XCTAssertNil(CBOR.boolean(false).mapValue)
  }

  func testUnwrap() {
    XCTAssertNil(CBOR.null.unwrapped)
    XCTAssertNil(CBOR.undefined.unwrapped)
    XCTAssertEqual(CBOR.boolean(true).unwrapped as? Bool, true)
    XCTAssertEqual(CBOR.byteString(Data([1, 2, 3, 4])).unwrapped as? Data, Data([1, 2, 3, 4]))
    XCTAssertEqual(CBOR.simple(5).unwrapped as? UInt8, 5)
    XCTAssertEqual(CBOR.utf8String("Hello World!").unwrapped as? String, "Hello World!")
    XCTAssertEqual(CBOR.unsignedInt(5).unwrapped as? UInt64, 5)
    XCTAssertEqual(CBOR.negativeInt(4).unwrapped as? Int64, -5)
    XCTAssertEqual(CBOR.half(1.5).unwrapped as? CBOR.Half, 1.5)
    XCTAssertEqual(CBOR.float(1.5).unwrapped as? Float, 1.5)
    XCTAssertEqual(CBOR.double(1.5).unwrapped as? Double, 1.5)
    XCTAssertEqual(CBOR.array([1, 2, 3]).unwrapped as? [UInt64], [1, 2, 3])
    XCTAssertEqual(CBOR.map(["a": 1, "b": 2, "c": 3]).unwrapped as? [String: UInt64], ["a": 1, "b": 2, "c": 3])
    XCTAssertEqual(CBOR.tagged(CBOR.Tag(rawValue: 5), CBOR.unsignedInt(5)).unwrapped as? UInt64, 5)
  }

  func testUntagged() {
    XCTAssertEqual(CBOR.tagged(CBOR.Tag(rawValue: 5), CBOR.unsignedInt(5)).untagged, CBOR.unsignedInt(5))
  }

}
