//
//  YAMLEncoderTests.swift
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


class YAMLEncoderTests: XCTestCase {

  func testEncodeWithDefaultKeyStrategy() {

    struct TestValue: Codable {
      var camelCased: String
    }

    let yaml =
    """
    ---
    camelCased: Hello World!
    ...

    """

    let encoder = YAML.Encoder()
    encoder.keyEncodingStrategy = .useDefaultKeys

    XCTAssertEqual(try encoder.encodeString(TestValue(camelCased: "Hello World!")), yaml)
  }

  func testEncodeWithSnakeCaseKeyStrategy() {

    struct TestValue: Codable {
      var snakeCased: String
    }

    let yaml =
    """
    ---
    snake_cased: Hello World!
    ...

    """

    let encoder = YAML.Encoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase

    XCTAssertEqual(try encoder.encodeString(TestValue(snakeCased: "Hello World!")), yaml)
  }

  func testEncodeWithCustomKeyStrategy() {

    struct TestValue: Codable {
      var kebabCased: String
    }

    let yaml =
    """
    ---
    kebab-cased: Hello World!
    ...

    """

    let encoder = YAML.Encoder()
    encoder.keyEncodingStrategy = .custom { _ in
      return AnyCodingKey(stringValue: "kebab-cased")
    }

    XCTAssertEqual(try encoder.encodeString(TestValue(kebabCased: "Hello World!")), yaml)
  }

