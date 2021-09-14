/*
 * MIT License
 *
 * Copyright 2021 Outfox, inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public struct AnyCodingKey: CodingKey, Equatable, Hashable {
  public var stringValue: String
  public var intValue: Int?

  public init(stringValue: String) {
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
      stringValue = try value.decode(String.self)
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
