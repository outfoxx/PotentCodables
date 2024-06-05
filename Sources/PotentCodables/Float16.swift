//
//  Float16.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

#if arch(x86_64) && (os(macOS) || os(Linux) || targetEnvironment(macCatalyst))

import Float16


/// Float16 shim for intel architectures
public typealias Float16 = float16


extension Float16: Codable {

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(try container.decode(Float.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(Float(self))
  }

}

extension Float16: LosslessStringConvertible {

  public init?(_ description: String) {
    guard let float = Float(description) else {
      return nil
    }
    self.init(float)
  }

}

#endif
