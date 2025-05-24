//
//  Tagged.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// ASN.1 encoded data with tag describing its contents.
///
public struct TaggedValue: Codable, Equatable, Hashable {
  public var tag: UInt8
  public var data: Data

  public init(tag: UInt8, data: Data) {
    self.tag = tag
    self.data = data
  }
}
