//
//  TreeValueDecodingContainer.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


public protocol TreeValueDecodingContainer: SingleValueDecodingContainer {

  func decodeUnwrappedValue() -> Any?
  
  func decodeTreeValue() -> Any?

}
