//
//  ASN1DERTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
@testable import PotentASN1
import XCTest


class ASN1DERTests: XCTestCase {

  func testWrite1ByteLengthValue() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0x7f)

    XCTAssertEqual(writer.data, Data([0x4, 0x7f]))
  }

  func testWrite2ByteLengthValue() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0x80)

    XCTAssertEqual(writer.data, Data([0x4, 0x81, 0x80]))
  }

  func testWrite3ByteLengthValueLow() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0x01_00)

    XCTAssertEqual(writer.data, Data([0x4, 0x82, 0x01, 0x00]))
  }

  func testWrite3ByteLengthValueHigh() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0xff_ff)

    XCTAssertEqual(writer.data, Data([0x4, 0x82, 0xff, 0xff]))
  }

  func testWrite4ByteLengthValueLow() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0x01_00_00)

    XCTAssertEqual(writer.data, Data([0x4, 0x83, 0x01, 0x00, 0x00]))
  }

  func testWrite4ByteLengthValueHigh() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0xff_ff_ff)

    XCTAssertEqual(writer.data, Data([0x4, 0x83, 0xff, 0xff, 0xff]))
  }

  func testWrite5ByteLengthValueLow() throws {
    let writer = ASN1DERWriter()
    try writer.append(tag: 4, length: 0x01_00_00_00)

    XCTAssertEqual(writer.data, Data([0x4, 0x84, 0x01, 0x00, 0x00, 0x00]))
  }

}
