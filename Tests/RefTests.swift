//
//  RefTests.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

@testable import PotentCodables
@testable import PotentJSON
import XCTest


protocol RefTestValue {}

struct AValue: RefTestValue, Codable {
  let name: String

  init(name: String) {
    self.name = name
  }
}

struct BValue: RefTestValue, Codable {
  let values: [String]
}


class RefTests: XCTestCase {

  override class func setUp() {
    DefaultTypeIndex.addAllowedTypes([AValue.self, BValue.self])
  }

  func testRef() throws {

    let src = AValue(name: "test")

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(AValue(name: "test")))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json.value?.name, "test")

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testNestedRef() throws {

    struct TestValue: Codable {
      var value: RefTestValue

      init(value: RefTestValue) {
        self.value = value
      }

      enum CodingKeys: CodingKey {
        case value
      }

      init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Ref.self, forKey: .value).as(RefTestValue.self)
      }

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Ref.Value(value), forKey: .value)
      }
    }

    let src = TestValue(value: AValue(name: "test"))

    let json = try JSON.Encoder.default.encodeTree(src)
    XCTAssertNotNil(json["value"]?["@type"], "AValue")
    XCTAssertEqual(json.value?.value?.name, "test")

    let testValue = try JSONDecoder.default.decodeTree(TestValue.self, from: json)
    XCTAssertEqual((testValue.value as? AValue)?.name, (src.value as? AValue)?.name)
  }

  func testCustomRef() throws {

    struct MyTypeKeys: TypeKeyProvider, ValueKeyProvider {
      static var typeKey: AnyCodingKey = "_type"
      static var valueKey: AnyCodingKey = "_value"
    }
    typealias MyRef = CustomRef<MyTypeKeys, MyTypeKeys, DefaultTypeIndex>

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(MyRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json._type)
    XCTAssertEqual(json._value?.name, "test")

    let ref = try JSONDecoder.default.decodeTree(MyRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testEmbeddedRef() throws {

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(EmbeddedRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json.name, "test")

    let ref = try JSONDecoder.default.decodeTree(EmbeddedRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testCustomEmbeddedRef() throws {

    struct MyTypeKey: TypeKeyProvider {
      static var typeKey: AnyCodingKey = "_type"
    }
    typealias MyRef = CustomEmbeddedRef<MyTypeKey, DefaultTypeIndex>

    let src = AValue(name: "test")

    let json = try JSONEncoder.default.encodeTree(MyRef.Value(AValue(name: "test")))
    XCTAssertNotNil(json._type)
    XCTAssertEqual(json.name, "test")

    let ref = try JSONDecoder.default.decodeTree(MyRef.self, from: json)

    XCTAssertNoThrow(try ref.as(RefTestValue.self)) // Ensure retrieving as protocol is allowed
    XCTAssertEqual(src.name, try ref.as(AValue.self).name)
  }

  func testRefUnkeyed() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value([1, 2, 3]))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .array([1, 2, 3]))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as([Int].self), [1, 2, 3])
  }

  func testRefSingleBool() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(true))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .bool(true))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Bool.self), true)
  }

  func testRefSingleInt() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(1))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Int.self), 1)
  }

  func testRefSingleInt8() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Int8(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Int8.self), 1)
  }

  func testRefSingleInt16() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Int16(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Int16.self), 1)
  }

  func testRefSingleInt32() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Int32(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Int32.self), 1)
  }

  func testRefSingleInt64() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Int64(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Int64.self), 1)
  }

  func testRefSingleUInt() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(UInt(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(UInt.self), 1)
  }

  func testRefSingleUInt8() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(UInt8(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(UInt8.self), 1)
  }

  func testRefSingleUInt16() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(UInt16(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(UInt16.self), 1)
  }

  func testRefSingleUInt32() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(UInt32(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(UInt32.self), 1)
  }

  func testRefSingleUInt64() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(UInt64(1)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(UInt64.self), 1)
  }

  func testRefSingleString() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value("test"))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .string("test"))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(String.self), "test")
  }

  func testRefSingleFloat16() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Float16(1.0)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1.0))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Float16.self), 1)
  }

  func testRefSingleFloat() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Float(1.0)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1.0))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Float.self), 1)
  }

  func testRefSingleDouble() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(Double(1.0)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .number(1.0))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as(Double.self), 1)
  }

  func testRefSingleNil() throws {

    let nullValue: RefTestValue? = nil
    let json = try JSON.Encoder.default.encodeTree(Ref.Value(nullValue))
    XCTAssertEqual(json, .null)

    let ref = try JSONDecoder.default.decodeTreeIfPresent(Ref.self, from: json)

    XCTAssertNil(ref)
  }

  func testRefSingleBoolArray() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value([true, false]))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .array([true, false]))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as([Bool].self), [true, false])
  }

  func testRefSingleIntArray() throws {

    let json = try JSON.Encoder.default.encodeTree(Ref.Value([1, 0]))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .array([1, 0]))

    let ref = try JSONDecoder.default.decodeTree(Ref.self, from: json)

    XCTAssertEqual(try ref.as([Int].self), [1, 0])
  }

  func testRefDecodeFailsWhenTypeNotAuthorized() throws {

    struct TestValue: Codable {
      var value: Bool
    }

    let json = try JSON.Encoder.default.encodeTree(Ref.Value(TestValue(value: true)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .object(["value": true]))

    XCTAssertThrowsError(try JSONDecoder.default.decodeTree(Ref.self, from: json))
  }

  func testEmbeddedRefSingleNil() throws {

    let nullValue: RefTestValue? = nil
    let json = try JSON.Encoder.default.encodeTree(EmbeddedRef.Value(nullValue))
    XCTAssertEqual(json, .null)

    let ref = try JSONDecoder.default.decodeTreeIfPresent(EmbeddedRef.self, from: json)

    XCTAssertNil(ref)
  }

  func testEmbeddedRefDecodeFailsWhenTypeNotAuthorized() throws {

    struct TestValue: Codable {
      var value: Bool
    }

    let json = try JSON.Encoder.default.encodeTree(EmbeddedRef.Value(TestValue(value: true)))
    XCTAssertNotNil(json["@type"])
    XCTAssertEqual(json["value"], .bool(true))

    XCTAssertThrowsError(try JSONDecoder.default.decodeTree(EmbeddedRef.self, from: json))
  }

}
