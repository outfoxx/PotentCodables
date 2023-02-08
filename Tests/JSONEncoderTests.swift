//
//  JSONEncoderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import BigInt
import Foundation
import PotentCodables
import PotentJSON
import XCTest


class JSONEncoderTests: XCTestCase {

  func testEncodeWithDefaultKeyStrategy() {

    struct TestValue: Codable {
      var camelCased: String
    }

    let json = #"{"camelCased":"Hello World!"}"#

    let encoder = JSON.Encoder()
    encoder.keyEncodingStrategy = .useDefaultKeys

    XCTAssertEqual(try encoder.encodeString(TestValue(camelCased: "Hello World!")), json)
  }

  func testEncodeWithSnakeCaseKeyStrategy() {

    struct TestValue: Codable {
      var snakeCased: String
    }

    let json = #"{"snake_cased":"Hello World!"}"#

    let encoder = JSON.Encoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase

    XCTAssertEqual(try encoder.encodeString(TestValue(snakeCased: "Hello World!")), json)
  }

  func testEncodeWithCustomKeyStrategy() {

    struct TestValue: Codable {
      var kebabCased: String
    }

    let json = #"{"kebab-cased":"Hello World!"}"#

    let encoder = JSON.Encoder()
    encoder.keyEncodingStrategy = .custom { _ in
      return AnyCodingKey(stringValue: "kebab-cased")
    }

    XCTAssertEqual(try encoder.encodeString(TestValue(kebabCased: "Hello World!")), json)
  }

