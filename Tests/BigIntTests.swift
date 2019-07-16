//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/18/19.
//

import XCTest
import BigInt
@testable import PotentASN1


class BigIntTests: XCTestCase {

  func testSerialize() {
    let src1 = BigInt(sign: .minus, magnitude: BigUInt(0xffffffff))
    let dst1 = BigInt(src1.serialize())
    XCTAssertEqual(src1, dst1)

    let src2 = BigInt(sign: .minus, magnitude: BigUInt(0x10000000))
    let dst2 = BigInt(src2.serialize())
    XCTAssertEqual(src2, dst2)
  }

  func testConversion() {
    if BigUInt.Word.bitWidth == 32 {
      XCTAssertEqual(String(BigInt(0xffff).integerValue!, radix: 16), "ffff")
      XCTAssertEqual(String(BigInt(0x7fffffff).integerValue!, radix: 16), "7fffffff")
      XCTAssertEqual(BigInt(0xffff).integerValue, 0xffff)
      XCTAssertEqual(BigInt(0x7fffffff).integerValue, 0x7fffffff)
      XCTAssertNil(BigInt("ffffffff", radix: 16)!.integerValue)
    }
    else {
      XCTAssertEqual(String(BigInt(0xffffffff).integerValue!, radix: 16), "ffffffff")
      XCTAssertEqual(String(BigInt(0x7fffffffffffffff).integerValue!, radix: 16), "7fffffffffffffff")
      XCTAssertEqual(BigInt(0xffffffff).integerValue, 0xffffffff)
      XCTAssertEqual(BigInt(0x7fffffffffffffff).integerValue, 0x7fffffffffffffff)
      XCTAssertNil(BigInt("ffffffffffffffff", radix: 16)!.integerValue)
    }
  }

}
