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
public struct AnyTime: Equatable, Hashable, Codable {


  public enum Kind: Int, Equatable, Hashable, Codable {
    case utc
    case generalized
  }


  public var kind: Kind?
  public var zonedDate: ZonedDate

  public init(_ zonedDate: ZonedDate, kind: Kind? = nil) {
    self.kind = kind
    self.zonedDate = zonedDate
  }

  public init(date: Date, timeZone: TimeZone, kind: Kind? = nil) {
    self.kind = kind
    self.zonedDate = ZonedDate(date: date, timeZone: timeZone)
  }

}
