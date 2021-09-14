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

import Foundation
import PotentCodables


/// ASN.1 `OBJECT IDENTIFIER` value (aka `OID`).
///
public struct ObjectIdentifier: Equatable, Hashable {

  public var fields: [UInt64]

  public init(_ fields: [UInt64]) {
    self.fields = fields
  }

  public init?(_ string: String) {
    var fields = [UInt64]()
    for num in string.split(separator: ".") {
      guard let field = UInt64(num) else { return nil }
      fields.append(field)
    }
    self.fields = fields
  }

  public var asn1: ASN1 {
    return .objectIdentifier(fields)
  }

}

public typealias OID = ObjectIdentifier


extension ObjectIdentifier: CustomStringConvertible {

  public var description: String {
    return fields.map { "\($0)" }.joined(separator: ".")
  }

}

extension ObjectIdentifier: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    fields = Self(try container.decode(String.self))?.fields ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(self)")
  }

}

extension ObjectIdentifier: ExpressibleByArrayLiteral, ExpressibleByStringLiteral {

  public init(arrayLiteral elements: UInt64...) {
    fields = elements
  }

  public init(stringLiteral value: String) {
    guard let oid = Self(value) else {
      fatalError("Invalid OBJECT IDENTIFIER field: \(value)")
    }
    self = oid
  }

}
