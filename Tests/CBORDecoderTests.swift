//
//  CBORDecoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
@testable import PotentCBOR
@testable import PotentCodables
import XCTest


class CBORDecoderTests: XCTestCase {

  func testDecodeFromSlice() {
    let data = Data([0x1, 0x2, 0x3, 0x64, 0x49, 0x45, 0x54, 0x46, 0x3, 0x2, 0x1])
    let slice = data[3..<data.count-3]
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: slice), "IETF")
  }

  func testDecodeEmpty() {
    struct Empty: Equatable, Codable {}
    XCTAssertEqual(try CBORDecoder.default.decode(Empty.self, from: Data([0xA0])), Empty())
  }

  func testDecodeNull() {
    XCTAssertNil(try CBORDecoder.default.decodeIfPresent(String.self, from: Data([0xF6])))
  }

  func testDecodeBools() {
    XCTAssertEqual(try CBORDecoder.default.decode(Bool.self, from: Data([0xF4])), false)
    XCTAssertEqual(try CBORDecoder.default.decode(Bool.self, from: Data([0xF5])), true)
    XCTAssertThrowsError(try CBORDecoder.default.decode(Bool.self, from: Data([0x1]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    XCTAssertEqual(try CBORDecoder.default.decodeIfPresent(Bool.self, from: Data([0xf6])), nil)
  }

  func testDecodeInts() {
    // Less than 24
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x00])), 0)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x08])), 8)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x0A])), 10)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x17])), 23)

    // Just bigger than 23
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x18, 0x18])), 24)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x18, 0x19])), 25)

    // Bigger
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x18, 0x64])), 100)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x19, 0x03, 0xE8])), 1000)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x1A, 0x00, 0x0F, 0x42, 0x40])), 1_000_000)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0x1B, 0x00, 0x00, 0x00, 0xE8, 0xD4, 0xA5, 0x10, 0x00])),
      Int64(1_000_000_000_000)
    )

    // Biggest
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt64.self, from: Data([0x1B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])),
      18_446_744_073_709_551_615
    )
  }

  func testDecodeNegativeInts() {
    // Less than 24
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x20])), -1)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x29])), -10)

    // Bigger
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x38, 0x63])), -100)
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0x39, 0x03, 0xE7])), -1000)

    // Overflow
    XCTAssertThrowsError(try CBORDecoder.default.decode(Int8.self, from: Data([0x38, 0x80])))

    // Biggest
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0x3B, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])),
      -9_223_372_036_854_775_808
    )
  }

  func testDecodeInt() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int.self, from: Data([0xE3])),
      Int(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int.self, from: Data([0x03])),
      Int(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int.self, from: Data([0x22])),
      Int(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int.self, from: Data([0xC2, 0x41, 0x03])),
      Int(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int.self, from: Data([0xC3, 0x41, 0x02])),
      Int(-3)
    )
  }

  func testDecodeInt8() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int8.self, from: Data([0xE3])),
      Int8(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int8.self, from: Data([0x03])),
      Int8(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int8.self, from: Data([0x22])),
      Int8(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int8.self, from: Data([0xC2, 0x41, 0x03])),
      Int8(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int8.self, from: Data([0xC3, 0x41, 0x02])),
      Int8(-3)
    )
  }

  func testDecodeInt16() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int16.self, from: Data([0xE3])),
      Int16(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int16.self, from: Data([0x03])),
      Int16(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int16.self, from: Data([0x22])),
      Int16(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int16.self, from: Data([0xC2, 0x41, 0x03])),
      Int16(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int16.self, from: Data([0xC3, 0x41, 0x02])),
      Int16(-3)
    )
  }

  func testDecodeInt32() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int32.self, from: Data([0xE3])),
      Int32(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int32.self, from: Data([0x03])),
      Int32(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int32.self, from: Data([0x22])),
      Int32(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int32.self, from: Data([0xC2, 0x41, 0x03])),
      Int32(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int32.self, from: Data([0xC3, 0x41, 0x02])),
      Int32(-3)
    )
  }

  func testDecodeInt64() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0xE3])),
      Int64(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0x03])),
      Int64(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0x22])),
      Int64(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0xC2, 0x41, 0x03])),
      Int64(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Int64.self, from: Data([0xC3, 0x41, 0x02])),
      Int64(-3)
    )
  }

  func testDecodeUInt() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt.self, from: Data([0xE3])),
      UInt(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt.self, from: Data([0x03])),
      UInt(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt.self, from: Data([0xC2, 0x41, 0x03])),
      UInt(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt8.self, from: Data([0xE3])),
      UInt8(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt8.self, from: Data([0x03])),
      UInt8(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt8.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt8.self, from: Data([0xC2, 0x41, 0x03])),
      UInt8(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt8.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt16.self, from: Data([0xE3])),
      UInt16(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt16.self, from: Data([0x03])),
      UInt16(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt16.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt16.self, from: Data([0xC2, 0x41, 0x03])),
      UInt16(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt16.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt32.self, from: Data([0xE3])),
      UInt32(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt32.self, from: Data([0x03])),
      UInt32(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt32.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt32.self, from: Data([0xC2, 0x41, 0x03])),
      UInt32(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt32.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt64.self, from: Data([0xE3])),
      UInt64(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt64.self, from: Data([0x03])),
      UInt64(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt64.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(UInt64.self, from: Data([0xC2, 0x41, 0x03])),
      UInt64(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt64.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeTaggedInt() {
    XCTAssertEqual(try CBORDecoder.default.decode(Int.self, from: Data([0xC5, 0x1])), 1)
  }

  func testDecodeIntFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(Int.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigInt() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0xE3])),
      BigInt(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0x03])),
      BigInt(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0x22])),
      BigInt(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0xC2, 0x41, 0x03])),
      BigInt(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0xC3, 0x41, 0x02])),
      BigInt(-3)
    )
  }

  func testDecodeTaggedBigInt() {
    XCTAssertEqual(try CBORDecoder.default.decode(BigInt.self, from: Data([0xC5, 0x1])), 1)
  }

  func testDecodeBigIntFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(BigInt.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigUInt() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigUInt.self, from: Data([0xE3])),
      BigUInt(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigUInt.self, from: Data([0x03])),
      BigUInt(3)
    )
    // From negative int
    XCTAssertThrowsError(try CBORDecoder.default.decode(BigUInt.self, from: Data([0x22]))) { error in
      AssertDecodingTypeMismatch(error)
    }
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigUInt.self, from: Data([0xC2, 0x41, 0x03])),
      BigUInt(3)
    )
    // From negative bignum
    XCTAssertThrowsError(try CBORDecoder.default.decode(UInt.self, from: Data([0xC3, 0x41, 0x02]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeTaggedBigUInt() {
    XCTAssertEqual(try CBORDecoder.default.decode(BigUInt.self, from: Data([0xC5, 0x1])), 1)
  }

  func testDecodeBigUIntFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(BigUInt.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInvalidDecimalFractions() {
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC4, 0x82, 0xF6, 0xF6]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0xF6, 0xF6]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeHalf() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xE3])),
      CBOR.Half(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0x03])),
      CBOR.Half(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0x22])),
      CBOR.Half(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC2, 0x41, 0x03])),
      CBOR.Half(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC3, 0x41, 0x02])),
      CBOR.Half(-3)
    )
    // From positive decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC4, 0x82, 0x22, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      CBOR.Half(1234.567)
    )
    // From positive decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC4, 0x82, 0x01, 0xC2, 0x41, 0x12])),
      CBOR.Half(180.0)
    )
    // From negative decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC4, 0x82, 0x22, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      CBOR.Half(-1234.567)
    )
    // From negative decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC4, 0x82, 0x01, 0xC3, 0x41, 0x11])),
      CBOR.Half(-180.0)
    )
  }

  func testDecodeFloat() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xE3])),
      Float(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0x03])),
      Float(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0x22])),
      Float(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC2, 0x41, 0x03])),
      Float(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC3, 0x41, 0x02])),
      Float(-3)
    )
    // From positive decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC4, 0x82, 0x22, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Float(1234.567)
    )
    // From positive decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC4, 0x82, 0x01, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Float(12345670.0)
    )
    // From negative decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC4, 0x82, 0x22, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Float(-1234.567)
    )
    // From negative decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Float.self, from: Data([0xC4, 0x82, 0x01, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Float(-12345670.0)
    )
  }

  func testDecodeDouble() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xE3])),
      Double(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0x03])),
      Double(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0x22])),
      Double(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC2, 0x41, 0x03])),
      Double(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC3, 0x41, 0x02])),
      Double(-3)
    )
    // From positve half
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xf9, 0x3e, 0x00])),
      Double(1.5)
    )
    // From negative half
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xf9, 0xbe, 0x00])),
      Double(-1.5)
    )
    // From positve float
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xfa, 0x3f, 0xfe, 0x66, 0x66])),
      Double(1.9874999523162842)
    )
    // From negative float
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xfa, 0xbf, 0xfe, 0x66, 0x66])),
      Double(-1.9874999523162842)
    )
    // From positve double
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xfb, 0x3f, 0xf3, 0xbe, 0x76, 0xc8, 0xb4, 0x39, 0x58])),
      Double(1.234)
    )
    // From negative double
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xfb, 0xbf, 0xf3, 0xbe, 0x76, 0xc8, 0xb4, 0x39, 0x58])),
      Double(-1.234)
    )
    // From positive decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC4, 0x82, 0x22, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Double(1234.567)
    )
    // From positive decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC4, 0x82, 0x01, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Double(12345670.0)
    )
    // From negative decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC4, 0x82, 0x22, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Double(-1234.567)
    )
    // From negative decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Double.self, from: Data([0xC4, 0x82, 0x01, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Double(-12345670.0)
    )
  }

  func testDecodeTaggedFloat() {
    XCTAssertEqual(try CBORDecoder.default.decode(CBOR.Half.self, from: Data([0xC5, 0xF9, 0x3E, 0x00])), 1.5)
  }

  func testDecodeFloatFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(Float.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimal() {
    // From simple
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xE3])),
      Decimal(3)
    )
    // From unsigned int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0x03])),
      Decimal(3)
    )
    // From negative int
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0x22])),
      Decimal(-3)
    )
    // From positive bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC2, 0x41, 0x03])),
      Decimal(3)
    )
    // From negative bignum
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC3, 0x41, 0x02])),
      Decimal(-3)
    )
    // From positve half
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xf9, 0x3e, 0x00])),
      Decimal(1.5)
    )
    // From negative half
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xf9, 0xbe, 0x00])),
      Decimal(-1.5)
    )
    // From positve float
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xfa, 0x3f, 0xfe, 0x66, 0x66])),
      Decimal(1.9874999523162842)
    )
    // From negative float
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xfa, 0xbf, 0xfe, 0x66, 0x66])),
      Decimal(-1.9874999523162842)
    )
    // From positve double
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xfb, 0x3f, 0xf3, 0xbe, 0x76, 0xc8, 0xb4, 0x39, 0x58])),
      Decimal(1.234)
    )
    // From negative double
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xfb, 0xbf, 0xf3, 0xbe, 0x76, 0xc8, 0xb4, 0x39, 0x58])),
      Decimal(-1.234)
    )
    // From positive decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x22, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Decimal(1234.567)
    )
    // From positive decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x01, 0xC2, 0x43, 0x12, 0xD6, 0x87])),
      Decimal(12345670.0)
    )
    // From negative decimal fraction (neg exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x22, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Decimal(-1234.567)
    )
    // From negative decimal fraction (pos exp)
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x01, 0xC3, 0x43, 0x12, 0xD6, 0x86])),
      Decimal(-12345670.0)
    )
  }

  func testDecodeTaggedDecimal() {
    XCTAssertEqual(try CBORDecoder.default.decode(Decimal.self, from: Data([0xc5, 0x01])), Decimal(1))
  }

  func testDecodeDecimalFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(Decimal.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalNil() {
    XCTAssertEqual(try CBORDecoder.default.decodeIfPresent(Decimal.self, from: Data([0xf6])), nil)
  }

  func testDecodeStrings() {
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: Data([0x60])), "")
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: Data([0x61, 0x61])), "a")
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: Data([0x64, 0x49, 0x45, 0x54, 0x46])), "IETF")
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: Data([0x62, 0x22, 0x5C])), "\"\\")
    XCTAssertEqual(try CBORDecoder.default.decode(String.self, from: Data([0x62, 0xC3, 0xBC])), "\u{00FC}")

  }

  func testDecodeStringFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(String.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeByteStrings() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0x44, 0x01, 0x02, 0x03, 0x04])),
      Data([0x01, 0x02, 0x03, 0x04])
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0x5F, 0x42, 0x01, 0x02, 0x43, 0x03, 0x04, 0x05, 0xFF])),
      Data([0x01, 0x02, 0x03, 0x04, 0x05])
    )
  }

  func testDecodeArrays() {
    XCTAssertEqual(
      try CBORDecoder.default.decode([String].self, from: Data([0x80])),
      []
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([Int].self, from: Data([0x83, 0x01, 0x02, 0x03])),
      [1, 2, 3]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([Int].self, from: Data([0x98, 0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                                             0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                                                             0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x18,
                                                             0x18, 0x19])),
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([[Int]].self, from: Data([0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05])),
      [[1], [2, 3], [4, 5]]
    )
    // indefinite
    XCTAssertEqual(
      try CBORDecoder.default.decode([Int].self, from: Data([0x9F, 0x04, 0x05, 0xFF])),
      [4, 5]
    )
    XCTAssertEqual(
      try CBORDecoder.default
        .decode([[Int]].self, from: Data([0x9F, 0x81, 0x01, 0x82, 0x02, 0x03, 0x9F, 0x04, 0x05, 0xFF, 0xFF])),
      [[1], [2, 3], [4, 5]]
    )
  }

  func testDecodeMaps() {
    XCTAssertEqual(
      try CBORDecoder.default.decode([String: String].self, from: Data([0xA0])),
      [:]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([String: String].self, from: Data([0xA5, 0x61, 0x61, 0x61, 0x41, 0x61, 0x62,
                                                                        0x61, 0x42, 0x61, 0x63, 0x61, 0x43, 0x61,
                                                                        0x64, 0x61, 0x44, 0x61, 0x65, 0x61, 0x45])),
      ["a": "A", "b": "B", "c": "C", "d": "D", "e": "E"]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([Int: Int].self, from: Data([0xA2, 0x01, 0x02, 0x03, 0x04])),
      [1: 2, 3: 4]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([Int: Int].self, from: Data([0xA2, 0x20, 0x21, 0x22, 0x23])),
      [-1: -2, -3: -4]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([String: String].self, from: Data([0xBF, 0x63, 0x46, 0x75, 0x6E, 0x61, 0x62,
                                                                        0x63, 0x41, 0x6D, 0x74, 0x61, 0x63, 0xFF])),
      ["Fun": "b", "Amt": "c"]
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode([String: [String: String]].self, from: Data([0xBF, 0x63, 0x46, 0x75, 0x6E, 0xA1,
                                                                                  0x61, 0x62, 0x61, 0x42, 0x63, 0x41,
                                                                                  0x6D, 0x74, 0xBF, 0x61, 0x63, 0x61,
                                                                                  0x43, 0xFF, 0xFF])),
      ["Fun": ["b": "B"], "Amt": ["c": "C"]]
    )
  }

  func testDecodeInvalidMapKeysThrowsError() throws {
    XCTAssertThrowsError(
      try CBORDecoder.default.decode([Int: Int].self, from: Data([0xA2, 0xf6, 0x02, 0x03, 0x04]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodingDoesntTranslateMapKeys() throws {
    let decoder = CBORDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let dict = try decoder.decodeTree([String: Int].self, from: .map(["this_is_an_example_key": 0]))
    XCTAssertEqual(dict.keys.first, "this_is_an_example_key")
  }

  func testDecodeNumericDates() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Date.self, from: Data([0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try CBORDecoder.default.decode(Date.self, from: Data([0xC1, 0xFB, 0x41, 0xD4, 0x52,
                                                            0xD9, 0xEC, 0x20, 0x00, 0x00])),
      Date(timeIntervalSince1970: 1_363_896_240.5)
    )
  }

  func testDecodeISO8601Dates() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Date.self, from: Data([0xC0, 0x78, 0x18, 0x32, 0x30, 0x32, 0x30, 0x2D, 0x31,
                                                            0x32, 0x2D, 0x31, 0x31, 0x54, 0x31, 0x32, 0x3A, 0x33,
                                                            0x34, 0x3A, 0x35, 0x36, 0x2E, 0x37, 0x38, 0x39, 0x5A])),
      Date(timeIntervalSince1970: 1607690096.789)
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(Date.self, from: Data([0xC0, 0x78, 0x0f, 0x32, 0x30, 0x32, 0x30, 0x2D, 0x31,
                                                            0x32, 0x2D, 0x31, 0x31, 0x54, 0x31, 0x32, 0x3A, 0x33]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }
  func testDecodeExtraTaggedDate() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Date.self, from: Data([0xC5, 0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
  }

  func testDecodeUntaggedDateAsUnits() {
    let decoder = CBORDecoder()
    decoder.untaggedDateDecodingStrategy = .unitsSince1970
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0x1B, 0x00, 0x00, 0x01, 0x3D, 0x8E, 0x8D, 0x07, 0x80])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xFB, 0x41, 0xD4, 0x52, 0xD9, 0xEC, 0x00, 0x00, 0x00])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
  }

  func testDecodeUntaggedDateAsMilliseconds() {
    let decoder = CBORDecoder()
    decoder.untaggedDateDecodingStrategy = .millisecondsSince1970
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0x1B, 0x00, 0x00, 0x01, 0x3D, 0x8E, 0x8D, 0x07, 0x80])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xFB, 0x42, 0x73, 0xD8, 0xE8, 0xD0, 0x78, 0x00, 0x00])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
  }

  func testDecodeUntaggedDateAsSeconds() {
    let decoder = CBORDecoder()
    decoder.untaggedDateDecodingStrategy = .secondsSince1970
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xC1, 0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0x1A, 0x51, 0x4B, 0x67, 0xB0])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
    XCTAssertEqual(
      try decoder.decode(Date.self, from: Data([0xFB, 0x41, 0xD4, 0x52, 0xD9, 0xEC, 0x00, 0x00, 0x00])),
      Date(timeIntervalSince1970: 1_363_896_240)
    )
  }

  func testDecodeDateFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(Date.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeData() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0x45, 0x1, 0x2, 0x3, 0x4, 0x5])),
      Data([1, 2, 3, 4, 5])
    )
  }

  func testDecodeBase64Data() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x22, 0x68, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41, 0x55, 0x2B])),
      Data([1, 2, 3, 4, 5, 62])
    )
    // Unpadded
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x22, 0x66, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41])),
      Data([1, 2, 3, 4])
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x22, 0x68, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41, 0x55, 0x60]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeBase64UrlData() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x21, 0x68, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41, 0x55, 0x2D])),
      Data([1, 2, 3, 4, 5, 62])
    )
    // Unpadded
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x21, 0x66, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41])),
      Data([1, 2, 3, 4])
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(Data.self, from: Data([0xD8, 0x21, 0x68, 0x41, 0x51, 0x49,
                                                            0x44, 0x42, 0x41, 0x55, 0x60]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeDataFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(Data.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeTaggedData() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Data.self, from: Data([0xc5, 0x45, 0x1, 0x2, 0x3, 0x4, 0x5])),
      Data([1, 2, 3, 4, 5])
    )
  }

  func testDecodeURL() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(URL.self, from: Data([0xD8, 0x20, 0x78, 0x1E, 0x68, 0x74, 0x74, 0x70, 0x73, 0x3A,
                                                           0x2F, 0x2F, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 0x2E,
                                                           0x63, 0x6F, 0x6D, 0x2F, 0x73, 0x6F, 0x6D, 0x65, 0x2F, 0x74,
                                                           0x68, 0x69, 0x6E, 0x67])),
      URL(string: "https://example.com/some/thing")
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(URL.self, from: Data([0xD8, 0x20, 0x60]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeTaggedURL() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(URL.self, from: Data([0xc5, 0xD8, 0x20, 0x78, 0x1E, 0x68, 0x74, 0x74, 0x70, 0x73,
                                                           0x3A, 0x2F, 0x2F, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65,
                                                           0x2E, 0x63, 0x6F, 0x6D, 0x2F, 0x73, 0x6F, 0x6D, 0x65, 0x2F,
                                                           0x74, 0x68, 0x69, 0x6E, 0x67])),
      URL(string: "https://example.com/some/thing")
    )
  }

  func testDecodeURLFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(URL.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUUID() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(UUID.self, from: Data([0xD8, 0x25, 0x50, 0x97, 0x5A, 0xEB, 0xED, 0x80, 0x60, 0x4E,
                                                            0x4D, 0x8A, 0x11, 0x28, 0xC5, 0xE8, 0xDD, 0xD2, 0x4C])),
      UUID(uuidString: "975AEBED-8060-4E4D-8A11-28C5E8DDD24C")
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(UUID.self, from: Data([0xD8, 0x25, 0x4c, 0x97, 0x5A, 0xEB, 0xED, 0x80, 0x60, 0x4E,
                                                            0x4D, 0x8A, 0x11, 0x28, 0xC5, 0xE8, 0xDD]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
    XCTAssertEqual(
      try CBORDecoder.default.decode(UUID.self, from: Data([0xD8, 0x25, 0x78, 0x24, 0x39, 0x37, 0x35, 0x41, 0x45,
                                                            0x42, 0x45, 0x44, 0x2D, 0x38, 0x30, 0x36, 0x30, 0x2D,
                                                            0x34, 0x45, 0x34, 0x44, 0x2D, 0x38, 0x41, 0x31, 0x31,
                                                            0x2D, 0x32, 0x38, 0x43, 0x35, 0x45, 0x38, 0x44, 0x44,
                                                            0x44, 0x32, 0x34, 0x43])),
      UUID(uuidString: "975AEBED-8060-4E4D-8A11-28C5E8DDD24C")
    )
    XCTAssertThrowsError(
      try CBORDecoder.default.decode(UUID.self, from: Data([0xD8, 0x25, 0x78, 0x20, 0x39, 0x37, 0x35, 0x41, 0x45, 0x42,
                                                            0x45, 0x44, 0x2D, 0x38, 0x30, 0x36, 0x30, 0x2D, 0x34, 0x45,
                                                            0x34, 0x44, 0x2D, 0x38, 0x41, 0x31, 0x31, 0x2D, 0x32, 0x38,
                                                            0x43, 0x35, 0x45, 0x38, 0x44, 0x44]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }
  func testDecodeTaggedUUID() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(UUID.self, from: Data([0xC5, 0xD8, 0x25, 0x50, 0x97, 0x5A, 0xEB, 0xED, 0x80,
                                                            0x60, 0x4E, 0x4D, 0x8A, 0x11, 0x28, 0xC5, 0xE8, 0xDD,
                                                            0xD2, 0x4C])),
      UUID(uuidString: "975AEBED-8060-4E4D-8A11-28C5E8DDD24C")
    )
  }

  func testDecodeUUIDFromUnsupportedValue() {
    XCTAssertThrowsError(try CBORDecoder.default.decode(UUID.self, from: Data([0xF5]))) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodePositiveDecimalNegativeExponent() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x22, 0xC2, 0x44, 0x00, 0x12, 0xD6, 0x87])),
      Decimal(sign: .plus, exponent: -3, significand: 1234567)
    )
  }

  func testDecodePositiveDecimalPositiveExponent() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x01, 0xC2, 0x44, 0x00, 0x12, 0xD6, 0x87])),
      Decimal(sign: .plus, exponent: 1, significand: 1234567)
    )
  }

  func testDecodeNegativeDecimalNegativeExponent() throws {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x22, 0xC3, 0x44, 0x00, 0x12, 0xD6, 0x86])),
      Decimal(sign: .minus, exponent: -3, significand: 1234567)
    )
  }

  func testDecodeNegativeDecimalPositiveExponent() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(Decimal.self, from: Data([0xC4, 0x82, 0x01, 0xC3, 0x44, 0x00, 0x12, 0xD6, 0x86])),
      Decimal(sign: .minus, exponent: 1, significand: 1234567)
    )
  }

  func testDecodePositiveBigInt() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0xC2, 0x44, 0x00, 0x12, 0xD6, 0x87])),
      BigInt(1234567)
    )
  }

  func testDecodeNegativeBigInt() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigInt.self, from: Data([0xC3, 0x44, 0x00, 0x12, 0xD6, 0x86])),
      BigInt(-1234567)
    )
  }

  func testDecodePositiveBigUInt() {
    XCTAssertEqual(
      try CBORDecoder.default.decode(BigUInt.self, from: Data([0xC2, 0x44, 0x00, 0x12, 0xD6, 0x87])),
      BigUInt(1234567)
    )
  }

  func testDecodeBoolFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Bool.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeStringFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(String.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int8.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int32.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Int64.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt8.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt32.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UInt64.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUIntFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(BigUInt.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloatFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDoubleFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Double.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimalFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Decimal.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUIDFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(UUID.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURLFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(URL.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDateFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Date.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDataFromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Data.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try CBOR.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeAnyDictionary() throws {

    XCTAssertEqual(try CBOR.Decoder.default.decode(AnyValue.AnyDictionary.self,
                                                   from: Data([0xA4, 0x61, 0x62, 0x01, 0x61, 0x7A, 0x02,
                                                               0x61, 0x6E, 0x03, 0x61, 0x66, 0x04])),
                   ["b": 1, "z": 2, "n": 3, "f": 4])
  }

}
