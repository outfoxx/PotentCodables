//
//  File.swift
//  
//
//  Created by Kevin Wooten on 7/23/19.
//

import Foundation
import PotentCodables


public struct SchemaState {

  public enum SchemaError: Error {

    public struct Context {
      public let codingPath: [CodingKey]
      public let debugDescription: String
    }

    case noVersionDefined(String)
    case noVersion(SchemaError.Context)
    case noDynamicTypeDefined(String)
    case noDynamicType(SchemaError.Context)
    case undefinedField(String, SchemaError.Context)
    case structureMismatch(SchemaError.Context)
    case versionCheck(SchemaError.Context)
    case unknownDynamicType(SchemaError.Context)
    case ambiguousImplicitTag(SchemaError.Context)
  }

  class Scope {
    let container: KeyedContainer
    var versionFieldName: String?
    var typeFieldName: String?

    init(container: KeyedContainer) {
      self.container = container
    }
  }

  enum State: CustomStringConvertible {
    case schema(Schema)
    case disallowed(Schema)
    case nothing

    var description: String {
      switch self {
      case .schema(let schema): return String(describing: schema)
      case .nothing: return "NONE"
      case .disallowed(let schema): return String(describing: schema)
      }
    }
  }

  internal private(set) var keyStack: [CodingKey] = []
  private var stateStack: [[State]] = []
  private var scopes: [[String]:Scope] = [:]
  private var containers: [[String]:Any?] = [:]


  init(initial: Schema) throws {
    self.stateStack.append(try expand(schema: initial))
  }

  var count: Int { keyStack.count }
  var currentKey: CodingKey { keyStack.last! }
  var currentPossibleStates: [State] { stateStack.last! }

  mutating func removeLast(count: Int = 1) {
    stateStack.removeLast(count)
    keyStack.removeLast(count)
  }

  func container(forCodingPath codingPath: [CodingKey]) -> Any? {
    return containers[codingPath.map { $0.stringValue }] ?? nil
  }

  mutating func save(container: Any?, forCodingPath codingPath: [CodingKey]) {
    containers[codingPath.map { $0.stringValue }] = container
  }

  private var nearestScope: Scope? {
    var path = keyStack.map { $0.stringValue }
    while let _ = path.popLast() {
      if let scope = scopes[path] {
        return scope
      }
    }
    return nil
  }

  mutating func save(scope container: KeyedContainer, forCodingPath codingPath: [CodingKey]) {
    let path = codingPath.map { $0.stringValue }
    guard !scopes.keys.contains(path) else { return }

    scopes[path] = Scope(container: container)
  }

  mutating func removeScope(forCodingPath codingPath: [CodingKey]) {
    scopes.removeValue(forKey: codingPath.map { $0.stringValue })
  }

  mutating func step(into container: Any?, key: CodingKey) throws {
    guard let currentPossibleStates = stateStack.last else { return }

    if let keyed = container as? KeyedContainer {
      save(scope: keyed, forCodingPath: keyStack)
    }

    keyStack.append(key)

    do {
      var nextPossibleStates: [State] = []

      for possibleState in currentPossibleStates {
        guard case .schema(let possibleSchema) = possibleState else {
          nextPossibleStates.append(possibleState)
          continue
        }

        let expandedPossibleStates = try step(into: possibleSchema)
        nextPossibleStates.append(contentsOf: expandedPossibleStates)
      }

      stateStack.append(nextPossibleStates)
    }
    catch {
      keyStack.removeLast()
    }
  }

  private func step(into schema: Schema) throws -> [State] {

    switch schema {

    case .sequence(let fields):

      guard currentKey.intValue == nil else {
        fatalError("Not a collection")
      }

      let fieldName = currentKey.stringValue
      guard let fieldSchema = fields[fieldName] else {
        throw SchemaError.undefinedField(fieldName, errorContext("Field is not defined in schema"))
      }

      return try expand(schema: fieldSchema)


    case .sequenceOf(let elementSchema, _):

      guard currentKey.intValue != nil else {
        throw SchemaError.structureMismatch(errorContext("SEQUENCE OF required, SEQUENCE encountered"))
      }

      return try expand(schema: elementSchema)


    case .setOf(let elementSchema, _):

      guard currentKey.intValue != nil else {
        throw SchemaError.structureMismatch(errorContext("SET OF required, SEQUENCE encountered"))
      }

      return try expand(schema: elementSchema)

    case .implicit(_, in: _, let schema), .explicit(_, in: _, let schema):
      return try step(into: schema)

    default:
      fatalError("state stack corrupt, stepping into scalar schema")
    }

  }

  private func expand(schema: Schema) throws -> [State] {

    switch schema {

    case .choiceOf(let options):
      return try options.flatMap { option in try expand(schema: option) }


    case .optional(let schema):
      let optional = try expand(schema: schema)
      return optional + [.nothing]


    case .type(let typeSchema):
      guard let scope = nearestScope else { fatalError("no scope")  }

      scope.typeFieldName = currentKey.stringValue
      return try expand(schema: typeSchema)


    case .dynamic(let allowUnknownTypes, let dynamicSchemaMappings):
      guard let nearestScope = nearestScope else { fatalError("no scope") }

      guard let typeFieldName = nearestScope.typeFieldName else {
        throw SchemaError.noDynamicTypeDefined("Dynamic type referenced but none marked in structure's schema")
      }

      guard let dynamicType = nearestScope.container[typeFieldName] as? ASN1 else {
        throw SchemaError.noDynamicType(errorContext("No dynamic type found"))
      }

      guard let dynamicSchema = dynamicSchemaMappings[dynamicType] else {
        if allowUnknownTypes {
          return [.schema(.any)]
        }
        throw SchemaError.unknownDynamicType(errorContext("Dynamic type not found in mapping"))
      }

      return try expand(schema: dynamicSchema)


    case .version(let versionSchema):
      guard let scope = nearestScope else { fatalError("no scope") }

      scope.versionFieldName = currentKey.stringValue

      return try expand(schema: versionSchema)


    case .versioned(range: let allowedRange, let versionedSchema):
      guard let nearestScope = nearestScope else { fatalError("no scope") }

      guard let versionFieldName = nearestScope.versionFieldName else {
        throw SchemaError.noVersionDefined("Version referenced but none marked in structure's schema")
      }

      guard let versionValue = nearestScope.container[versionFieldName] as? ASN1 else {
        throw SchemaError.noVersion(errorContext("No version found"))
      }

      guard let version = versionValue.integerValue?.unsignedIntegerValue else {
        throw SchemaError.noVersion(errorContext("Version is required to be unsigned integer"))
      }

      guard allowedRange.contains(version) else {
        return [.disallowed(schema), .nothing]
      }

      return try expand(schema: versionedSchema)

      
    default:
      return [.schema(schema)]
    }

  }

  func errorContext(_ debugDescription: String) -> SchemaError.Context {
    return .init(codingPath: keyStack, debugDescription: debugDescription)
  }

}
