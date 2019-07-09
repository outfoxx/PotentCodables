//
//  CBORWriterTests.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
import XCTest

class CBORWriterTests: XCTestCase {
  static var allTests = [
    ("testEncodeInts", testEncodeInts),
    ("testEncodeByteStrings", testEncodeByteStrings),
    ("testEncodeData", testEncodeData),
    ("testEncodeUtf8Strings", testEncodeUtf8Strings),
    ("testEncodeArrays", testEncodeArrays),
    ("testEncodeMaps", testEncodeMaps),
    ("testEncodeTagged", testEncodeTagged),
    ("testEncodeSimple", testEncodeSimple),
    ("testEncodeFloats", testEncodeFloats),
    ("testEncodeIndefiniteArrays", testEncodeIndefiniteArrays),
    ("testEncodeIndefiniteMaps", testEncodeIndefiniteMaps),
    ("testEncodeIndefiniteStrings", testEncodeIndefiniteStrings),
    ("testEncodeIndefiniteByteStrings", testEncodeIndefiniteByteStrings),
    ("testReadmeExamples", testReadmeExamples),
  ]

  func stream(_ type: CBORWriter.StreamableItemType, block: (CBORWriter) throws -> Void) throws -> [UInt8] {
    return try encode { encoder in
      try encoder.encodeIndefiniteStart(for: type)
      defer { try? encoder.encodeIndefiniteEnd() }
      try block(encoder)
    }
  }

  func encode(block: (CBORWriter) throws -> Void) rethrows -> [UInt8] {
    let stream = CBORDataStream()
    let encoder = CBORWriter(stream: stream)
    try block(encoder)
    return Array(stream.data)
  }

  func testEncodeInts() {
    for i in 0 ..< 24 {
      XCTAssertEqual(try encode { try $0.encodeInt(i) }, [UInt8(i)])
      XCTAssertEqual(try encode { try $0.encodeInt(-i) }.count, 1)
    }
    XCTAssertEqual(try encode { try $0.encodeInt(-1) }, [0x20])
    XCTAssertEqual(try encode { try $0.encodeInt(-10) }, [0x29])
    XCTAssertEqual(try encode { try $0.encodeInt(-24) }, [0x37])
    XCTAssertEqual(try encode { try $0.encodeInt(-25) }, [0x38, 24])
    XCTAssertEqual(try encode { try $0.encodeInt(1000000) }, [0x1A, 0x00, 0x0F, 0x42, 0x40])
    XCTAssertEqual(try encode { try $0.encodeInt(Int64(4294967295)) }, [0x1A, 0xFF, 0xFF, 0xFF, 0xFF]) // UInt32.max
    XCTAssertEqual(try encode { try $0.encodeInt(Int64(1000000000000)) }, [0x1B, 0x00, 0x00, 0x00, 0xE8, 0xD4, 0xA5, 0x10, 0x00])
    XCTAssertEqual(try encode { try $0.encodeInt(-1000000) }, [0x3A, 0x00, 0x0F, 0x42, 0x3F])
    XCTAssertEqual(try encode { try $0.encodeInt(Int64(-1000000000000)) }, [0x3B, 0x00, 0x00, 0x00, 0xE8, 0xD4, 0xA5, 0x0F, 0xFF])
  }

  func testEncodeByteStrings() {
    XCTAssertEqual(try encode { try $0.encodeByteString(Data()) }, [0x40])
    XCTAssertEqual(try encode { try $0.encodeByteString(Data([0xF0])) }, [0x41, 0xF0])
    XCTAssertEqual(try encode { try $0.encodeByteString(Data([0x01, 0x02, 0x03, 0x04])) }, [0x44, 0x01, 0x02, 0x03, 0x04])

    let bytes23 = Data([0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xAA])
    XCTAssertEqual(try encode { try $0.encodeByteString(bytes23) }, [0x57] + bytes23)

    let bytes24 = bytes23 + [0xAA]
    XCTAssertEqual(try encode { try $0.encodeByteString(bytes24) }, [0x58, 24] + bytes24)
  }

  func testEncodeData() {
    XCTAssertEqual(try encode { try $0.encodeByteString(Data()) }, [0x40])
    XCTAssertEqual(try encode { try $0.encodeByteString(Data([0xF0])) }, [0x41, 0xF0])
    XCTAssertEqual(try encode { try $0.encodeByteString(Data([0x01, 0x02, 0x03, 0x04])) }, [0x44, 0x01, 0x02, 0x03, 0x04])

    let bytes23 = Data([0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xAA])
    XCTAssertEqual(try encode { try $0.encodeByteString(bytes23) }, [0x57] + bytes23)

    let bytes24 = Data(bytes23 + [0xAA])
    XCTAssertEqual(try encode { try $0.encodeByteString(bytes24) }, [0x58, 24] + bytes24)
  }

