//
//  CBORAnyValueTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCBOR
import PotentCodables
import BigInt
import XCTest


class CBORAnyValueTests: XCTestCase {

  func testDecode() throws {

    struct TestValue: Codable {
      var unsigned: AnyValue
      var negative: AnyValue
      var byteString: AnyValue
      var utf8String: AnyValue
      var array: AnyValue
      var map: AnyValue
      var tagged: AnyValue
      var simple: AnyValue
      var boolean: AnyValue
      var null: AnyValue
      var undefined: AnyValue
      var half: AnyValue
      var float: AnyValue
      var double: AnyValue
    }

    // swiftlint:disable:next line_length
    let cbor = Data(base64Encoded: "rmh1bnNpZ25lZBh7aG5lZ2F0aXZlOQHHamJ5dGVTdHJpbmdLQmluYXJ5IERhdGFqdXRmOFN0cmluZ2xIZWxsbyBXb3JsZCFlYXJyYXmE9vQZAchhYWNtYXCkYWMBYWECYWQDYWIEZnRhZ2dlZMB4GDIwMjAtMTItMjFUMTI6MzQ6NTYuMTIzWmZzaW1wbGXlZ2Jvb2xlYW71ZG51bGz2aXVuZGVmaW5lZPdkaGFsZvk88GVmbG9hdPpBRYfdZmRvdWJsZftAXt06kqMFUw==")!

    let value = try CBOR.Decoder.default.decode(TestValue.self, from: cbor)
    XCTAssertEqual(value.unsigned, AnyValue.int64(123))
    XCTAssertEqual(value.negative, AnyValue.int64(-456))
    XCTAssertEqual(value.byteString, AnyValue.data("Binary Data".data(using: .utf8)!))
    XCTAssertEqual(value.utf8String, AnyValue.string("Hello World!"))
    XCTAssertEqual(value.array, AnyValue.array([.nil, .bool(false), .int64(456), .string("a")]))
    XCTAssertEqual(value.map, AnyValue.dictionary(["c": .int64(1), "a": .int64(2), "d": .int64(3), "b": .int64(4)]))
    XCTAssertEqual(value.tagged, AnyValue.date(ZonedDate(iso8601Encoded: "2020-12-21T12:34:56.123Z")!.utcDate))
    XCTAssertEqual(value.simple, AnyValue.uint8(5))
    XCTAssertEqual(value.boolean, AnyValue.bool(true))
    XCTAssertEqual(value.null, AnyValue.nil)
    XCTAssertEqual(value.undefined, AnyValue.nil)
    XCTAssertEqual(value.half, AnyValue.float16(CBOR.Half("1.234")!))
    XCTAssertEqual(value.float, AnyValue.float(CBOR.Float("12.34567")!))
    XCTAssertEqual(value.double, AnyValue.double(123.4567))
  }

