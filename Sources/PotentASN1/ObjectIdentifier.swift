//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/13/19.
//

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
    self.fields = Self(try container.decode(String.self))?.fields ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode("\(self)")
  }

}

extension ObjectIdentifier: ExpressibleByArrayLiteral, ExpressibleByStringLiteral {

  public init(arrayLiteral elements: UInt64...) {
    self.fields = elements
  }

  public init(stringLiteral value: String) {
    guard let oid = Self(value) else {
      fatalError("Invalid OBJECT IDENTIFIER field: \(value)")
    }
    self = oid
  }

}

