//
//  YAMLSchemaCore.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation
import PotentCodables
import Regex


extension YAMLSchema where Self == YAMLSchemas.Core {

  public static var core: Self { .instance }
}

extension YAMLSchemas {

  public enum Core: YAMLSchema {
    case instance

    static let nullRegex: Regex = #"^((null)|(Null)|(NULL)|(~)|(^$))$"#

    static let boolRegex: Regex = .anyOf(trueRegex, falseRegex)
    static let trueRegex: Regex = #"^((true)|(True)|(TRUE))$"#
    static let falseRegex: Regex = #"^((false)|(False)|(FALSE))$"#

    static let int8Regex: Regex = #"^(0o[0-7]+)$"#
    static let int10Regex: Regex = #"^([-+]?[0-9]+)$"#
    static let int16Regex: Regex = #"^(0x[0-9a-fA-F]+)$"#
    static let intRegex: Regex = .anyOf(int8Regex, int10Regex, int16Regex)

    static let numRegex: Regex = #"^([-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?)$"#
    static let infRegex: Regex = #"^([-+]?((\.inf)|(\.Inf)|(\.INF)))$"#
    static let nanRegex: Regex = #"^((\.nan)|(\.NaN)|(\.NAN))$"#
    static let floatRegex: Regex = .anyOf(numRegex, infRegex, nanRegex)

    public func isNull(_ string: String) -> Bool { Self.nullRegex.matches(string) }

    public func isBool(_ string: String) -> Bool { Self.boolRegex.matches(string) }
    public func isTrue(_ string: String) -> Bool { Self.trueRegex.matches(string) }
    public func isFalse(_ string: String) -> Bool { Self.falseRegex.matches(string) }

    public func isInt(_ string: String) -> Bool { Self.intRegex.matches(string) }

    public func isFloat(_ string: String) -> Bool { Self.floatRegex.matches(string) }
    public func isNumber(_ string: String) -> Bool { Self.numRegex.matches(string) }
    public func isInfinity(_ string: String) -> Bool { Self.infRegex.matches(string) }
    public func isNaN(_ string: String) -> Bool { Self.nanRegex.matches(string) }

    public func requiresQuotes(for string: String) -> Bool {
      isNull(string) || isBool(string) || isInt(string) || isFloat(string)
    }
  }

}
