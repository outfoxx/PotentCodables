//
//  YAMLReader.swift
//  
//
//  Created by Kevin Wooten on 9/2/20.
//

import Foundation
import Cfyaml

public enum YAMLReader {
  
  public static func read(data: Data) throws -> [YAML] {
    
    var parseCfg = fy_parse_cfg(search_path: nil, flags: fy_parse_cfg_flags(rawValue: 0), userdata: nil, diag: nil)
    
    guard let parser = fy_parser_create(&parseCfg).map({ Parser(rawParser: $0) }) else {
      fatalError("Unable to create parser")
    }
    defer { parser.destroy() }
    
    return try data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
      
      let bytes = ptr.bindMemory(to: Int8.self)
      
      fy_parser_set_string(parser.rawParser, bytes.baseAddress, bytes.count)
      
      _ = try parser.expect(eventType: FYET_STREAM_START)
      
      return try stream(parser: parser)
    }
  }
  
  
  static func stream(parser: Parser) throws -> [YAML] {
    
    var documents: [YAML] = []
    
    while (true) {
      
      let event = try parser.next()
      defer { parser.free(event: event) }
      
      guard event.type != FYET_STREAM_END else {
        return documents
      }
      
      switch event.type {
      case FYET_DOCUMENT_START:
        documents.append(try document(parser: parser))
        break
        
      default:
        throw YAML.Error.unexpectedEvent
      }
    }
    
  }
  
  
  static func document(parser: Parser) throws -> YAML {
    
    let root = try parser.next()
    defer { parser.free(event: root) }
    
    let document = try value(event: root, parser: parser)
    
    _ = try parser.expect(eventType: FYET_DOCUMENT_END)
    
    return document
  }
  
  
  static func mapping(parser: Parser) throws -> [YAML.MapEntry] {
    
    var result: [YAML.MapEntry] = []
    
    while (true) {
      
      let event = try parser.next()
      defer { parser.free(event: event) }
      
      guard event.type != FYET_MAPPING_END else {
        return result
      }
      
      let key = try value(event: event, parser: parser)
      
      let valEvent = try parser.next()
      defer { parser.free(event: valEvent) }
      
      let val = try value(event: valEvent, parser: parser)
      
      result.append(YAML.MapEntry(key: key, value: val))
    }
    
  }
  
  
  static func sequence(parser: Parser) throws -> [YAML] {
    
    var result: [YAML] = []
    
    while (true) {
      
      let event = try parser.next()
      defer { parser.free(event: event) }
      
      guard event.type != FYET_SEQUENCE_END else {
        return result
      }
      
      let val = try value(event: event, parser: parser)
      
      result.append(val)
    }
  }
  
  static let nullRegex = RegEx(pattern: #"^(null|Null|NULL|~)$"#)!
  static let trueRegex = RegEx(pattern: #"^(true|True|TRUE)$"#)!
  static let falseRegex = RegEx(pattern: #"^(false|False|FALSE)$"#)!
  static let integerRegex = RegEx(pattern: #"^(([-+]?[0-9]+)|(0o[0-7]+)|(0x[0-9a-fA-F]+))$"#)!
  static let floatRegex = RegEx(pattern: #"^([-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?)$"#)!
  static let infinityRegex = RegEx(pattern: #"^([-+]?(\.inf|\.Inf|\.INF))$"#)!
  static let nanRegex = RegEx(pattern: #"^(\.nan|\.NaN|\.NAN)$"#)!

  static func scalar(value: String, style: fy_scalar_style, tag: YAML.Tag?, anchor: String?) -> YAML {
    let stringStyle = YAML.StringStyle(rawValue: style.rawValue)!
    
    switch tag {
    case .none:

      if style == FYSS_PLAIN {
        
        if nullRegex.matches(string: value) {
          return .null(anchor: anchor)
        }
        
        if trueRegex.matches(string: value) {
          return .bool(true, anchor: anchor)
        }
        
        if falseRegex.matches(string: value) {
          return .bool(false, anchor: anchor)
        }

        if integerRegex.matches(string: value) {
          return .integer(YAML.Number(value), anchor: anchor)
        }

        if floatRegex.matches(string: value) {
          return .float(YAML.Number(value), anchor: anchor)
        }
        
        if infinityRegex.matches(string: value) {
          return .float(YAML.Number(value), anchor: anchor)
        }
        
        if nanRegex.matches(string: value) {
          return .float(YAML.Number(value), anchor: anchor)
        }

      }
      
      return .string(value, style: stringStyle, tag: nil, anchor: nil)

    case .some(YAML.Tag.null):
      return .null(anchor: anchor)
      
    case .some(YAML.Tag.bool):
      return .bool(Bool(value.lowercased())!, anchor: anchor)
      
    case .some(YAML.Tag.int):
      return .integer(YAML.Number(value), anchor: anchor)
      
    case .some(YAML.Tag.float):
      return .float(YAML.Number(value), anchor: anchor)
      
    case .some(let tag):
      return .string(value, style: stringStyle, tag: tag, anchor: anchor)
    }
    
  }

  static func value(event: Parser.Event, parser: Parser) throws -> YAML {
    switch event.type {
    case FYET_MAPPING_START:
      let value = try mapping(parser: parser)
      return .mapping(value, style: event.style.collectionStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)
      
    case FYET_SEQUENCE_START:
      let value = try sequence(parser: parser)
      return .sequence(value, style: event.style.collectionStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)
      
    case FYET_SCALAR:
      guard let (scalarValue, scalarStyle) = event.scalar else {
        return .null(anchor: event.anchor)
      }
      return scalar(value: scalarValue, style: scalarStyle, tag: YAML.Tag(event.tag), anchor: event.anchor)
      
    case FYET_ALIAS:
      return YAML.alias(event.tag ?? "")
      
    default:
      throw YAML.Error.unexpectedEvent
    }
    
  }
  
  struct Parser {
    
    struct Event {
      let rawEvent: UnsafeMutablePointer<fy_event>
      
      var type: fy_event_type { rawEvent.pointee.type }
      
      var anchor: String? {
        guard let token = rawEvent.pointee.scalar.anchor else { return nil }
        guard let anchor = String(token: token) else {
          fatalError()
        }
        return anchor
      }
      
      var tag: String? {
        guard let token = rawEvent.pointee.scalar.tag else { return nil }
        guard let anchor = String(token: token) else {
          fatalError()
        }
        return anchor
      }
      
      var scalar: (String, fy_scalar_style)? {
        guard let token = rawEvent.pointee.scalar.value else { return nil }
        guard let anchor = String(token: token) else {
          fatalError()
        }
        return (anchor, fy_token_scalar_style(token))
      }
      
      var style: fy_node_style {
        return fy_event_get_node_style(rawEvent)
      }
      
    }
    
    let rawParser: OpaquePointer
    
    func nextIfPresent() -> Event? {
      return fy_parser_parse(rawParser).map { Event(rawEvent: $0) }
    }
    
    func next() throws -> Event {
      guard let event = nextIfPresent() else {
        throw YAML.Error.unexpectedEOF
      }
      return event
    }
    
    func expect(eventType: fy_event_type) throws -> Event {
      
      let event = try next()
      
      if (event.type != eventType) {
        throw YAML.Error.unexpectedEvent
      }
      
      return event
    }
    
    func destroy() {
      fy_parser_destroy(rawParser)
    }
    
    func free(event: Event) {
      fy_parser_event_free(rawParser, event.rawEvent)
    }
    
  }

}

extension String {
  
  init?(token: OpaquePointer) {
    var tokenLen = 0
    guard let tokenData = fy_token_get_text(token, &tokenLen) else {
      fatalError()
    }
    self.init(data: Data(bytes: UnsafeRawPointer(tokenData), count: tokenLen), encoding: .utf8)
  }
  
}


class RegEx {
  
  public struct Options : OptionSet {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }
    
    public static let basic            = Options([])
    public static let extended         = Options(rawValue: 1 << 0)
    public static let caseInsensitive  = Options(rawValue: 1 << 1)
    public static let resultOnly       = Options(rawValue: 1 << 2)
    public static let newLineSensitive = Options(rawValue: 1 << 3)
  }
  
  public struct MatchOptions : OptionSet {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }
    
    public static let firstCharacterNotAtBeginningOfLine = MatchOptions(rawValue: REG_NOTBOL)
    public static let lastCharacterNotAtEndOfLine        = MatchOptions(rawValue: REG_NOTEOL)
  }

  private var regex = regex_t()
  
  init?(pattern: String, options: Options = [.extended]) {
    let res = pattern.withCString { patternPtr in
      regcomp(&regex, patternPtr, options.rawValue)
    }
    guard res == 0 else {
      return nil
    }
  }
  
  deinit {
    regfree(&regex)
  }
  
  func matches(string: String, options: MatchOptions = []) -> Bool {
    return string.withCString { stringPtr in
      return regexec(&regex, stringPtr, 0, nil, options.rawValue) == 0
    }
  }
  
}

extension fy_node_style {
  
  var collectionStyle: YAML.CollectionStyle {
    switch self {
    case FYNS_FLOW: return .flow
    case FYNS_BLOCK: return .block
    default: return .block
    }
  }
  
}
