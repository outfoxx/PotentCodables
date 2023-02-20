//
//  JSONDecoderTests.swift
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


class JSONDecoderTests: XCTestCase {

  func testDecodeFromUTF8Data() {

    struct TestValue: Codable {
      var test: String
    }

    let json = #"{"test":"Hello World!"}"#

    let decoder = JSON.Decoder()
    decoder.keyDecodingStrategy = .useDefaultKeys

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: json.data(using: .utf8)!))
  }

  func testDecodeWithDefaultKeyStrategy() {

    struct TestValue: Codable {
      var camelCased: String
    }

    let json = #"{"camelCased":"Hello World!"}"#

    let decoder = JSON.Decoder()
    decoder.keyDecodingStrategy = .useDefaultKeys

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: json))
  }

  func testDecodeWithSnakeCaseKeyStrategy() {

    struct TestValue: Codable {
      var snakeCased: String
    }

    let json = #"{"snake_cased":"Hello World!"}"#

    let decoder = JSON.Decoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: json))
  }

  func testDecodeWithCustomKeyStrategy() {

    struct TestValue: Codable {
      var kebabCased: String
    }

    let json = #"{"kebab-cased":"Hello World!"}"#

    let decoder = JSON.Decoder()
    decoder.keyDecodingStrategy = .custom { _ in
      return AnyCodingKey(stringValue: "kebabCased")
    }

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: json))
  }

  func testDecodeISO8601Date() throws {

    let date = ZonedDate(date: Date(), timeZone: .utc)
    let parsedDate = ZonedDate(iso8601Encoded: date.iso8601EncodedString())!

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"\#(parsedDate.iso8601EncodedString())"}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .iso8601

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.date, parsedDate.utcDate)
  }

  func testDecodeEpochSecondsDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSince1970)}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .secondsSince1970

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeEpochMillisecondsDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSince1970 * 1000)}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual((testValue.date.timeIntervalSince1970 * 1000.0).rounded(),
                   (date.timeIntervalSince1970 * 1000.0).rounded())
  }

  func testDecodeDeferredToDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSinceReferenceDate)}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .deferredToDate

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeWithCustomDecoder() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":\#(date.timeIntervalSince1970)}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .custom {
      Date(timeIntervalSince1970: try $0.singleValueContainer().decode(Double.self))
    }

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeWithFormatter() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date().truncatedToMillisecs

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"\#(formatter.string(from: date))"}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .formatted(formatter)

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual((testValue.date.timeIntervalSince1970 * 1000.0).rounded(),
                   (date.timeIntervalSince1970 * 1000.0).rounded())
  }

  func testDecodeBadFormattedDate() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date().truncatedToMillisecs

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"\#(date)"}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .formatted(formatter)

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeBadISO8601Date() throws {

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":"2020 Wed 09"}"#

    let decoder = JSON.Decoder()
    decoder.dateDecodingStrategy = .iso8601

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeDateFromNull() throws {

    struct TestValue: Codable {
      var date: Date
    }

    let json = #"{"date":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBase64Data() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"\#(data.base64EncodedString())"}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .base64

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeBase64DataUnpadded() throws {

    let data = "1234".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"\#(data.base64EncodedString().replacingOccurrences(of: "=", with: ""))"}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .base64

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeDeferredToData() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":[\#(data.map { String($0) }.joined(separator: ", "))]}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .deferredToData

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeCustomData() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"\#(data.hexEncodedString())"}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .custom { decoder in
      return Data(hexEncoded: try decoder.singleValueContainer().decode(String.self))
    }

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeBadBase64Data() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":"This is not base64"}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .base64

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeIncorrectBase64Data() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":[1, 2, 3, 4, 5]}"#

    let decoder = JSON.Decoder()
    decoder.dataDecodingStrategy = .base64

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDataFromNull() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let json = #"{"data":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURL() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let json = #"{"url":"https://example.com/some/thing"}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.url, URL(string: "https://example.com/some/thing"))
  }

  func testDecodeBadURL() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let json = #"{"url":"Not a URL"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeURLFromNonString() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let json = #"{"url":12345}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeURLFromNull() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let json = #"{"url":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUID() throws {

    let uuid = UUID()

    struct TestValue: Codable {
      var uuid: UUID
    }

    let json = #"{"uuid":"\#(uuid.uuidString)"}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.uuid, uuid)
  }

  func testDecodeBadUUID() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let json = #"{"uuid":"Not a UUID"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeUUIDFromNonString() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let json = #"{"uuid":12345}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUUIDFromNull() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let json = #"{"uuid":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeString() throws {

    let string = "Hello World!"

    struct TestValue: Codable {
      var string: String
    }

    let json = #"{"string":"\#(string)"}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.string, string)
  }

  func testDecodeStringFromNonString() throws {

    struct TestValue: Codable {
      var string: String
    }

    let json = #"{"string":12345}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeStringFromNull() throws {

    struct TestValue: Codable {
      var string: String
    }

    let json = #"{"string":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimalFromPositiveDecimal() throws {

    let decimal = Decimal(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":\#(decimal.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.decimal, decimal)
  }

  func testDecodeDecimalFromNegativeDecimal() throws {

    let decimal = Decimal(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":\#(decimal.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.decimal, decimal)
  }

  func testDecodeDecimalFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.decimal, Decimal(sign: .plus, exponent: 0, significand: Decimal(integer)))
  }

  func testDecodeDecimalFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.decimal, Decimal(sign: .minus, exponent: 0, significand: Decimal(integer.magnitude)))
  }

  func testDecodeDecimalFromNaNWithStrategy() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.decimal, Decimal.nan)
  }

  func testDecodeNonConformingDecimalThrowsError() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy = .throw

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalFromNonNumber() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalFromNull() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let json = #"{"decimal":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDoubleFromPositiveDecimal() throws {

    let double = Double(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(double.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, double)
  }

  func testDecodeDoubleFromNegativeDecimal() throws {

    let double = Double(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(double.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, double)
  }

  func testDecodeDoubleFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, Double(sign: .plus, exponent: 0, significand: Double(integer)))
  }

  func testDecodeDoubleFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, Double(sign: .minus, exponent: 0, significand: Double(integer.magnitude)))
  }

  func testDecodeDoubleFromNaNWithStrategy() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertTrue(testValue.double.isNaN)
  }

  func testDecodeDoubleFromPositiveInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"+inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, Double.infinity)
  }

  func testDecodeDoubleFromNegativeInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"-inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.double, -Double.infinity)
  }

  func testDecodeNonConformingDoubleThrowsError() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy = .throw

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDoubleFromNonNumber() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDoubleFromNull() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let json = #"{"double":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloatFromPositiveDecimal() throws {

    let float = Float(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(float.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloatFromNegativeDecimal() throws {

    let float = Float(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(float.description)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloatFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float(sign: .plus, exponent: 0, significand: Float(integer)))
  }

  func testDecodeFloatFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float(sign: .minus, exponent: 0, significand: Float(integer.magnitude)))
  }

  func testDecodeFloatFromNaNWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertTrue(testValue.float.isNaN)
  }

  func testDecodeFloatFromPositiveInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"+inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float.infinity)
  }

  func testDecodeFloatFromNegativeInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"-inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, -Float.infinity)
  }

  func testDecodeNonConformingFloatThrowsError() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy = .throw

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloatFromNonNumber() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloatFromNull() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let json = #"{"float":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat16FromPositiveDecimal() throws {

    let float = Float16(sign: .plus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(float)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloat16FromNegativeDecimal() throws {

    let float = Float16(sign: .minus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(float)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloat16FromPositiveInteger() throws {

    let integer = 1234

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float16(sign: .plus, exponent: 0, significand: Float16(integer)))
  }

  func testDecodeFloat16FromNegativeInteger() throws {

    let integer = -1234

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float16(sign: .minus, exponent: 0, significand: Float16(integer.magnitude)))
  }

  func testDecodeFloat16FromNaNWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertTrue(testValue.float.isNaN)
  }

  func testDecodeFloat16FromPositiveInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"+inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, Float16.infinity)
  }

  func testDecodeFloat16FromNegativeInfinityWithStrategy() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"-inf"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy =
      .convertFromString(positiveInfinity: "+inf", negativeInfinity: "-inf", nan: "nan")

    let testValue = try decoder.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.float, -Float16.infinity)
  }

  func testDecodeNonConformingFloat16ThrowsError() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"nan"}"#

    let decoder = JSON.Decoder()
    decoder.nonConformingFloatDecodingStrategy = .throw

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloat16FromNonNumber() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloat16FromNull() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let json = #"{"float":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat16FromNullItem() throws {

    struct TestValue: Codable {
      init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try container.decode(Float16.self)
      }
      func encode(to encoder: Encoder) throws {
      }
    }

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.bigInt, BigInt(integer))
  }

  func testDecodeBigIntFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.bigInt, BigInt(integer))
  }

  func testDecodeBigIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeBigIntFromNonNumber() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigIntFromNull() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let json = #"{"bigInt":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUIntFromInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let json = #"{"bigUInt":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.bigUInt, BigUInt(integer))
  }

  func testDecodeBigUIntFromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let json = #"{"bigUInt":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeBigUIntFromNonNumber() throws {

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let json = #"{"bigUInt":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigUIntFromNull() throws {

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let json = #"{"bigUInt":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, UInt(integer))
  }

  func testDecodeUIntFromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt
    }

    let json = #"{"int":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNull() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt64
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, UInt64(integer))
  }

  func testDecodeUInt64FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt64
    }

    let json = #"{"int":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNull() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt32
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, UInt32(integer))
  }

  func testDecodeUInt32FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt32
    }

    let json = #"{"int":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNull() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16FromPositiveInteger() throws {

    let integer = 65432

    struct TestValue: Codable {
      var int: UInt16
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, UInt16(integer))
  }

  func testDecodeUInt16FromNegativeIntegerFails() throws {

    let integer = -65432

    struct TestValue: Codable {
      var int: UInt16
    }

    let json = #"{"int":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNull() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8FromPositiveInteger() throws {

    let integer = 234

    struct TestValue: Codable {
      var int: UInt8
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, UInt8(integer))
  }

  func testDecodeUInt8FromNegativeIntegerFails() throws {

    let integer = -234

    struct TestValue: Codable {
      var int: UInt8
    }

    let json = #"{"int":\#(integer)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNull() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int(integer))
  }

  func testDecodeIntFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int(integer))
  }

  func testDecodeIntFromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":\#(UInt(Int.max) + 1)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromNull() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int64(integer))
  }

  func testDecodeInt64FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int64(integer))
  }

  func testDecodeInt64FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":\#(UInt64(Int64.max) + 1)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNull() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int32(integer))
  }

  func testDecodeInt32FromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int32(integer))
  }

  func testDecodeInt32FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":\#(UInt32(Int32.max) + 1)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNull() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16FromPositiveInteger() throws {

    let integer = 32101

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int16(integer))
  }

  func testDecodeInt16FromNegativeInteger() throws {

    let integer = -32101

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int16(integer))
  }

  func testDecodeInt16FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":\#(UInt16(Int16.max) + 1)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNull() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8FromPositiveInteger() throws {

    let integer = 123

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int8(integer))
  }

  func testDecodeInt8FromNegativeInteger() throws {

    let integer = -123

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":\#(integer)}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.int, Int8(integer))
  }

  func testDecodeInt8FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":\#(UInt8(Int8.max) + 1)}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":123.456}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":"Not a Number"}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNull() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let json = #"{"int":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBool() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let json = #"{"bool":true}"#

    let testValue = try JSON.Decoder.default.decode(TestValue.self, from: json)
    XCTAssertEqual(testValue.bool, true)
  }

  func testDecodeBoolFromNonBoolean() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let json = #"{"bool":1}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBoolFromNull() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let json = #"{"bool":null}"#

    XCTAssertThrowsError(try JSON.Decoder.default.decode(TestValue.self, from: json)) { error in
      AssertDecodingValueNotFound(error)
    }
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

    XCTAssertThrowsError(try JSON.Decoder.default.decodeTree(TestValue.self, from: .array([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

}
