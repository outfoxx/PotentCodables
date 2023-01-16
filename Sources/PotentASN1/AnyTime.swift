//
//  AnyTime.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables


/// Allows encoding _any_ ASN.1 time value while allowing control of the
/// specific ASN.1 tag.
///
public struct AnyTime: Equatable, Hashable, Codable {

  /// Kind of ASN.1 time.
  ///
  /// Controls the specific ASN.1 tag used in encoded form.
  public enum Kind: Int, Equatable, Hashable, Codable {
    ///
    case utc
    /// Time in `YYYYMMDDHH[MM[SS[.fff]]]` format with optional time zone.
    ///
    /// The optional time can be specified as UTC ('Z') or an offset
    /// (`+-HHMM`). Without a time zone the time is considered local.
    case generalized
  }


  /// Specifies the exact ``Kind`` of time.
  ///
  /// When encoding, selects the specific kind when the schema allows
  /// for multiple kinds of times.
  ///
  /// When decoding, reports the specific kind of time that was decoded.
  ///
  public var kind: Kind?
  /// String value
  public var zonedDate: ZonedDate

  /// Initialize with a ``ZonedDate`` and explicit ASN.1 kind.
  public init(_ zonedDate: ZonedDate, kind: Kind? = nil) {
    self.kind = kind
    self.zonedDate = zonedDate
  }

  /// Initialize with a date, time zone and explicit ASN.1 kind.
  public init(date: Date, timeZone: TimeZone, kind: Kind? = nil) {
    self.kind = kind
    zonedDate = ZonedDate(date: date, timeZone: timeZone)
  }

}
