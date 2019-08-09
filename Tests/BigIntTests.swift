//
//  BigIntTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
@testable import PotentASN1
import XCTest


class BigIntTests: XCTestCase {

  func testSerialize() {
    let src1 = BigInt(sign: .minus, magnitude: BigUInt(0xFFFFFFFF))
    let dst1 = BigInt(src1.serialize())
    XCTAssertEqual(src1, dst1)

    let src2 = BigInt(sign: .minus, magnitude: BigUInt(0x10000000))
    let dst2 = BigInt(src2.serialize())
    XCTAssertEqual(src2, dst2)
  }

  func testConversion() {
    if BigUInt.Word.bitWidth == 32 {
      XCTAssertEqual(String(BigInt(0xFFFF).integerValue!, radix: 16), "ffff")
      XCTAssertEqual(String(BigInt(0x7FFFFFFF).integerValue!, radix: 16), "7fffffff")
      XCTAssertEqual(BigInt(0xFFFF).integerValue, 0xFFFF)
      XCTAssertEqual(BigInt(0x7FFFFFFF).integerValue, 0x7FFFFFFF)
      XCTAssertNil(BigInt("ffffffff", radix: 16)!.integerValue)
    }
    else {
      XCTAssertEqual(String(BigInt(0xFFFFFFFF).integerValue!, radix: 16), "ffffffff")
      XCTAssertEqual(String(BigInt(0x7FFFFFFFFFFFFFFF).integerValue!, radix: 16), "7fffffffffffffff")
      XCTAssertEqual(BigInt(0xFFFFFFFF).integerValue, 0xFFFFFFFF)
      XCTAssertEqual(BigInt(0x7FFFFFFFFFFFFFFF).integerValue, 0x7FFFFFFFFFFFFFFF)
      XCTAssertNil(BigInt("ffffffffffffffff", radix: 16)!.integerValue)
    }
  }

}
