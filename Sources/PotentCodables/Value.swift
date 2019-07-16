//
//  Value.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


/// `Value`s are the intermediary representation that
/// allows querying the structure in memory, decoding
/// it to a compatible `Decodable` type, or serializing
/// it to `Data`
public protocol Value: Hashable {

  var isNull: Bool { get }

  var unwrapped: Any? { get }

}