  func testEncodeUtf8Strings() {
    XCTAssertEqual(try encode { try $0.encodeString("") }, [0x60])
    XCTAssertEqual(try encode { try $0.encodeString("a") }, [0x61, 0x61])
    XCTAssertEqual(try encode { try $0.encodeString("B") }, [0x61, 0x42])
    XCTAssertEqual(try encode { try $0.encodeString("ABC") }, [0x63, 0x41, 0x42, 0x43])
    XCTAssertEqual(try encode { try $0.encodeString("IETF") }, [0x64, 0x49, 0x45, 0x54, 0x46])
    XCTAssertEqual(try encode { try $0.encodeString("今日は") }, [0x69, 0xE4, 0xBB, 0x8A, 0xE6, 0x97, 0xA5, 0xE3, 0x81, 0xAF])
    XCTAssertEqual(try encode { try $0.encodeString("♨️français;日本語！Longer text\n with break?") },
                   [0x78, 0x34, 0xE2, 0x99, 0xA8, 0xEF, 0xB8, 0x8F, 0x66, 0x72, 0x61, 0x6E, 0xC3, 0xA7, 0x61, 0x69, 0x73, 0x3B, 0xE6, 0x97, 0xA5, 0xE6, 0x9C, 0xAC, 0xE8, 0xAA, 0x9E, 0xEF, 0xBC, 0x81, 0x4C, 0x6F, 0x6E, 0x67, 0x65, 0x72, 0x20, 0x74, 0x65, 0x78, 0x74, 0x0A, 0x20, 0x77, 0x69, 0x74, 0x68, 0x20, 0x62, 0x72, 0x65, 0x61, 0x6B, 0x3F])
    XCTAssertEqual(try encode { try $0.encodeString("\"\\") }, [0x62, 0x22, 0x5C])
    XCTAssertEqual(try encode { try $0.encodeString("\u{6C34}") }, [0x63, 0xE6, 0xB0, 0xB4])
    XCTAssertEqual(try encode { try $0.encodeString("水") }, [0x63, 0xE6, 0xB0, 0xB4])
    XCTAssertEqual(try encode { try $0.encodeString("\u{00fc}") }, [0x62, 0xC3, 0xBC])
    XCTAssertEqual(try encode { try $0.encodeString("abc\n123") }, [0x67, 0x61, 0x62, 0x63, 0x0A, 0x31, 0x32, 0x33])
  }

  func testEncodeArrays() {
    XCTAssertEqual(try encode { try $0.encodeArray([]) }, [0x80])
    XCTAssertEqual(try encode { try $0.encodeArray([1, 2, 3]) }, [0x83, 0x01, 0x02, 0x03])
    XCTAssertEqual(try encode { try $0.encodeArray([[1], [2, 3], [4, 5]]) }, [0x83, 0x81, 0x01, 0x82, 0x02, 0x03, 0x82, 0x04, 0x05])
    XCTAssertEqual(try encode { try $0.encodeArray((1 ... 25).map { CBOR($0) }) },
                   [0x98, 0x19, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x18, 0x18, 0x19])
  }

  func testEncodeMaps() throws {
    XCTAssertEqual(try encode { try $0.encodeMap([:]) }, [0xA0])

    let map = try encode { try $0.encodeMap([1: 2, 3: 4]) }
    XCTAssertTrue(map == [0xA2, 0x01, 0x02, 0x03, 0x04] || map == [0xA2, 0x03, 0x04, 0x01, 0x02])

    let nested = try encode { try $0.encodeMap(["a": [1], "b": [2, 3]]) }
    XCTAssertTrue(nested == [0xA2, 0x61, 0x61, 0x81, 0x01, 0x61, 0x62, 0x82, 0x02, 0x03] || nested == [0xA2, 0x61, 0x62, 0x82, 0x02, 0x03, 0x61, 0x61, 0x81, 0x01])
  }

