//
//  YAMLSchema.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public protocol YAMLSchema {

  func isNull(_ string: String) -> Bool

  func isBool(_ string: String) -> Bool
  func isTrue(_ string: String) -> Bool
  func isFalse(_ string: String) -> Bool

  func isInt(_ string: String) -> Bool

  func isFloat(_ string: String) -> Bool
  func isNumber(_ string: String) -> Bool
  func isInfinity(_ string: String) -> Bool
  func isNaN(_ string: String) -> Bool
  
  func requiresQuotes(for string: String) -> Bool

}

public enum YAMLSchemas {
}
