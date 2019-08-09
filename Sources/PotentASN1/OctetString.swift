//
//  OctetString.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// ASN.1 `OCTET STRING` value.
///
public struct OctetString: Equatable, Hashable {

  public let value: Data?

  public init(value: Data? = nil) {
    self.value = value
  }
}


extension OctetString: Codable {

  public enum CodingKeys: String, CodingKey {
    case value
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: TaggedItemKeys.self)
    value = try container.decodeIfPresent(Data.self, expectingTag: ASN1.Tag.octetString, nullTag: ASN1.Tag.null)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: TaggedItemKeys.self)
    try container.encode(value, withTag: ASN1.Tag.octetString)
  }

}