  func testEncode() throws {

    struct TestValue: Codable, Equatable {
      var `nil`: AnyValue = .nil
      var bool: AnyValue = .bool(true)
      var string: AnyValue = .string("Hello World!")
      var pi8: AnyValue = .int8(2)
      var pi16: AnyValue = .int16(500)
      var pi32: AnyValue = .int32(70_000)
      var pi64: AnyValue = .int64(5_000_000_000)
      var ni8: AnyValue = .int8(-2)
      var ni16: AnyValue = .int16(-500)
      var ni32: AnyValue = .int32(-70_000)
      var ni64: AnyValue = .int64(-5_000_000_000)
      var u8: AnyValue = .uint8(UInt8.max)
      var u16: AnyValue = .uint16(UInt16.max)
      var u32: AnyValue = .uint32(UInt32.max)
      var u64: AnyValue = .uint64(UInt64.max)
      var nint: AnyValue = .integer(BigInt("-999000000000000000000000000000"))
      var pint: AnyValue = .integer(BigInt("999000000000000000000000000000"))
      var uint: AnyValue = .unsignedInteger(BigUInt("999000000000000000000000000000"))
      var f16: AnyValue = .float16(1.234)
      var f32: AnyValue = .float(12.34567)
      var f64: AnyValue = .double(123.4567)
      var ppdec: AnyValue = .decimal(Decimal(sign: .plus, exponent: 1, significand: 1234567))
      var pndec: AnyValue = .decimal(Decimal(sign: .plus, exponent: -3, significand: 1234567))
      var npdec: AnyValue = .decimal(Decimal(sign: .minus, exponent: 1, significand: 1234567))
      var nndec: AnyValue = .decimal(Decimal(sign: .minus, exponent: -3, significand: 1234567))
      var data: AnyValue = .data("Binary Data".data(using: .utf8)!)
      var url: AnyValue = .url(URL(string: "https://example.com/some/thing")!)
      var uuid: AnyValue = .uuid(UUID(uuidString: "46076D06-86E8-4B3B-80EF-B24115D4C609")!)
      var date: AnyValue = .date(Date(timeIntervalSinceReferenceDate: 1234567.89))
      var array: AnyValue = .array([nil, false, 456, "a"])
      var object: AnyValue = .dictionary([
        "c": 1,
        "a": 2,
        "d": 3,
        "b": 4,
      ])
    }
    let srcValue = TestValue()

    // swiftlint:disable:next line_length
    let cbor = Data(hexEncoded: "b81f636e696cf664626f6f6cf566737472696e676c48656c6c6f20576f726c6421637069380264706931361901f464706933321a0001117064706936341b000000012a05f200636e693821646e6931363901f3646e6933323a0001116f646e6936343b000000012a05f1ff62753818ff6375313619ffff637533321affffffff637536341bffffffffffffffff646e696e74c34d0c9bf16e93a6a46dad57ffffff6470696e74c24d0c9bf16e93a6a46dad580000006475696e74c24d0c9bf16e93a6a46dad5800000063663136f93cf063663332fa414587dd63663634fb405edd3a92a30553657070646563c48201c24312d68765706e646563c48222c24312d687656e70646563c48201c34312d686656e6e646563c48222c34312d68664646174614b42696e61727920446174616375726cd820781e68747470733a2f2f6578616d706c652e636f6d2f736f6d652f7468696e676475756964d8255046076d0686e84b3b80efb24115d4c6096464617465c07818323030312d30312d31355430363a35363a30372e3839305a65617272617984f6f41901c86161666f626a656374a4616301616102616403616204")

    XCTAssertEqual(try CBOR.Encoder.default.encode(srcValue), cbor)

    let dstValue = try CBOR.Decoder.default.decode(TestValue.self, from: cbor)
    XCTAssertEqual(dstValue.nil, srcValue.nil)
    XCTAssertEqual(dstValue.bool, srcValue.bool)
    XCTAssertEqual(dstValue.string, srcValue.string)
    XCTAssertEqual(dstValue.pi8, .int64(2))
    XCTAssertEqual(dstValue.pi16, .int64(500))
    XCTAssertEqual(dstValue.pi32, .int64(70_000))
    XCTAssertEqual(dstValue.pi64, srcValue.pi64)
    XCTAssertEqual(dstValue.ni8, .int64(-2))
    XCTAssertEqual(dstValue.ni16, .int64(-500))
    XCTAssertEqual(dstValue.ni32, .int64(-70_000))
    XCTAssertEqual(dstValue.ni64, srcValue.ni64)
    XCTAssertEqual(dstValue.u8, .int64(Int64(UInt8.max)))
    XCTAssertEqual(dstValue.u16, .int64(Int64(UInt16.max)))
    XCTAssertEqual(dstValue.u32, .int64(Int64(UInt32.max)))
    XCTAssertEqual(dstValue.u64, .uint64(UInt64.max))
    XCTAssertEqual(dstValue.pint, srcValue.pint)
    XCTAssertEqual(dstValue.nint, srcValue.nint)
    XCTAssertEqual(dstValue.uint, .integer(BigInt("999000000000000000000000000000")))
    XCTAssertEqual(dstValue.f16, srcValue.f16)
    XCTAssertEqual(dstValue.f32, srcValue.f32)
    XCTAssertEqual(dstValue.f64, srcValue.f64)
    XCTAssertEqual(dstValue.ppdec, srcValue.ppdec)
    XCTAssertEqual(dstValue.pndec, srcValue.pndec)
    XCTAssertEqual(dstValue.npdec, srcValue.npdec)
    XCTAssertEqual(dstValue.nndec, srcValue.nndec)
    XCTAssertEqual(dstValue.data, srcValue.data)
    XCTAssertEqual(dstValue.url, srcValue.url)
    XCTAssertEqual(dstValue.uuid, srcValue.uuid)
    XCTAssertEqual(dstValue.date.dateValue?.timeIntervalSince1970, srcValue.date.dateValue?.timeIntervalSince1970)
    XCTAssertEqual(dstValue.array, .array([nil, false, .int64(456), "a"]))
    XCTAssertEqual(dstValue.object, .dictionary(["c": .int64(1), "a": .int64(2), "d": .int64(3), "b": .int64(4)]))
  }

  func testDecodeBase64Data() throws {

    struct TestValue: Codable {
      var b64Data: AnyValue
    }

    let cbor = Data(hexEncoded: "A16762363444617461D82270516D6C7559584A35494552686447453D")

    let dstValue = try CBOR.Decoder.default.decode(TestValue.self, from: cbor)
    XCTAssertEqual(dstValue.b64Data, .data("Binary Data".data(using: .utf8)!))
  }

  func testDecodeTaggedInt() throws {

    struct TestValue: Codable {
      var value: AnyValue
    }

    let cbor = Data(hexEncoded: "A16576616C7565C501")

    let dstValue = try CBOR.Decoder.default.decode(TestValue.self, from: cbor)
    XCTAssertEqual(dstValue.value, .int64(1))
  }

}
