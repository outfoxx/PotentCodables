//
//  Tag.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public protocol TaggedValue {

  var tag: ASN1.AnyTag { get }
  var value: Any? { get }

  /// Encode the value accroding to the schema
  func encode(schema: Schema) throws -> ASN1

  init?(tag: ASN1.AnyTag, value: Any?)

}
