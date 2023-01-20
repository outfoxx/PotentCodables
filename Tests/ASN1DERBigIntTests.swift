//
//  ASN1DERBigIntTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
@testable import PotentASN1
import XCTest


class ASN1DERBigIntTests: XCTestCase {

  func testSerialize() {
    let src1 = BigInt(sign: .minus, magnitude: BigUInt(0xFFFF_FFFF))
    let dst1 = BigInt(derEncoded: src1.derEncoded())
    XCTAssertEqual(src1, dst1)

    let src2 = BigInt(sign: .plus, magnitude: BigUInt(0xFFFF_FFFF))
    let dst2 = BigInt(derEncoded: src2.derEncoded())
    XCTAssertEqual(src2, dst2)

    let src3 = BigInt(sign: .minus, magnitude: BigUInt(0x1000_0000))
    let dst3 = BigInt(derEncoded: src3.derEncoded())
    XCTAssertEqual(src3, dst3)

    let src4 = BigInt(sign: .plus, magnitude: BigUInt(0x1000_0000))
    let dst4 = BigInt(derEncoded: src4.derEncoded())
    XCTAssertEqual(src4, dst4)

    let src5 = BigInt(sign: .minus, magnitude: BigUInt(0x0))
    let dst5 = BigInt(derEncoded: src5.derEncoded())
    XCTAssertEqual(src5, dst5)

    let src6 = BigInt(sign: .plus, magnitude: BigUInt(0x0))
    let dst6 = BigInt(derEncoded: src6.derEncoded())
    XCTAssertEqual(src6, dst6)

    let src7 = BigInt(sign: .minus, magnitude: BigUInt(0x1))
    let dst7 = BigInt(derEncoded: src7.derEncoded())
    XCTAssertEqual(src7, dst7)

    let src8 = BigInt(sign: .plus, magnitude: BigUInt(0x1))
    let dst8 = BigInt(derEncoded: src8.derEncoded())
    XCTAssertEqual(src8, dst8)
  }

}