  func testEncodeToString() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
    }

    let json = #"{"int":5,"string":"Hello World!"}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue())
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeToStringWithPrettyOption() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
      var array = [1, 2, 3]
      var object = [
        "b": 2,
        "a": 1,
      ]
    }

    let json =
    """
    {
      "array" : [
        1,
        2,
        3
      ],
      "int" : 5,
      "object" : {
        "a" : 1,
        "b" : 2
      },
      "string" : "Hello World!"
    }
    """

    let encoder = JSON.Encoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let testJSON = try encoder.encodeString(TestValue())
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeToStringWithEscapedStringsOption() throws {

    struct TestValue: Codable {
      var url = "http://example.com/some/thing"
    }

    let json = #"{"url":"http:\/\/example.com\/some\/thing"}"#

    let encoder = JSON.Encoder()
    encoder.outputFormatting = .escapeSlashes

    let testJSON = try encoder.encodeString(TestValue())
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeToStringWithSortedKeysOption() throws {

    struct TestValue: Codable {
      var c = 1
      var a = 2
      var b = 3
    }

    let json = #"{"a":2,"b":3,"c":1}"#

    let encoder = JSON.Encoder()
    encoder.outputFormatting = .sortedKeys

    let testJSON = try encoder.encodeString(TestValue())
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeToData() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
    }

    let json = #"{"int":5,"string":"Hello World!"}"#

    let testJSONData = try JSON.Encoder.default.encode(TestValue())
    XCTAssertEqual(testJSONData, json.data(using: .utf8)!)
  }

  func testEncodeToDataWithPrettyOption() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
      var array = [1, 2, 3]
      var object = [
        "b": 2,
        "a": 1,
      ]
    }

    let json =
    """
    {
      "array" : [
        1,
        2,
        3
      ],
      "int" : 5,
      "object" : {
        "a" : 1,
        "b" : 2
      },
      "string" : "Hello World!"
    }
    """

    let encoder = JSON.Encoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let testJSONData = try encoder.encode(TestValue())
    XCTAssertEqual(testJSONData, json.data(using: .utf8))
  }

  func testEncodeToDataWithEscapedStringsOption() throws {

    struct TestValue: Codable {
      var url = "http://example.com/some/thing"
    }

    let json = #"{"url":"http:\/\/example.com\/some\/thing"}"#

    let encoder = JSON.Encoder()
    encoder.outputFormatting = .escapeSlashes

    let testJSONData = try encoder.encode(TestValue())
    XCTAssertEqual(testJSONData, json.data(using: .utf8))
  }

  func testEncodeToDataWithSortedKeysOption() throws {

    struct TestValue: Codable {
      var c = 1
      var a = 2
      var b = 3
    }

    let json = #"{"a":2,"b":3,"c":1}"#

    let encoder = JSON.Encoder()
    encoder.outputFormatting = .sortedKeys

    let testJSONData = try encoder.encode(TestValue())
    XCTAssertEqual(testJSONData, json.data(using: .utf8))
  }

  func testEncodingChildContainers() throws {

    class TestValue: Codable {
      var b: Int = 5
      var d: String = "Hello World!"
      var a: Bool = true
      var c: TestValue?

      init(c: TestValue? = nil) {
        self.c = c
      }
    }

    let json =
    """
    {
      "b" : 5,
      "d" : "Hello World!",
      "a" : true,
      "c" : {
        "b" : 5,
        "d" : "Hello World!",
        "a" : true,
        "c" : {
          "b" : 5,
          "d" : "Hello World!",
          "a" : true
        }
      }
    }
    """

    let testValue = TestValue(c: TestValue(c: TestValue()))

    let testJSON = try prettyEncoder.encodeString(testValue)
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateAsISO8601() throws {

    let date = ZonedDate(date: Date(), timeZone: .utc)
    let parsedDate = ZonedDate(iso8601Encoded: date.iso8601EncodedString())!

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"\#(parsedDate.iso8601EncodedString())"}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .iso8601

    let testJSON = try encoder.encodeString(TestValue(date: parsedDate.utcDate))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateAsEpochSeconds() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSince1970)}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .secondsSince1970

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateAsEpochMilliseconds() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSince1970 * 1000.0)}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .millisecondsSince1970

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateWithDeferredToDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSinceReferenceDate)}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .deferredToDate

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateWithFormatter() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"\#(formatter.string(from: date))"}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .formatted(formatter)

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateWithCustomEncoder() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSinceReferenceDate)}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
      var container = encoder.singleValueContainer()
      try container.encode(date.timeIntervalSinceReferenceDate)
    }

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDateWithNothingCustomEncoder() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":null}"#

    let encoder = JSON.Encoder()
    encoder.dateEncodingStrategy = .custom { _, _ in
      // do nothing
    }

    let testJSON = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDataAsBase64() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"\#(data.base64EncodedString())"}"#

    let encoder = JSON.Encoder()
    encoder.dataEncodingStrategy = .base64

    let testJSON = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDataWithDeferredToData() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":[\#(data.map { String($0) }.joined(separator: ","))]}"#

    let encoder = JSON.Encoder()
    encoder.dataEncodingStrategy = .deferredToData

    let testJSON = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDataWithCustomEncoder() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"\#(data.hexEncodedString())"}"#

    let encoder = JSON.Encoder()
    encoder.dataEncodingStrategy = .custom { data, encoder in
      var container = encoder.singleValueContainer()
      try container.encode(data.hexEncodedString())
    }

    let testJSON = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDataWithNothingCustomEncoder() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":null}"#

    let encoder = JSON.Encoder()
    encoder.dataEncodingStrategy = .custom { _, _ in
    }

    let testJSON = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePositiveBigInt() throws {

    let bigInt = BigInt(1234567)

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":\#(bigInt)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(bigInt: bigInt))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeBigInt() throws {

    let bigInt = BigInt(-1234567)

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":\#(bigInt)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(bigInt: bigInt))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeBigUInt() throws {

    let bigUInt = BigUInt(1234567)

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let json = #"{"bigUInt":\#(bigUInt)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(bigUInt: bigUInt))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePostiveDecimal() throws {

    let dec = Decimal(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var dec: Decimal
    }

    let json = #"{"dec":\#(dec)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeDecimal() throws {

    let dec = Decimal(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var dec: Decimal
    }

    let json = #"{"dec":\#(dec)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDecimalNaNWithStrategy() throws {

    let dec = Decimal.nan

    struct TestValue: Codable {
      var dec: Decimal
    }

    let json = #"{"dec":"nan"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNonConformingDecimalThrowsError() throws {

    let dec = Decimal.nan

    struct TestValue: Codable {
      var dec: Decimal
    }

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy = .throw

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(TestValue(dec: dec))) { error in
      AssertEncodingInvalidValue(error)
    }
  }

  func testEncodePostiveDouble() throws {

    let double = Double(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(double)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeDouble() throws {

    let double = Double(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(double)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDoubleNaNWithStrategy() throws {

    let double = Double.nan

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"nan"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(double: double))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDoublePositiveInfinityWithStrategy() throws {

    let double = Double.infinity

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"+inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(double: double))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeDoubleNegativeInfinityWithStrategy() throws {

    let double = -Double.infinity

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"-inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(double: double))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNonConformingDoubleThrowsError() throws {

    let double = Double.nan

    struct TestValue: Codable {
      var double: Double
    }

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy = .throw

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(TestValue(double: double))) { error in
      AssertEncodingInvalidValue(error)
    }
  }

  func testEncodePostiveFloat() throws {

    let float = Float(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(float)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeFloat() throws {

    let float = Float(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(float)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloatNaNWithStrategy() throws {

    let float = Float.nan

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"nan"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloatPositiveInfinityWithStrategy() throws {

    let float = Float.infinity

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"+inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloatNegativeInfinityWithStrategy() throws {

    let float = -Float.infinity

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"-inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNonConformingFloatThrowsError() throws {

    let float = Float.nan

    struct TestValue: Codable {
      var float: Float
    }

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy = .throw

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(TestValue(float: float))) { error in
      AssertEncodingInvalidValue(error)
    }
  }

  func testEncodePostiveFloat16() throws {

    let float = Float16(sign: .plus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(float)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeFloat16() throws {

    let float = Float16(sign: .minus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(float)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloat16NaNWithStrategy() throws {

    let float = Float16.nan

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"nan"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloat16PositiveInfinityWithStrategy() throws {

    let float = Float16.infinity

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"+inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeFloat16NegativeInfinityWithStrategy() throws {

    let float = -Float16.infinity

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"-inf"}"#

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy =
      .convertToString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testJSON = try encoder.encodeString(TestValue(float: float))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNonConformingFloat16ThrowsError() throws {

    let float = Float16.nan

    struct TestValue: Codable {
      var float: Float16
    }

    let encoder = JSON.Encoder()
    encoder.nonConformingFloatEncodingStrategy = .throw

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(TestValue(float: float))) { error in
      AssertEncodingInvalidValue(error)
    }
  }

  func testEncodePositiveInt8() throws {

    let int = Int8.max

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeInt8() throws {

    let int = Int8.min

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePositiveInt16() throws {

    let int = Int16.max

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeInt16() throws {

    let int = Int16.min

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePositiveInt32() throws {

    let int = Int32.max

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeInt32() throws {

    let int = Int32.min

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePositiveInt64() throws {

    let int = Int64.max

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeInt64() throws {

    let int = Int64.min

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodePositiveInt() throws {

    let int = Int.max

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNegativeInt() throws {

    let int = Int.min

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":\#(int)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUInt8() throws {

    let uint = UInt8.max

    struct TestValue: Codable {
      var uint: UInt8
    }

    let json = #"{"uint":\#(uint)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUInt16() throws {

    let uint = UInt16.max

    struct TestValue: Codable {
      var uint: UInt16
    }

    let json = #"{"uint":\#(uint)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUInt32() throws {

    let uint = UInt32.max

    struct TestValue: Codable {
      var uint: UInt32
    }

    let json = #"{"uint":\#(uint)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUInt64() throws {

    let uint = UInt64.max

    struct TestValue: Codable {
      var uint: UInt64
    }

    let json = #"{"uint":\#(uint)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUInt() throws {

    let uint = UInt.max

    struct TestValue: Codable {
      var uint: UInt
    }

    let json = #"{"uint":\#(uint)}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeURL() throws {

    let url = URL(string: "https://example.com/some/thing")!

    struct TestValue: Codable {
      var url: URL
    }

    let json = #"{"url":"\#(url.absoluteString)"}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(url: url))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeUUID() throws {

    let uuid = UUID()

    struct TestValue: Codable {
      var uuid: UUID
    }

    let json = #"{"uuid":"\#(uuid.uuidString)"}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(uuid: uuid))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNil() throws {

    struct TestValue: Codable {
      var null: Int? = .none

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .null)
      }
    }

    let json = #"{"null":null}"#

    let testJSON = try JSON.Encoder.default.encodeString(TestValue(null: nil))
    XCTAssertEqual(testJSON, json)
  }

  func testEncodeNonStringKeyedDictionary() throws {

    struct TestValue: Codable {
      var dict: [Int: Int]
    }

    XCTAssertNoThrow(try JSON.Encoder.default.encodeString(TestValue(dict: [1: 1])))
  }

  let prettyEncoder: JSON.Encoder = {
    let enc = JSON.Encoder()
    enc.outputFormatting = .prettyPrinted
    return enc
  }()

}
