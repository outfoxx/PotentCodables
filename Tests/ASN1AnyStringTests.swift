//
//  ASN1AnyStringTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentASN1
import XCTest


class ASN1AnyStringTests: XCTestCase {

  func testInit() {

    let val0 = AnyString("test", kind: .utf8)
    XCTAssertEqual(val0.storage, "test")
    XCTAssertEqual(val0.kind, .utf8)

    let val1: AnyString = "test"
    XCTAssertEqual(val1.storage, "test")
    XCTAssertNil(val1.kind)

    let val2 = AnyString(String("test"))
    XCTAssertEqual(val2.storage, "test")
    XCTAssertNil(val2.kind)

    let val3 = "test".withCString { AnyString(cString: $0) }
    XCTAssertEqual(val3.storage, "test")
    XCTAssertNil(val3.kind)
  }

  func testCodable() {

    XCTAssertEqual(try JSONEncoder().encode(AnyString("test")), #""test""#.data(using: .utf8))
    XCTAssertEqual(try JSONDecoder().decode(AnyString.self, from: #""test""#.data(using: .utf8)!), AnyString("test"))
  }

  func testUppercased() {
    XCTAssertEqual(AnyString("test").uppercased(), "TEST")
  }

  func testLowercased() {
    XCTAssertEqual(AnyString("TEST").lowercased(), "test")
  }

  func testUTF8() {
    XCTAssertEqual(Array(AnyString("test").utf8), Array("test".utf8))
  }

  func testUTF16() {
    XCTAssertEqual(Array(AnyString("test").utf16), Array("test".utf16))
  }

  func testUnicodeScalars() {
    XCTAssertEqual(Array(AnyString("test").unicodeScalars), Array("test".unicodeScalars))
  }

  func testCString() {

    XCTAssertEqual(AnyString("test").withCString { String(cString: $0) }, "test")
  }

  func testIndices() {

    let str = AnyString("test")
    XCTAssertEqual(str[str.startIndex], "t")
    XCTAssertEqual(str[str.startIndex..<str.endIndex], "test")
    XCTAssertEqual(str.index(after: str.startIndex), str.storage.index(after: str.storage.startIndex))
    XCTAssertEqual(str.index(before: str.endIndex), str.storage.index(before: str.storage.endIndex))
  }

  func testWrite() {

    var str = AnyString("Hello")
    str.write(" World")
    XCTAssertEqual(str.storage, "Hello World")

    var empty = ""
    AnyString("test").write(to: &empty)
    XCTAssertEqual(empty, "test")
  }

}
