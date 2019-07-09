//
//  AnyCodingKey.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

struct AnyCodingKey: CodingKey, Equatable, Hashable {
  var stringValue: String
  var intValue: Int?

  init?(stringValue: String) {
    self.stringValue = stringValue
    intValue = nil
  }

  init(intValue: Int) {
    stringValue = "\(intValue)"
    self.intValue = intValue
  }

  init(stringValue: String, intValue: Int?) {
    self.stringValue = stringValue
    self.intValue = intValue
  }

  init(index: Int) {
    stringValue = "Index \(index)"
    intValue = index
  }

  init<Key: CodingKey>(_ base: Key) {
    if let index = base.intValue {
      self.init(intValue: index)
    }
    else {
      self.init(stringValue: base.stringValue)!
    }
  }

  func key<K: CodingKey>() -> K {
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
  func encode(to encoder: Encoder) throws {
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
  init(from decoder: Decoder) throws {
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

