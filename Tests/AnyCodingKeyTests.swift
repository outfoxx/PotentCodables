//
//  AnyCodingKeyTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables
import XCTest


class AnyCodingKeyTests: XCTestCase {

  func testInit() {

    let intKey: AnyCodingKey = 5
    XCTAssertEqual(intKey, AnyCodingKey(intValue: 5))
    XCTAssertEqual(intKey.intValue, 5)
    XCTAssertEqual(intKey.stringValue, "5")

    let idxKey = AnyCodingKey(index: 5)
    XCTAssertEqual(idxKey, AnyCodingKey(intValue: 5))
    XCTAssertEqual(idxKey.intValue, 5)
    XCTAssertEqual(idxKey.stringValue, "5")

    let strKey: AnyCodingKey = "test"
    XCTAssertEqual(strKey, AnyCodingKey(stringValue: "test"))
    XCTAssertEqual(strKey.stringValue, "test")
    XCTAssertEqual(strKey.intValue, nil)
  }

  func testConvert() {

    enum StrKey: CodingKey {
      case test
    }

    let strKey = AnyCodingKey(StrKey.test)
    XCTAssertEqual(strKey.stringValue, "test")
    XCTAssertNil(strKey.intValue)
    XCTAssertEqual(strKey.key() as StrKey, .test)

    enum IntKey: Int, CodingKey {
      case test = 1
    }

    let intKey = AnyCodingKey(IntKey.test)
    XCTAssertEqual(intKey.stringValue, "1")
    XCTAssertEqual(intKey.intValue, 1)
    XCTAssertEqual(intKey.key() as IntKey, .test)
  }

}
