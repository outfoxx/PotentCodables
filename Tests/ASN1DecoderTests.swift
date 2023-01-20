//
//  ASN1DecoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentASN1
import PotentJSON
import PotentCodables
import XCTest


class ASN1DecoderTests: XCTestCase {

  func testDecodeNull() {
    let data = Data([ASN1.Tag.null.rawValue, 0])
    XCTAssertNil(try ASN1Decoder(schema: .null).decodeIfPresent(String.self, from: data))
  }

  func testDecodeBool() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .boolean()).decode(Bool.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0xff])),
      true
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .boolean()).decode(Bool.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00])),
      false
    )
  }

  func testDecodeInvalidBool() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .integer()).decode(Bool.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBoolFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Bool.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Int(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])),
      Int(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      Int(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x81])),
      Int(-Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      Int(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0xff, 0xff])),
      Int(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      Int(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x80, 0x01])),
      Int(-Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      Int(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0xff, 0xff, 0xff, 0xff])),
      Int(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      Int(Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x80, 0x00, 0x00, 0x01])),
      Int(-Int32.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Int.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xfe])),
      Int(Int32.max)
    )
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInvalidInt() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Int.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Int8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Int8(1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Int8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])),
      Int8(-1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Int8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      Int8.max
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Int8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x81])),
      -Int8.max
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Int8.self, from: Data([ASN1.Tag.bitString.rawValue, 0x02, 0x00, 0xfe])),
      Int8.max
    )
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int8.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInvalidInt8() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int8.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Int8.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Int16(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])),
      Int16(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      Int16(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x81])),
      Int16(-Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      Int16(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0xff, 0xff])),
      Int16(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      Int16.max
    )
    XCTAssertEqual(
      try decoder.decode(Int16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x80, 0x01])),
      -Int16.max
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Int16.self, from: Data([ASN1.Tag.bitString.rawValue, 0x03, 0x00, 0xff, 0xfe])),
      Int16.max
    )
  }

  func testDecodeInvalidInt16() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int16.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Int16.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Int32(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])),
      Int32(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      Int32(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x81])),
      Int32(-Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      Int32(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0xff, 0xff])),
      Int32(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      Int32(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x80, 0x01])),
      Int32(-Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      Int32(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0xff, 0xff, 0xff, 0xff])),
      Int32(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      Int32.max
    )
    XCTAssertEqual(
      try decoder.decode(Int32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x80, 0x00, 0x00, 0x01])),
      -Int32.max
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Int32.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xfe])),
      Int32.max
    )
  }

  func testDecodeInvalidInt32() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int32.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Int32.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Int64(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff])),
      Int64(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      Int64(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x81])),
      Int64(-Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      Int64(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0xff, 0xff])),
      Int64(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      Int64(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x80, 0x01])),
      Int64(-Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      Int64(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0xff, 0xff, 0xff, 0xff])),
      Int64(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      Int64(Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x80, 0x00, 0x00, 0x01])),
      Int64(-Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])),
      Int64(1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])),
      Int64(-1)
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])),
      Int64.max
    )
    XCTAssertEqual(
      try decoder.decode(Int64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])),
      -Int64.max
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Int64.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])),
      Int64(UInt32.max)
    )
  }

  func testDecodeInvalidInt64() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Int64.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Int64.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      UInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      UInt(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      UInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      UInt(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      UInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      UInt(Int32.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(UInt.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])),
      UInt(UInt32.max)
    )
  }

  func testDecodeInvalidUInt() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UInt.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UInt.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(UInt8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      UInt8(1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(UInt8.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      UInt8(Int8.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(UInt8.self, from: Data([ASN1.Tag.bitString.rawValue, 0x02, 0x00, 0xff])),
      UInt8.max
    )
  }

  func testDecodeInvalidUInt8() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UInt8.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UInt8.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(UInt16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      UInt16(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt16.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      UInt16(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      UInt16(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt16.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      UInt16(Int16.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(UInt16.self, from: Data([ASN1.Tag.bitString.rawValue, 0x03, 0x00, 0xff, 0xff])),
      UInt16.max
    )
  }

  func testDecodeInvalidUInt16() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UInt16.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UInt16.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      UInt32(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      UInt32(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      UInt32(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      UInt32(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      UInt32(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt32.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      UInt32(Int32.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(UInt32.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])),
      UInt32.max
    )
  }

  func testDecodeInvalidUInt32() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UInt32.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UInt32.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      UInt64(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      UInt64(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      UInt64(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      UInt64(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      UInt64(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      UInt64(Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])),
      UInt64(1)
    )
    XCTAssertEqual(
      try decoder.decode(UInt64.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                  0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])),
      UInt64(Int64.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(UInt64.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])),
      UInt64(UInt32.max)
    )
  }

  func testDecodeInvalidUInt64() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UInt64.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UInt64.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigInt() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      BigInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      BigInt(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      BigInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      BigInt(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      BigInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      BigInt(Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])),
      BigInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                  0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])),
      BigInt(Int64.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(BigInt.self, from: Data([ASN1.Tag.bitString.rawValue, 0x06, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff])),
      BigInt(UInt32.max)
    )
  }

  func testDecodeEmptyBigInt() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(BigInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x00])),
      BigInt(0)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(BigInt.self, from: Data([ASN1.Tag.bitString.rawValue, 0x01, 0x00])),
      BigInt(0)
    )
  }

  func testDecodeInvalidBigInt() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(BigInt.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigIntFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(BigInt.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUInt() {
    let decoder = ASN1Decoder(schema: .integer())
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      BigUInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x7f])),
      BigUInt(Int8.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x00, 0x01])),
      BigUInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x02, 0x7f, 0xff])),
      BigUInt(Int16.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x00, 0x00, 0x00, 0x01])),
      BigUInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x04, 0x7f, 0xff, 0xff, 0xff])),
      BigUInt(Int32.max)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])),
      BigUInt(1)
    )
    XCTAssertEqual(
      try decoder.decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x08,
                                                   0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])),
      BigUInt(Int64.max)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(BigUInt.self, from: Data([ASN1.Tag.bitString.rawValue, 0x05, 0x00, 0xff, 0xff, 0xff, 0xff])),
      BigUInt(UInt32.max)
    )
  }

  func testDecodeEmptyBigUInt() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x00])),
      BigUInt(0)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(BigUInt.self, from: Data([ASN1.Tag.bitString.rawValue, 0x01, 0x00])),
      BigUInt(0)
    )
  }

  func testDecodeNegativeBigUInt() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .integer()).decode(BigUInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0xff]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInvalidBigUInt() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(BigUInt.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigUIntFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(BigUInt.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Float.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Float(1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .real).decode(Float.self, from: Data([ASN1.Tag.real.rawValue, 0x05,
                                                                    0x00, 0x31, 0x2E, 0x32, 0x33])),
      Float(1.23)
    )
  }

  func testDecodeInvalidFloat() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Float.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloatFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Float.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDouble() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Double.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Double(1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .real).decode(Double.self, from: Data([ASN1.Tag.real.rawValue, 0x05,
                                                                     0x00, 0x31, 0x2E, 0x32, 0x33])),
      Double(1.23)
    )
  }

  func testDecodeInvalidDouble() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Double.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDoubleFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Double.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimal() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .integer()).decode(Decimal.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      Decimal(1)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .real).decode(Decimal.self, from: Data([ASN1.Tag.real.rawValue, 0x05,
                                                                      0x00, 0x31, 0x2E, 0x32, 0x33])),
      Decimal(1.23)
    )
  }

  func testDecodeInvalidDecimal() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Decimal.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Decimal.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeStrings() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .string(kind: .utf8))
        .decode(String.self, from: Data([ASN1.Tag.utf8String.rawValue, 0x0b,
                                         0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64])),
      String("Hello World")
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .string(kind: .general))
        .decode(String.self, from: Data([ASN1.Tag.generalString.rawValue, 0x0b,
                                         0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64])),
      String("Hello World")
    )
  }

  func testDecodeInvalidString() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(String.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeStringFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(String.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUID() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .string(kind: .utf8))
        .decode(UUID.self, from: Data([ASN1.Tag.utf8String.rawValue, 0x24,
                                       0x33, 0x35, 0x33, 0x35, 0x36, 0x38, 0x44, 0x38, 0x2D, 0x42, 0x32, 0x33,
                                       0x32, 0x2D, 0x34, 0x41, 0x30, 0x30, 0x2D, 0x42, 0x44, 0x37, 0x36, 0x2D,
                                       0x33, 0x33, 0x38, 0x42, 0x38, 0x42, 0x33, 0x43, 0x37, 0x46, 0x42, 0x37])),
      UUID(uuidString: "353568D8-B232-4A00-BD76-338B8B3C7FB7")
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .octetString())
        .decode(UUID.self, from: Data([ASN1.Tag.octetString.rawValue, 0x10,
                                       0x4C, 0xFD, 0x3C, 0x5A, 0x6D, 0x1B, 0x4B, 0x52, 0x84, 0x76, 0xDA, 0x6E,
                                       0xEF, 0x38, 0xC2, 0x53])),
      UUID(uuidString: "4CFD3C5A-6D1B-4B52-8476-DA6EEF38C253")
    )
  }

  func testDecodeUUIDFromInvalidString() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .string(kind: .utf8))
        .decode(UUID.self, from: Data([ASN1.Tag.utf8String.rawValue, 0x0b,
                                       0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeUUIDFromInvalidData() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .octetString())
        .decode(UUID.self, from: Data([ASN1.Tag.octetString.rawValue, 0x0C,
                                       0x4C, 0xFD, 0x3C, 0x5A, 0x6D, 0x1B, 0x4B, 0x52, 0x84, 0x76, 0xDA, 0x6E]))
    ) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeInvalidUUID() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(UUID.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUUIDFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(UUID.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURL() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .string(kind: .utf8))
        .decode(URL.self, from: Data([ASN1.Tag.utf8String.rawValue, 0x1E,
                                      0x68, 0x74, 0x74, 0x70, 0x73, 0x3A, 0x2F, 0x2F, 0x65, 0x78, 0x61, 0x6D,
                                      0x70, 0x6C, 0x65, 0x2E, 0x63, 0x6F, 0x6D, 0x2F, 0x73, 0x6F, 0x6D, 0x65,
                                      0x2F, 0x74, 0x68, 0x69, 0x6E, 0x67])),
      URL(string: "https://example.com/some/thing")
    )
  }

  func testDecodeInvalidURL() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(URL.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeURLFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(URL.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeData() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .octetString())
        .decode(Data.self, from: Data([ASN1.Tag.octetString.rawValue, 0x10,
                                       0x4C, 0xFD, 0x3C, 0x5A, 0x6D, 0x1B, 0x4B, 0x52, 0x84, 0x76, 0xDA, 0x6E,
                                       0xEF, 0x38, 0xC2, 0x53])),
      Data(hexEncoded: "4CFD3C5A6D1B4B528476DA6EEF38C253")
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(Data.self, from: Data([ASN1.Tag.bitString.rawValue, 0x02, 0x00, 0x7f])),
      Data([0x7f])
    )
  }

  func testDecodeInvalidData() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Data.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDataFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Data.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDate() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .time(kind: .generalized))
        .decode(Date.self, from: Data([ASN1.Tag.generalizedTime.rawValue, 0x0f,
                                       0x32, 0x30, 0x32, 0x32, 0x31, 0x32, 0x31,
                                       0x31, 0x31, 0x30, 0x30, 0x39, 0x30, 0x38, 0x5A])),
      ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")?.utcDate
    )
  }

  func testDecodeInvalidDate() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(Date.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDateFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(Date.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeAnyString() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .string(kind: .utf8))
        .decode(AnyString.self, from: Data([ASN1.Tag.utf8String.rawValue, 0x0b,
                                            0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64])),
      AnyString("Hello World", kind: .utf8)
    )
  }

  func testDecodeInvalidAnyString() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(AnyString.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeAnyStringFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(AnyString.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeAnyTime() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .time(kind: .generalized))
        .decode(AnyTime.self, from: Data([ASN1.Tag.generalizedTime.rawValue, 0x0f,
                                       0x32, 0x30, 0x32, 0x32, 0x31, 0x32, 0x31,
                                       0x31, 0x31, 0x30, 0x30, 0x39, 0x30, 0x38, 0x5A])),
      AnyTime(ZonedDate(iso8601Encoded: "2022-12-11T10:09:08Z")!, kind: .generalized)
    )
  }

  func testDecodeInvalidAnyTime() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(AnyTime.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeAnyTimeFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(AnyTime.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBitString() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .bitString())
        .decode(BitString.self, from: Data([ASN1.Tag.bitString.rawValue, 0x02, 0x00, 0x7f])),
      BitString(bitPattern: 0xfe)
    )
    XCTAssertEqual(
      try ASN1Decoder(schema: .octetString())
        .decode(BitString.self, from: Data([ASN1.Tag.octetString.rawValue, 0x01, 0x7f])),
      BitString(bitPattern: 0xfe)
    )
  }

  func testDecodeInvalidBitString() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean()).decode(BitString.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBitStringFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(BitString.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeObjectIdentifier() {
    XCTAssertEqual(
      try ASN1Decoder(schema: .objectIdentifier())
        .decode(ObjectIdentifier.self, from: Data([ASN1.Tag.objectIdentifier.rawValue, 0x04,
                                                   0x2A, 0x03, 0x04, 0x05])),
      ObjectIdentifier([1, 2, 3, 4, 5])
    )
  }

  func testDecodeInvalidObjectIdentifier() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .boolean())
        .decode(ObjectIdentifier.self, from: Data([ASN1.Tag.boolean.rawValue, 0x01, 0x00]))
    ) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeObjectIdentifierFromNull() {
    XCTAssertThrowsError(
      try ASN1Decoder(schema: .null).decode(ObjectIdentifier.self, from: Data([ASN1.Tag.null.rawValue, 0x00]))
    ) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeTagged() {

    struct TaggedInt: Equatable, Codable, Tagged {
      var tag: ASN1.AnyTag = 0x35
      var int: BigInt

      init?(tag: ASN1.AnyTag, value: Any?) {
        guard let int = value as? BigInt else {
          return nil
        }
        self.int = int
      }

      var value: Any? { int }

      func encode(schema: Schema) throws -> ASN1 {
        return .tagged(0x35, Data())
      }

    }

    XCTAssertEqual(
      try ASN1Decoder(schema: .integer())
        .decode(TaggedInt.self, from: Data([ASN1.Tag.integer.rawValue, 0x01, 0x01])),
      TaggedInt(tag: 0x35, value: BigInt(1))
    )
  }

}