  func testEncodeTagged() {
    let bignum = Data([0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) // 2**64
    let bignumCBOR = CBOR.byteString(bignum)
    XCTAssertEqual(try encode { try $0.encodeTagged(tag: .positiveBignum, value: bignumCBOR) }, [0xC2, 0x49] + bignum)
    XCTAssertEqual(try encode { try $0.encodeTagged(tag: .init(rawValue: UInt64.max), value: bignumCBOR) }, [0xDB, 255, 255, 255, 255, 255, 255, 255, 255, 0x49] + bignum)
  }

  func testEncodeSimple() {
    XCTAssertEqual(try encode { try $0.encode(.boolean(false)) }, [0xF4])
    XCTAssertEqual(try encode { try $0.encode(.boolean(true)) }, [0xF5])
    XCTAssertEqual(try encode { try $0.encode(.null) }, [0xF6])
    XCTAssertEqual(try encode { try $0.encode(.undefined) }, [0xF7])
    XCTAssertEqual(try encode { try $0.encode(.simple(16)) }, [0xF0])
    XCTAssertEqual(try encode { try $0.encode(.simple(24)) }, [0xF8, 0x18])
    XCTAssertEqual(try encode { try $0.encode(.simple(255)) }, [0xF8, 0xFF])
  }

  func testEncodeFloats() {
    // The following tests are modifications of examples of Float16 in the RFC
    XCTAssertEqual(try encode { try $0.encodeFloat(0.0) }, [0xFA, 0x00, 0x00, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(-0.0) }, [0xFA, 0x80, 0x00, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(1.0) }, [0xFA, 0x3F, 0x80, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(1.5) }, [0xFA, 0x3F, 0xC0, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(65504.0) }, [0xFA, 0x47, 0x7F, 0xE0, 0x00])

    // The following are seen as Float32s in the RFC
    XCTAssertEqual(try encode { try $0.encodeFloat(100000.0) }, [0xFA, 0x47, 0xC3, 0x50, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(3.4028234663852886e+38) }, [0xFA, 0x7F, 0x7F, 0xFF, 0xFF])

    // The following are seen as Doubles in the RFC
    XCTAssertEqual(try encode { try $0.encodeDouble(1.1) }, [0xFB, 0x3F, 0xF1, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9A])
    XCTAssertEqual(try encode { try $0.encodeDouble(-4.1) }, [0xFB, 0xC0, 0x10, 0x66, 0x66, 0x66, 0x66, 0x66, 0x66])
    XCTAssertEqual(try encode { try $0.encodeDouble(1.0e+300) }, [0xFB, 0x7E, 0x37, 0xE4, 0x3C, 0x88, 0x00, 0x75, 0x9C])
    XCTAssertEqual(try encode { try $0.encodeDouble(5.960464477539063e-8) }, [0xFB, 0x3E, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

    // Special values
    XCTAssertEqual(try encode { try $0.encodeFloat(.infinity) }, [0xFA, 0x7F, 0x80, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(-.infinity) }, [0xFA, 0xFF, 0x80, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeDouble(.infinity) }, [0xFB, 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeDouble(-.infinity) }, [0xFB, 0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeFloat(.nan) }, [0xFA, 0x7F, 0xC0, 0x00, 0x00])
    XCTAssertEqual(try encode { try $0.encodeDouble(.nan) }, [0xFB, 0x7F, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

    // Swift's floating point literals are read as Doubles unless specifically specified. e.g.
    XCTAssertEqual(try encode { try $0.encode(0.0) }, [0xFB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }

  func testEncodeIndefiniteArrays() throws {
    let encoded = try stream(.array) {
      try $0.encodeArrayChunk([1, 2])
      try $0.encodeInt(3)
      try $0.encodeIndefiniteStart(for: .array)
      try $0.encodeArrayChunk([1, 2, 3])
      try $0.encodeIndefiniteEnd()
    }
    XCTAssertEqual(encoded, [0x9F, 0x01, 0x02, 0x03, 0x9F, 0x01, 0x02, 0x03, 0xFF, 0xFF])
  }

  func testEncodeIndefiniteMaps() throws {
    let encoded = try stream(.map) {
      try $0.encodeMapChunk(["a": 1])
      try $0.encodeMapChunk(["B": 2])
    }
    XCTAssertEqual(encoded, [0xBF, 0x61, 0x61, 0x01, 0x61, 0x42, 0x02, 0xFF])
  }

  func testEncodeIndefiniteStrings() throws {
    let encoded = try stream(.string) {
      try $0.encodeString("a")
      try $0.encodeString("B")
    }
    XCTAssertEqual(encoded, [0x7F, 0x61, 0x61, 0x61, 0x42, 0xFF])
  }

  func testEncodeIndefiniteByteStrings() throws {
    let encoded = try stream(.byteString) {
      try $0.encodeByteString(Data([0xF0]))
      try $0.encodeByteString(Data([0xFF]))
    }
    XCTAssertEqual(encoded, [0x5F, 0x41, 0xF0, 0x41, 0xFF, 0xFF])
  }

  func testReadmeExamples() throws {
    XCTAssertEqual(try encode { try $0.encode(100) }, [0x18, 0x64])
    XCTAssertEqual(try encode { try $0.encode("hello") }, [0x65, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
    XCTAssertEqual(try encode { try $0.encodeArray(["a", "b", "c"]) }, [0x83, 0x61, 0x61, 0x61, 0x62, 0x61, 0x63])

    struct MyStruct {
      var x: Int
      var y: String

      public func encode() -> CBOR {
        return [
          "x": CBOR(self.x),
          "y": .utf8String(self.y),
        ]
      }
    }

    let encoded = try encode { try $0.encode(MyStruct(x: 42, y: "words").encode()) }
    XCTAssert(encoded == [0xA2, 0x61, 0x79, 0x65, 0x77, 0x6F, 0x72, 0x64, 0x73, 0x61, 0x78, 0x18, 0x2A] || encoded == [0xA2, 0x61, 0x78, 0x18, 0x2A, 0x61, 0x79, 0x65, 0x77, 0x6F, 0x72, 0x64, 0x73])
  }

}

