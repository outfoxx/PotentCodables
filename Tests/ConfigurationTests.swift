//
//  CBORReaderTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentJSON
import XCTest


@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
class ConfigurationTests: XCTestCase {

  struct LimitedString: CodableWithConfiguration {

    typealias EncodingConfiguration = Int
    typealias DecodingConfiguration = Int

    var value: String

    init(value: String) {
      self.value = value
    }

    enum CodingKeys: String, CodingKey {
      case value
    }

    init(from decoder: any Decoder, configuration: Int) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.value = try String(container.decode(String.self, forKey: .value).prefix(configuration))
    }

    func encode(to encoder: any Encoder, configuration: Int) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(String(value.prefix(configuration)), forKey: .value)
    }
  }

  struct Max5: EncodingConfigurationProviding, DecodingConfigurationProviding {
    static let encodingConfiguration: Int = 5
    static let decodingConfiguration: Int = 5
  }

  struct TestAnnotation: Codable {
    @CodableConfiguration(from: Max5.self)
    var string = LimitedString(value: "")
  }

  struct TestManual: Codable {
    var string = LimitedString(value: "")
    var optionalString: LimitedString?

    enum CodingKeys: CodingKey {
      case string
      case optionalString
    }

    init(string: LimitedString, optionalString: LimitedString?) {
      self.string = string
      self.optionalString = optionalString
    }

    init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.string = try container
        .decode(LimitedString.self, forKey: .string, configuration: 5)
      self.optionalString = try container
        .decodeIfPresent(LimitedString.self, forKey: .optionalString, configuration: 4)
    }

    func encode(to encoder: any Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(string, forKey: .string, configuration: 5)
      try container.encodeIfPresent(optionalString, forKey: .optionalString, configuration: 4)
    }
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  public func testEncodeTopLevelConfiguration() throws {

    let jsonTree = try JSON.Encoder.default.encodeTree(LimitedString(value: "12345678"), configuration: 5)
    XCTAssertEqual(jsonTree, .object(["value": "12345"]))

    let jsonData = try JSON.Encoder.default.encode(LimitedString(value: "12345678"), configuration: 5)
    XCTAssertEqual(jsonData, Data(#"{"value":"12345"}"#.utf8))

    let jsonString = try JSON.Encoder.default.encodeString(LimitedString(value: "12345678"), configuration: 5)
    XCTAssertEqual(jsonString, #"{"value":"12345"}"#)
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  public func testDecodeTopLevelConfiguration() throws {

    let stringFromTree = try JSON.Decoder.default
      .decodeTree(LimitedString.self, from: .object(["value": "12345678"]), configuration: 5)
    XCTAssertEqual(stringFromTree.value, "12345")

    let optStringFromTree = try JSON.Decoder.default
      .decodeTreeIfPresent(LimitedString.self, from: .object(["value": "12345678"]), configuration: 5)
    XCTAssertEqual(optStringFromTree?.value, "12345")

    let nilStringFromTree = try JSON.Decoder.default
      .decodeTreeIfPresent(LimitedString.self, from: .null, configuration: 5)
    XCTAssertEqual(nilStringFromTree?.value, nil)

    let stringFromData = try JSON.Decoder.default
      .decode(LimitedString.self, from: Data(#"{"value":"12345678"}"#.utf8), configuration: 5)
    XCTAssertEqual(stringFromData.value, "12345")

    let optStringFromData = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: Data(#"{"value":"12345678"}"#.utf8), configuration: 5)
    XCTAssertEqual(optStringFromData?.value, "12345")

    let nilStringFromData = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: Data(#"null"#.utf8), configuration: 5)
    XCTAssertEqual(nilStringFromData?.value, nil)

    let stringFromString = try JSON.Decoder.default
      .decode(LimitedString.self, from: #"{"value":"12345678"}"#, configuration: 5)
    XCTAssertEqual(stringFromString.value, "12345")

    let optStringFromString = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: #"{"value":"12345678"}"#, configuration: 5)
    XCTAssertEqual(optStringFromString?.value, "12345")

    let nilStringFromString = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: #"null"#, configuration: 5)
    XCTAssertEqual(nilStringFromString?.value, nil)
  }

  public func testEncodeTopLevelConfigurationProvider() throws {

    let jsonTree = try JSON.Encoder.default.encodeTree(LimitedString(value: "12345678"), configuration: Max5.self)
    XCTAssertEqual(jsonTree, .object(["value": "12345"]))

    let jsonData = try JSON.Encoder.default.encode(LimitedString(value: "12345678"), configuration: Max5.self)
    XCTAssertEqual(jsonData, Data(#"{"value":"12345"}"#.utf8))

    let jsonString = try JSON.Encoder.default.encodeString(LimitedString(value: "12345678"), configuration: Max5.self)
    XCTAssertEqual(jsonString, #"{"value":"12345"}"#)
  }

  @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
  public func testDecodeTopLevelConfigurationProvider() throws {

    let stringFromTree = try JSON.Decoder.default
      .decodeTree(LimitedString.self, from: .object(["value": "12345678"]), configuration: Max5.self)
    XCTAssertEqual(stringFromTree.value, "12345")

    let optStringFromTree = try JSON.Decoder.default
      .decodeTreeIfPresent(LimitedString.self, from: .object(["value": "12345678"]), configuration: Max5.self)
    XCTAssertEqual(optStringFromTree?.value, "12345")

    let nilStringFromTree = try JSON.Decoder.default
      .decodeTreeIfPresent(LimitedString.self, from: .null, configuration: 5)
    XCTAssertEqual(nilStringFromTree?.value, nil)

    let stringFromData = try JSON.Decoder.default
      .decode(LimitedString.self, from: Data(#"{"value":"12345678"}"#.utf8), configuration: Max5.self)
    XCTAssertEqual(stringFromData.value, "12345")

    let optStringFromData = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: Data(#"{"value":"12345678"}"#.utf8), configuration: Max5.self)
    XCTAssertEqual(optStringFromData?.value, "12345")

    let nilStringFromData = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: Data(#"null"#.utf8), configuration: Max5.self)
    XCTAssertEqual(nilStringFromData?.value, nil)

    let stringFromString = try JSON.Decoder.default
      .decode(LimitedString.self, from: #"{"value":"12345678"}"#, configuration: Max5.self)
    XCTAssertEqual(stringFromString.value, "12345")

    let optStringFromString = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: #"{"value":"12345678"}"#, configuration: Max5.self)
    XCTAssertEqual(optStringFromString?.value, "12345")

    let nilStringFromString = try JSON.Decoder.default
      .decodeIfPresent(LimitedString.self, from: #"null"#, configuration: Max5.self)
    XCTAssertEqual(nilStringFromString?.value, nil)
  }

  public func testEncodeConfiguredViaAnnotation() throws {

    let json = try JSON.Encoder.default.encodeString(TestAnnotation(string: .init(value: "12345678")))
    XCTAssertEqual(json, #"{"string":{"value":"12345"}}"#)
  }

  public func testDecodeConfiguredViaAnnotation() throws {

    let test = try JSON.Decoder.default.decode(TestAnnotation.self, from: #"{"string":{"value":"12345678"}}"#)
    XCTAssertEqual(test.string.value, "12345")
  }

  public func testEncodeConfiguredViaManualImplementatinon() throws {

    let json = try JSON.Encoder.default
      .encodeString(TestManual(string: .init(value: "12345678"), optionalString: nil))
    XCTAssertEqual(json, #"{"string":{"value":"12345"}}"#)

    let json2 = try JSON.Encoder.default
      .encodeString(TestManual(string: .init(value: "12345678"), optionalString: .init(value: "123456")))
    XCTAssertEqual(json2, #"{"string":{"value":"12345"},"optionalString":{"value":"1234"}}"#)
  }

  public func testDecodeConfiguredViaManualImplementatinon() throws {

    let test = try JSON.Decoder.default
      .decode(TestManual.self, from: #"{"string":{"value":"12345678"}}"#)
    XCTAssertEqual(test.string.value, "12345")
    XCTAssertEqual(test.optionalString?.value, nil)

    let test2 = try JSON.Decoder.default
      .decode(TestManual.self, from: #"{"string":{"value":"12345678"},"optionalString":{"value":"123456"}}"#)
    XCTAssertEqual(test2.string.value, "12345")
    XCTAssertEqual(test2.optionalString?.value, "1234")
  }

  struct InvalidValue: CodableWithConfiguration {
    typealias EncodingConfiguration = Int
    typealias DecodingConfiguration = Int
    init() {}
    init(from decoder: any Decoder, configuration: Int) throws {
    }
    func encode(to encoder: any Encoder, configuration: Int) throws {
    }
  }

  struct IntCP: EncodingConfigurationProviding, DecodingConfigurationProviding {
    static var encodingConfiguration: Int = 0
    static var decodingConfiguration: Int = 0
  }

  func testEncodeInvalidTreeValue() throws {

    XCTAssertThrowsError(try JSON.Encoder.default.encodeTree(InvalidValue(), configuration: 0)) { error in
      XCTAssertTrue(error is EncodingError)
    }

    XCTAssertThrowsError(try JSON.Encoder.default.encodeTree(InvalidValue(), configuration: IntCP.self)) { error in
      XCTAssertTrue(error is EncodingError)
    }
  }

  func testEncodeInvalidDataValue() throws {

    XCTAssertThrowsError(try JSON.Encoder.default.encode(InvalidValue(), configuration: 0)) { error in
      XCTAssertTrue(error is EncodingError)
    }

    XCTAssertThrowsError(try JSON.Encoder.default.encode(InvalidValue(), configuration: IntCP.self)) { error in
      XCTAssertTrue(error is EncodingError)
    }
  }

  func testEncodeInvalidStringValue() throws {

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(InvalidValue(), configuration: 0)) { error in
      XCTAssertTrue(error is EncodingError)
    }

    XCTAssertThrowsError(try JSON.Encoder.default.encodeString(InvalidValue(), configuration: IntCP.self)) { error in
      XCTAssertTrue(error is EncodingError)
    }
  }

  func testDecodeMissingTreeValue() throws {

    XCTAssertThrowsError(
      try JSON.Decoder.default.decodeTree(InvalidValue.self, from: nil, configuration: 0)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }

    XCTAssertThrowsError(
      try JSON.Decoder.default.decodeTree(InvalidValue.self, from: nil, configuration: Max5.self)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testDecodeMissingDataValue() throws {

    XCTAssertThrowsError(
      try JSON.Decoder.default.decode(InvalidValue.self, from: Data("null".utf8), configuration: 0)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }

    XCTAssertThrowsError(
      try JSON.Decoder.default.decode(InvalidValue.self, from: Data("null".utf8), configuration: Max5.self)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testDecodeMissingStringValue() throws {

    XCTAssertThrowsError(
      try JSON.Decoder.default.decode(InvalidValue.self, from: "null", configuration: 0)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }

    XCTAssertThrowsError(
      try JSON.Decoder.default.decode(InvalidValue.self, from: "null", configuration: Max5.self)
    ) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

}
