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


enum Libfyaml {

  internal static func createParser() -> OpaquePointer? {

    guard let diag = createDiag(options: (FYET_ERROR, false, true)) else {
      return nil
    }
    defer { fy_diag_unref(diag) }

    var parseCfg = fy_parse_cfg(
      search_path: nil,
      flags: FYPCF_QUIET,
      userdata: nil,
      diag: diag
    )

    return fy_parser_create(&parseCfg)
  }

  internal typealias EmitterWriter = (String?) -> Void

  internal typealias EmitterOutput = @convention(c) (
    OpaquePointer?,
    fy_emitter_write_type,
    UnsafePointer<Int8>?,
    Int32,
    UnsafeMutableRawPointer?
  ) -> Int32

  internal static func createEmitter(
    flags: fy_emitter_cfg_flags,
    output: EmitterOutput,
    writer: UnsafePointer<EmitterWriter>
  ) -> OpaquePointer? {

    guard let diag = createDiag(options: (FYET_ERROR, false, false)) else {
      return nil
    }
    defer { fy_diag_unref(diag) }

    var cfg = fy_emitter_cfg(
      flags: flags,
      output: output,
      userdata: UnsafeMutableRawPointer(mutating: writer),
      diag: diag
    )

    return fy_emitter_create(&cfg)
  }

  internal typealias DiagOptions = (level: fy_error_type, showSource: Bool, showPosition: Bool)

  internal static func createDiag(options: DiagOptions) -> OpaquePointer? {

    var diagCfg = fy_diag_cfg(
      fp: nil,
      output_fn: nil,
      user: nil,
      level: FYET_ERROR,
      module_mask: UInt32.max,
      colorize: false,
      show_source: options.showSource,
      show_position: options.showPosition,
      show_type: false,
      show_module: false,
      source_width: Int32.max,
      position_width: 4,
      type_width: 0,
      module_width: 0
    )

    guard let diag = fy_diag_create(&diagCfg) else {
      return nil
    }

    fy_diag_set_collect_errors(diag, true)

    return diag
  }


}

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

  static prefix func ~ (_ value: Self) -> Self {
    return Self(~value.rawValue)
  }

  static func & (_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue & right.rawValue)
  }

  static func | (_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue | right.rawValue)
  }

  static func << (_ left: Self, _ right: Self) -> Self {
    return Self(rawValue: left.rawValue << right.rawValue)
  }

}
