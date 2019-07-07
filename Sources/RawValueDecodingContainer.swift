//
//  RawValueDecodingContainer.swift
//  
//
//  Created by Kevin Wooten on 7/6/19.
//

import Foundation


protocol RawValueDecodingContainer : SingleValueDecodingContainer {

  func decodeRawValue() -> Any?

}
