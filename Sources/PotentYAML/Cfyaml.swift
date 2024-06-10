//
//  Cfyaml.swift
//  PotentCodables
//
//  Copyright © 2021 Outfox, inc.
//
//
//  Distributed under the MIT License, See LICENSE for details.
//

import Cfyaml


extension fy_emitter_cfg_flags {

  private static var indentMask = Self(UInt32(bitPattern: FYECF_INDENT_MASK))
  private static var indentShift = Self(UInt32(bitPattern: FYECF_INDENT_SHIFT))

  static func indent<R: RawRepresentable>(_ indent: R) -> Self where R.RawValue == UInt8 {
    .indent(indent.rawValue)
  }

  static func indent(_ indent: UInt8) -> Self {
    precondition(indent >= 0 && indent <= 9)
    return (Self(UInt32(indent)) & .indentMask) << .indentShift
  }

  private static var widthMask = Self(UInt32(bitPattern: FYECF_WIDTH_MASK))
  private static var widthShift = Self(UInt32(bitPattern: FYECF_WIDTH_SHIFT))

  static func width<R: RawRepresentable>(_ width: R) -> Self where R.RawValue == UInt8 {
    .width(width.rawValue)
  }

  static func width(_ width: UInt8) -> Self {
    return (Self(UInt32(width)) & .widthMask) << .widthShift
  }

  static prefix func ~(_ value: Self) -> Self {
    return Self(~value.rawValue)
  }

  static func &(_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue & right.rawValue)
  }

  static func |(_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue | right.rawValue)
  }

  static func <<(_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue << right.rawValue)
  }

}