  func testEncodeToString() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
    }

    let yaml =
    """
    ---
    int: 5
    string: Hello World!
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue())
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeToStringWithSortedKeysOption() throws {

    struct TestValue: Codable {
      var c = 1
      var a = 2
      var b = 3
    }

    let yaml =
    """
    ---
    a: 2
    b: 3
    c: 1
    ...

    """

    let encoder = YAML.Encoder()
    encoder.outputFormatting = .sortedKeys

    let testYAML = try encoder.encodeString(TestValue())
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeToData() throws {

    struct TestValue: Codable {
      var int = 5
      var string = "Hello World!"
    }

    let yaml =
    """
    ---
    int: 5
    string: Hello World!
    ...

    """

    let testYAMLData = try YAML.Encoder.default.encode(TestValue())
    XCTAssertEqual(testYAMLData, yaml.data(using: .utf8)!)
  }

  func testEncodeToDataWithSortedKeysOption() throws {

    struct TestValue: Codable {
      var c = 1
      var a = 2
      var b = 3
    }

    let yaml =
    """
    ---
    a: 2
    b: 3
    c: 1
    ...

    """

    let encoder = YAML.Encoder()
    encoder.outputFormatting = .sortedKeys

    let testYAMLData = try encoder.encode(TestValue())
    XCTAssertEqual(testYAMLData, yaml.data(using: .utf8))
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

    let yaml =
    """
    ---
    b: 5
    d: Hello World!
    a: true
    c:
      b: 5
      d: Hello World!
      a: true
      c:
        b: 5
        d: Hello World!
        a: true
    ...

    """

    let testValue = TestValue(c: TestValue(c: TestValue()))

    let testYAML = try YAML.Encoder.default.encodeString(testValue)
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateAsISO8601() throws {

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

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .iso8601

    let testYAML = try encoder.encodeString(TestValue(date: parsedDate.utcDate))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateAsEpochSeconds() throws {

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

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .secondsSince1970

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateAsEpochMilliseconds() throws {

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

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .millisecondsSince1970

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateWithDeferredToDate() throws {

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

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .deferredToDate

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateWithFormatter() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: \(formatter.string(from: date))
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .formatted(formatter)

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateWithCustomEncoder() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

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

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
      var container = encoder.singleValueContainer()
      try container.encode(date.timeIntervalSinceReferenceDate)
    }

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDateWithNothingCustomEncoder() throws {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS XXXX"

    let date = Date()

    struct TestValue: Codable {
      var date: Date
    }

    let yaml =
    """
    ---
    date: {}
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dateEncodingStrategy = .custom { _, _ in
      // do nothing
    }

    let testYAML = try encoder.encodeString(TestValue(date: date))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDataAsBase64() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: \(data.base64EncodedString())
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dataEncodingStrategy = .base64

    let testYAML = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDataWithDeferredToData() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data:
    \(data.map { "- \($0)" }.joined(separator: "\n"))
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dataEncodingStrategy = .deferredToData

    let testYAML = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDataWithCustomEncoder() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: \(data.hexEncodedString())
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dataEncodingStrategy = .custom { data, encoder in
      var container = encoder.singleValueContainer()
      try container.encode(data.hexEncodedString())
    }

    let testYAML = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDataWithNothingCustomEncoder() throws {

    let data = Data([1, 2, 3, 4, 5])

    struct TestValue: Codable {
      var data: Data
    }

    let yaml =
    """
    ---
    data: {}
    ...

    """

    let encoder = YAML.Encoder()
    encoder.dataEncodingStrategy = .custom { _, _ in
    }

    let testYAML = try encoder.encodeString(TestValue(data: data))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveBigInt() throws {

    let bigInt = BigInt(1234567)

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: \(bigInt)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(bigInt: bigInt))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeBigInt() throws {

    let bigInt = BigInt(-1234567)

    struct TestValue: Codable {
      var bigInt: BigInt
    }

    let yaml =
    """
    ---
    bigInt: \(bigInt)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(bigInt: bigInt))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeBigUInt() throws {

    let bigUInt = BigUInt(1234567)

    struct TestValue: Codable {
      var bigUInt: BigUInt
    }

    let yaml =
    """
    ---
    bigUInt: \(bigUInt)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(bigUInt: bigUInt))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePostiveDecimal() throws {

    let dec = Decimal(sign: .plus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var dec: Decimal
    }

    let yaml =
    """
    ---
    dec: \(dec)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeDecimal() throws {

    let dec = Decimal(sign: .minus, exponent: -3, significand: 1234567)

    struct TestValue: Codable {
      var dec: Decimal
    }

    let yaml =
    """
    ---
    dec: \(dec)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDecimalNaN() throws {

    let dec = Decimal.nan

    struct TestValue: Codable {
      var dec: Decimal
    }

    let yaml =
    """
    ---
    dec: .nan
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(dec: dec))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePostiveDouble() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeDouble() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDoubleNaN() throws {

    let double = Double.nan

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: .nan
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDoublePositiveInfinity() throws {

    let double = Double.infinity

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: +.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeDoubleNegativeInfinity() throws {

    let double = -Double.infinity

    struct TestValue: Codable {
      var double: Double
    }

    let yaml =
    """
    ---
    double: -.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(double: double))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePostiveFloat() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeFloat() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloatNaN() throws {

    let float = Float.nan

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: .nan
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloatPositiveInfinity() throws {

    let float = Float.infinity

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: +.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloatNegativeInfinity() throws {

    let float = -Float.infinity

    struct TestValue: Codable {
      var float: Float
    }

    let yaml =
    """
    ---
    float: -.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePostiveFloat16() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeFloat16() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloat16NaN() throws {

    let float = Float16.nan

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: .nan
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloat16PositiveInfinity() throws {

    let float = Float16.infinity

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: +.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeFloat16NegativeInfinity() throws {

    let float = -Float16.infinity

    struct TestValue: Codable {
      var float: Float16
    }

    let yaml =
    """
    ---
    float: -.inf
    ...

    """

    let testYAML = try YAMLEncoder.default.encodeString(TestValue(float: float))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveInt8() throws {

    let int = Int8.max

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeInt8() throws {

    let int = Int8.min

    struct TestValue: Codable {
      var int: Int8
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveInt16() throws {

    let int = Int16.max

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeInt16() throws {

    let int = Int16.min

    struct TestValue: Codable {
      var int: Int16
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveInt32() throws {

    let int = Int32.max

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeInt32() throws {

    let int = Int32.min

    struct TestValue: Codable {
      var int: Int32
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveInt64() throws {

    let int = Int64.max

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeInt64() throws {

    let int = Int64.min

    struct TestValue: Codable {
      var int: Int64
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodePositiveInt() throws {

    let int = Int.max

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNegativeInt() throws {

    let int = Int.min

    struct TestValue: Codable {
      var int: Int
    }

    let yaml =
    """
    ---
    int: \(int)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(int: int))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUInt8() throws {

    let uint = UInt8.max

    struct TestValue: Codable {
      var uint: UInt8
    }

    let yaml =
    """
    ---
    uint: \(uint)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUInt16() throws {

    let uint = UInt16.max

    struct TestValue: Codable {
      var uint: UInt16
    }

    let yaml =
    """
    ---
    uint: \(uint)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUInt32() throws {

    let uint = UInt32.max

    struct TestValue: Codable {
      var uint: UInt32
    }

    let yaml =
    """
    ---
    uint: \(uint)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUInt64() throws {

    let uint = UInt64.max

    struct TestValue: Codable {
      var uint: UInt64
    }

    let yaml =
    """
    ---
    uint: \(uint)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUInt() throws {

    let uint = UInt.max

    struct TestValue: Codable {
      var uint: UInt
    }

    let yaml =
    """
    ---
    uint: \(uint)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uint: uint))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeURL() throws {

    let url = URL(string: "https://example.com/some/thing")!

    struct TestValue: Codable {
      var url: URL
    }

    let yaml =
    """
    ---
    url: \(url.absoluteString)
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(url: url))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeUUID() throws {

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

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(uuid: uuid))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNil() throws {

    struct TestValue: Codable {
      var null: Int? = .none

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeNil(forKey: .null)
      }
    }

    let yaml =
    """
    ---
    null: null
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(TestValue(null: nil))
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeAnyDictionary() throws {

    let dict: AnyValue.AnyDictionary = ["b": 1, "z": 2, "n": 3, "f": 4]

    let yaml =
    """
    ---
    b: 1
    z: 2
    n: 3
    f: 4
    ...

    """

    let testYAML = try YAML.Encoder.default.encodeString(dict)
    XCTAssertEqual(testYAML, yaml)
  }

  func testEncodeNonStringKeyedDictionary() throws {

    struct TestValue: Codable {
      var dict: [Int: Int]
    }

    XCTAssertNoThrow(try YAML.Encoder.default.encodeString(TestValue(dict: [1: 1])))
  }

}
