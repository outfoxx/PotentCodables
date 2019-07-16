//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/26/19.
//

import Foundation


public protocol TaggedValue {

  var tagAndValue: (ASN1.AnyTag, Any?) { get }

  init?(tag: ASN1.AnyTag, value: Any?)

}
