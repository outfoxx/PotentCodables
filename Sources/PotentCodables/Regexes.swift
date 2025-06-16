//
//  Pattern.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import Regex


extension Regex: @retroactive ExpressibleByStringLiteral {

  public init(stringLiteral value: StaticString) {
    self.init(value)
  }

}

extension Regex {

  public static func anyOf(_ regexes: Regex...) -> Regex {
    do {
      return try Regex(string: regexes.map { "(\($0.description))" }.joined(separator: "|"))
    }
    catch {
      preconditionFailure("unexpected error creating regex from joined set: \(error)")
    }
  }

}
