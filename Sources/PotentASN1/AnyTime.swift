//
//  AnyTime.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// Allows encoding _any_ ASN.1 time value while controlling the specific ASN.1 type.
///
public struct AnyTime: Equatable, Hashable {


  public enum Kind: Int, Equatable, Hashable, Codable {
    case utc
    case generalized
  }


  public var kind: Kind?
  public var storage: Date

  public init(_ value: Date = Date(), kind: Kind? = nil) {
    self.kind = kind
    storage = value
  }

}


extension AnyTime: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    storage = try container.decode(Date.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(storage)
  }

}
