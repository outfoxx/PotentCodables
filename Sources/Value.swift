//
//  Value.swift
//  PotentCodables
//
//  Created by Kevin Wooten on 6/12/19.
//

import Foundation


/// `Value`s are the intermediary representation that
/// allows querying the structure in memory, decoding
/// it to a compatible `Decodable` type, or serializing
/// it to `Data`
public protocol Value : Hashable {

  var isNull: Bool { get }

  var unwrapped: Any? { get }

}
