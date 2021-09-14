/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import BigInt
@testable import PotentASN1
import XCTest


class BigIntTests: XCTestCase {

  func testSerialize() {
    let src1 = BigInt(sign: .minus, magnitude: BigUInt(0xFFFF_FFFF))
    let dst1 = BigInt(serialized: src1.serialized())
    XCTAssertEqual(src1, dst1)

    let src2 = BigInt(sign: .plus, magnitude: BigUInt(0xFFFF_FFFF))
    let dst2 = BigInt(serialized: src2.serialized())
    XCTAssertEqual(src2, dst2)

    let src3 = BigInt(sign: .minus, magnitude: BigUInt(0x1000_0000))
    let dst3 = BigInt(serialized: src3.serialized())
    XCTAssertEqual(src3, dst3)

    let src4 = BigInt(sign: .plus, magnitude: BigUInt(0x1000_0000))
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
    XCTAssertEqual(String(BigInt(0xFFFF_FFFF).integerValue!, radix: 16), "ffffffff")
    XCTAssertEqual(String(BigInt(0x7FFF_FFFF_FFFF_FFFF).integerValue!, radix: 16), "7fffffffffffffff")
    XCTAssertEqual(BigInt(0xFFFF_FFFF).integerValue, 0xFFFF_FFFF)
    XCTAssertEqual(BigInt(0x7FFF_FFFF_FFFF_FFFF).integerValue, 0x7FFF_FFFF_FFFF_FFFF)
    XCTAssertNil(BigInt("ffffffffffffffff", radix: 16)!.integerValue)
  }

}
