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
    let dst1 = BigInt(serialized: src1.serialized())
    XCTAssertEqual(src1, dst1)

    let src2 = BigInt(sign: .plus, magnitude: BigUInt(0xFFFFFFFF))
    let dst2 = BigInt(serialized: src2.serialized())
    XCTAssertEqual(src2, dst2)

    let src3 = BigInt(sign: .minus, magnitude: BigUInt(0x10000000))
    let dst3 = BigInt(serialized: src3.serialized())
    XCTAssertEqual(src3, dst3)

    let src4 = BigInt(sign: .plus, magnitude: BigUInt(0x10000000))
    let dst4 = BigInt(serialized: src4.serialized())
    XCTAssertEqual(src4, dst4)

    let src5 = BigInt(sign: .minus, magnitude: BigUInt(0x0))
    let dst5 = BigInt(serialized: src5.serialized())
    XCTAssertEqual(src5, dst5)

    let src6 = BigInt(sign: .plus, magnitude: BigUInt(0x0))
    let dst6 = BigInt(serialized: src6.serialized())
    XCTAssertEqual(src6, dst6)

    let src7 = BigInt(sign: .minus, magnitude: BigUInt(0x1))
    let dst7 = BigInt(serialized: src7.serialized())
    XCTAssertEqual(src7, dst7)

    let src8 = BigInt(sign: .plus, magnitude: BigUInt(0x1))
    let dst8 = BigInt(serialized: src8.serialized())
    XCTAssertEqual(src8, dst8)
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
