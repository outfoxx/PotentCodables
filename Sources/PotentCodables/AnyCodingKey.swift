//
//  AnyCodingKey.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

public struct AnyCodingKey: CodingKey, Equatable, Hashable {
  public var stringValue: String
  public var intValue: Int?

  public init?(stringValue: String) {
    self.stringValue = stringValue
    intValue = nil
  }

  public init(intValue: Int) {
    stringValue = "\(intValue)"
    self.intValue = intValue
  }

  public init(stringValue: String, intValue: Int?) {
    self.stringValue = stringValue
    self.intValue = intValue
  }

  public init(index: Int) {
    stringValue = "\(index)"
    intValue = index
  }

  public init<Key: CodingKey>(_ base: Key) {
    if let index = base.intValue {
      self.init(intValue: index)
    }
    else {
      self.init(stringValue: base.stringValue)!
    }
  }

  public func key<K: CodingKey>() -> K {
    if let intValue = self.intValue {
      return K(intValue: intValue)!
    }
    else {
      return K(stringValue: stringValue)!
    }
  }

  internal static let `super` = AnyCodingKey(stringValue: "super")!

}

extension AnyCodingKey: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if let intValue = self.intValue {
      try container.encode(intValue)
    }
    else {
      try container.encode(stringValue)
    }
  }
}

extension AnyCodingKey: Decodable {
  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer()
    if let intValue = try? value.decode(Int.self) {
      stringValue = "\(intValue)"
      self.intValue = intValue
    }
    else {
      stringValue = try! value.decode(String.self)
      intValue = nil
    }
  }
}

extension AnyCodingKey: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
  public init(stringLiteral value: String) {
    stringValue = value
  }

  public init(integerLiteral value: Int) {
    intValue = value
    stringValue = "\(value)"
  }
}
