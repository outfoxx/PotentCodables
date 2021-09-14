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

  var tagAndValue: (ASN1.AnyTag, Any?) { get }

  init?(tag: ASN1.AnyTag, value: Any?)

}
