//
//  SchemaSpecified.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public protocol SchemaSpecified {

  static var asn1Schema: Schema { get }

}

public extension SchemaSpecified where Self: Encodable {

  func encoded() throws -> Data {
    return try ASN1Encoder.encode(self)
  }

}
