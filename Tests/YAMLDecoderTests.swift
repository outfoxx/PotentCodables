//
//  YAMLDecoderTests.swift
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
import PotentYAML
import XCTest


class YAMLDecoderTests: XCTestCase {

  func testDecodeFromUTF8Data() {

    struct TestValue: Codable {
      var test: String
    }

    let yaml =
    """
    test: Hello World!
    """

    let decoder = YAML.Decoder()
    decoder.keyDecodingStrategy = .useDefaultKeys

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: yaml.data(using: .utf8)!))
  }

  func testDecodeWithDefaultKeyStrategy() {

    struct TestValue: Codable {
      var camelCased: String
    }

    let yaml =
    """
    camelCased: Hello World!
    """

    let decoder = YAML.Decoder()
    decoder.keyDecodingStrategy = .useDefaultKeys

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: yaml))
  }

  func testDecodeWithSnakeCaseKeyStrategy() {

    struct TestValue: Codable {
      var snakeCased: String
    }

    let yaml =
    """
    snake_cased: Hello World!
    """

    let decoder = YAML.Decoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: yaml))
  }

  func testDecodeWithCustomKeyStrategy() {

    struct TestValue: Codable {
      var kebabCased: String
    }

    let yaml =
    """
    kebab-cased: Hello World!
    """

    let decoder = YAML.Decoder()
    decoder.keyDecodingStrategy = .custom { _ in
      return AnyCodingKey(stringValue: "kebabCased")
    }

    XCTAssertNoThrow(try decoder.decode(TestValue.self, from: yaml))
  }

  func testDecodeISO8601Date() throws {

    let date = ZonedDate(date: Date(), timeZone: .utc)
    let parsedDate = ZonedDate(iso8601Encoded: date.iso8601EncodedString())!

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(parsedDate.iso8601EncodedString())
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .iso8601

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.date, parsedDate.utcDate)
  }

  func testDecodeEpochSecondsDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(date.timeIntervalSince1970)
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .secondsSince1970

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeEpochMillisecondsDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(date.timeIntervalSince1970 * 1000.0)
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual((testValue.date.timeIntervalSince1970 * 1000.0).rounded(),
                   (date.timeIntervalSince1970 * 1000.0).rounded())
  }

  func testDecodeDeferredToDate() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(date.timeIntervalSinceReferenceDate)
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .deferredToDate

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeWithCustomDecoder() throws {

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(date.timeIntervalSince1970)
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .custom {
      Date(timeIntervalSince1970: try $0.singleValueContainer().decode(Double.self))
    }

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.date.timeIntervalSince1970, date.timeIntervalSince1970)
  }

  func testDecodeWithFormatter() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date().truncatedToMillisecs

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(formatter.string(from: date))
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .formatted(formatter)

    let testValue = try decoder.decode(TestValue.self, from: yaml)
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

    let yaml =
    """
    ---
    date: \(date)
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .formatted(formatter)

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeBadISO8601Date() throws {

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: 2020 Wed 09
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dateDecodingStrategy = .iso8601

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeDateFromNull() throws {

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBase64Data() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: \(data.base64EncodedString())
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .base64

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeBase64DataUnpadded() throws {

    let data = "1234".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: \(data.base64EncodedString().replacingOccurrences(of: "=", with: ""))
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .base64

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeDeferredToData() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: [\(data.map { String($0) }.joined(separator: ", "))]
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .deferredToData

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeCustomData() throws {

    let data = "Hello World!".data(using: .utf8)!

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: \(data.hexEncodedString())
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .custom { decoder in
      return Data(hexEncoded: try decoder.singleValueContainer().decode(String.self))
    }

    let testValue = try decoder.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.data, data)
  }

  func testDecodeBadBase64Data() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: This is not base64
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .base64

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeIncorrectBase64Data() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: [1, 2, 3, 4, 5]
    ...

    """

    let decoder = YAML.Decoder()
    decoder.dataDecodingStrategy = .base64

    XCTAssertThrowsError(try decoder.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDataFromNull() throws {

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeURL() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let yaml =
    """
    ---
    url: https://example.com/some/thing
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.url, URL(string: "https://example.com/some/thing"))
  }

  func testDecodeBadURL() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let yaml =
    """
    ---
    url: Not a URL
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeURLFromNonString() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let yaml =
    """
    ---
    url: 12345
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeURLFromNull() throws {

    struct TestValue: Codable {
      var url: URL
    }

    let yaml =
    """
    ---
    url: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUUID() throws {

    let uuid = UUID()

    struct TestValue: Codable {
      var uuid: UUID
    }

    let yaml =
    """
    ---
    uuid: \(uuid.uuidString)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.uuid, uuid)
  }

  func testDecodeBadUUID() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let yaml =
    """
    ---
    uuid: Not a UUID
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

  func testDecodeUUIDFromNonString() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let yaml =
    """
    ---
    uuid: 12345
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUUIDFromNull() throws {

    struct TestValue: Codable {
      var uuid: UUID
    }

    let yaml =
    """
    ---
    uuid: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeString() throws {

    let string = "Hello World!"

    struct TestValue: Codable {
      var string: String
    }

    let yaml =
    """
    ---
    string: \(string)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.string, string)
  }

  func testDecodeStringFromNonString() throws {

    struct TestValue: Codable {
      var string: String
    }

    let yaml =
    """
    ---
    string: 12345
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeStringFromNull() throws {

    struct TestValue: Codable {
      var string: String
    }

    let yaml =
    """
    ---
    string: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDecimalFromPositiveDecimal() throws {

    let decimal = Decimal(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: \(decimal)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.decimal, decimal)
  }

  func testDecodeDecimalFromNegativeDecimal() throws {

    let decimal = Decimal(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: \(decimal)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.decimal, decimal)
  }

  func testDecodeDecimalFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.decimal, Decimal(sign: .plus, exponent: 0, significand: Decimal(integer)))
  }

  func testDecodeDecimalFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.decimal, Decimal(sign: .minus, exponent: 0, significand: Decimal(integer.magnitude)))
  }

  func testDecodeDecimalFromNaN() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: .nan
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertTrue(testValue.decimal.isNaN)
  }

  func testDecodeNonConformingDecimalThrowsError() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: +.inf
    ...

    """

    XCTAssertThrowsError(try YAMLDecoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalFromNonNumber() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDecimalFromNull() throws {

    struct TestValue: Codable {
      var decimal: Decimal
    }

    let yaml =
    """
    ---
    decimal: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeDoubleFromPositiveDecimal() throws {

    let double = Double(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: \(double)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, double)
  }

  func testDecodeDoubleFromNegativeDecimal() throws {

    let double = Double(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: \(double)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, double)
  }

  func testDecodeDoubleFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, Double(sign: .plus, exponent: 0, significand: Double(integer)))
  }

  func testDecodeDoubleFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, Double(sign: .minus, exponent: 0, significand: Double(integer.magnitude)))
  }

  func testDecodeDoubleFromNaN() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: .nan
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertTrue(testValue.double.isNaN)
  }

  func testDecodeDoubleFromPositiveInfinity() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: +.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, Double.infinity)
  }

  func testDecodeDoubleFromNegativeInfinity() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: -.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.double, -Double.infinity)
  }

  func testDecodeDoubleFromNonNumber() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeDoubleFromNull() throws {

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloatFromPositiveDecimal() throws {

    let float = Float(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: \(float)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloatFromNegativeDecimal() throws {

    let float = Float(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: \(float)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloatFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float(sign: .plus, exponent: 0, significand: Float(integer)))
  }

  func testDecodeFloatFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float(sign: .minus, exponent: 0, significand: Float(integer.magnitude)))
  }

  func testDecodeFloatFromNaN() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: .nan
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertTrue(testValue.float.isNaN)
  }

  func testDecodeFloatFromPositiveInfinity() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: +.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float.infinity)
  }

  func testDecodeFloatFromNegativeInfinity() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: -.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, -Float.infinity)
  }

  func testDecodeFloatFromNonNumber() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloatFromNull() throws {

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeFloat16FromPositiveDecimal() throws {

    let float = Float16(sign: .plus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: \(float)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloat16FromNegativeDecimal() throws {

    let float = Float16(sign: .minus, exponent: -3, significand: 1234)

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: \(float)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, float)
  }

  func testDecodeFloat16FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float16(sign: .plus, exponent: 0, significand: Float16(integer)))
  }

  func testDecodeFloat16FromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float16(sign: .minus, exponent: 0, significand: Float16(integer.magnitude)))
  }

  func testDecodeFloat16FromNaN() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: .nan
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertTrue(testValue.float.isNaN)
  }

  func testDecodeFloat16FromPositiveInfinity() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: +.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, Float16.infinity)
  }

  func testDecodeFloat16FromNegativeInfinity() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: -.inf
    ...

    """

    let testValue = try YAMLDecoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.float, -Float16.infinity)
  }

  func testDecodeFloat16FromNonNumber() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeFloat16FromNull() throws {

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.bigInt, BigInt(integer))
  }

  func testDecodeBigIntFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.bigInt, BigInt(integer))
  }

  func testDecodeBigIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigIntFromNonNumber() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigIntFromNull() throws {

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBigUIntFromInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let yaml =
    """
    ---
    bigUInt: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.bigUInt, BigUInt(integer))
  }

  func testDecodeBigUIntFromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let yaml =
    """
    ---
    bigUInt: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigUIntFromNonNumber() throws {

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let yaml =
    """
    ---
    bigUInt: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBigUIntFromNull() throws {

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let yaml =
    """
    ---
    bigUInt: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, UInt(integer))
  }

  func testDecodeUIntFromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUIntFromNull() throws {

    struct TestValue: Codable {
      var int: UInt
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt64FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt64
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, UInt64(integer))
  }

  func testDecodeUInt64FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt64
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt64FromNull() throws {

    struct TestValue: Codable {
      var int: UInt64
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt32FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: UInt32
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, UInt32(integer))
  }

  func testDecodeUInt32FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: UInt32
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt32FromNull() throws {

    struct TestValue: Codable {
      var int: UInt32
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt16FromPositiveInteger() throws {

    let integer = 65432

    struct TestValue: Codable {
      var int: UInt16
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, UInt16(integer))
  }

  func testDecodeUInt16FromNegativeIntegerFails() throws {

    let integer = -65432

    struct TestValue: Codable {
      var int: UInt16
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt16FromNull() throws {

    struct TestValue: Codable {
      var int: UInt16
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeUInt8FromPositiveInteger() throws {

    let integer = 234

    struct TestValue: Codable {
      var int: UInt8
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, UInt8(integer))
  }

  func testDecodeUInt8FromNegativeIntegerFails() throws {

    let integer = -234

    struct TestValue: Codable {
      var int: UInt8
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNonNumber() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeUInt8FromNull() throws {

    struct TestValue: Codable {
      var int: UInt8
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntFromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int(integer))
  }

  func testDecodeIntFromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int(integer))
  }

  func testDecodeIntFromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: \(UInt(Int.max) + 1)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeIntFromNull() throws {

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt64FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int64(integer))
  }

  func testDecodeInt64FromNegativeIntegerFails() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int64(integer))
  }

  func testDecodeInt64FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: \(UInt64(Int64.max) + 1)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt64FromNull() throws {

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt32FromPositiveInteger() throws {

    let integer = 1234567

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int32(integer))
  }

  func testDecodeInt32FromNegativeInteger() throws {

    let integer = -1234567

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int32(integer))
  }

  func testDecodeInt32FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: \(UInt32(Int32.max) + 1)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt32FromNull() throws {

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt16FromPositiveInteger() throws {

    let integer = 32101

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int16(integer))
  }

  func testDecodeInt16FromNegativeInteger() throws {

    let integer = -32101

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int16(integer))
  }

  func testDecodeInt16FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: \(UInt16(Int16.max) + 1)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt16FromNull() throws {

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeInt8FromPositiveInteger() throws {

    let integer = 123

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int8(integer))
  }

  func testDecodeInt8FromNegativeInteger() throws {

    let integer = -123

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: \(integer)
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.int, Int8(integer))
  }

  func testDecodeInt8FromOverflowFails() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: \(UInt8(Int8.max) + 1)
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromDecimalFails() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: 123.456
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNonNumber() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: Not a Number
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeInt8FromNull() throws {

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeBool() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let yaml =
    """
    ---
    bool: true
    ...

    """

    let testValue = try YAML.Decoder.default.decode(TestValue.self, from: yaml)
    XCTAssertEqual(testValue.bool, true)
  }

  func testDecodeBoolFromNonBoolean() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let yaml =
    """
    ---
    bool: 1
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
      AssertDecodingTypeMismatch(error)
    }
  }

  func testDecodeBoolFromNull() throws {

    struct TestValue: Codable {
      var bool: Bool
    }

    let yaml =
    """
    ---
    bool: null
    ...

    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode(TestValue.self, from: yaml)) { error in
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

    XCTAssertThrowsError(try YAML.Decoder.default.decodeTree(TestValue.self, from: .sequence([nil]))) { error in
      AssertDecodingValueNotFound(error)
    }
  }

  func testDecodeIntKeyedMap() throws {

    let yaml =
    """
    1: a
    2: b
    """

    XCTAssertEqual(
      try YAML.Decoder.default.decode([String: String].self, from: yaml),
      ["1": "a", "2": "b"]
    )
  }

  func testDecodeInvalidKeyedMap() throws {

    let yaml =
    """
    null: a
    2: b
    """

    XCTAssertThrowsError(try YAML.Decoder.default.decode([String: String].self, from: yaml)) { error in
      AssertDecodingDataCorrupted(error)
    }
  }

}
