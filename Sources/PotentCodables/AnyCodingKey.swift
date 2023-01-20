//
//  AnyCodingKey.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

public struct AnyCodingKey: CodingKey, Equatable, Hashable {
  public var stringValue: String
  public var intValue: Int?

  public init(stringValue: String, intValue: Int?) {
    self.stringValue = stringValue
    self.intValue = intValue
  }

  public init(stringValue: String) {
    self.init(stringValue: stringValue, intValue: nil)
  }

  public init(intValue: Int) {
    self.init(stringValue: "\(intValue)", intValue: intValue)
  }

  public init(index: Int) {
    self.init(intValue: index)
  }

  public init<Key: CodingKey>(_ base: Key) {
    if let index = base.intValue {
      self.init(intValue: index)
    }
    else {
      self.init(stringValue: base.stringValue)
    }
  }

  // swiftlint:disable:next force_unwrapping
  public func key<K: CodingKey>() -> K {
    if let intValue = self.intValue {
      return K(intValue: intValue)!
    }
    else {
      return K(stringValue: stringValue)!
    }
  }

  internal static let `super` = AnyCodingKey(stringValue: "super")

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
