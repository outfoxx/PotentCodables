//
//  RawValueDecodingContainer.swift
//  PotentCodables
//
//  Copyright © 2019 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Foundation


protocol RawValueDecodingContainer: SingleValueDecodingContainer {

  func decodeRawValue() -> Any?

}
