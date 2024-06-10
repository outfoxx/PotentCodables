//
//  YAMLSchemaTests.swift
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

class YAMLSchemaTests: XCTestCase {

  let schema: YAMLSchema = .core

  func testNullMatching() {
    XCTAssertTrue(schema.isNull("null"))
    XCTAssertTrue(schema.isNull("Null"))
    XCTAssertTrue(schema.isNull("NULL"))
    XCTAssertTrue(schema.isNull("~"))
    XCTAssertTrue(schema.isNull(""))

    XCTAssertFalse(schema.isNull("NuLL"))
  }

  func testBoolMatching() {
    XCTAssertTrue(schema.isBool("true"))
    XCTAssertTrue(schema.isBool("True"))
    XCTAssertTrue(schema.isBool("TRUE"))

    XCTAssertFalse(schema.isBool("TRue"))

    XCTAssertTrue(schema.isBool("false"))
    XCTAssertTrue(schema.isBool("False"))
    XCTAssertTrue(schema.isBool("FALSE"))

    XCTAssertFalse(schema.isBool("FaLSe"))
  }

  func testIntMatching() {
    XCTAssertTrue(schema.isInt("0"))
    XCTAssertTrue(schema.isInt("00"))
    XCTAssertTrue(schema.isInt("19"))
    XCTAssertTrue(schema.isInt("+19"))
    XCTAssertTrue(schema.isInt("-19"))
    XCTAssertTrue(schema.isInt("0o7"))
    XCTAssertTrue(schema.isInt("0x3A"))
  }

  func testFloatMatching() {
    XCTAssertTrue(schema.isFloat("0."))
    XCTAssertTrue(schema.isFloat("+0."))
    XCTAssertTrue(schema.isFloat("-0."))
    XCTAssertTrue(schema.isFloat("0.0"))
    XCTAssertTrue(schema.isFloat("+0.0"))
    XCTAssertTrue(schema.isFloat("-0.0"))
    XCTAssertTrue(schema.isFloat(".5"))
    XCTAssertTrue(schema.isFloat("+.5"))
    XCTAssertTrue(schema.isFloat("-.5"))
    XCTAssertTrue(schema.isFloat("12e03"))
    XCTAssertTrue(schema.isFloat("+12e03"))
    XCTAssertTrue(schema.isFloat("-12e03"))
    XCTAssertTrue(schema.isFloat("2E+05"))
    XCTAssertTrue(schema.isFloat("+2E+05"))
    XCTAssertTrue(schema.isFloat("-2E+05"))

    XCTAssertTrue(schema.isFloat(".inf"))
    XCTAssertTrue(schema.isFloat("+.inf"))
    XCTAssertTrue(schema.isFloat("-.inf"))
    XCTAssertTrue(schema.isFloat(".Inf"))
    XCTAssertTrue(schema.isFloat("+.Inf"))
    XCTAssertTrue(schema.isFloat("-.Inf"))
    XCTAssertTrue(schema.isFloat(".INF"))
    XCTAssertTrue(schema.isFloat("+.INF"))
    XCTAssertTrue(schema.isFloat("-.INF"))

    XCTAssertFalse(schema.isFloat(".inF"))

    XCTAssertTrue(schema.isFloat(".nan"))
    XCTAssertTrue(schema.isFloat(".NaN"))
    XCTAssertTrue(schema.isFloat(".NAN"))

    XCTAssertFalse(schema.isFloat(".naN"))
  }

}
