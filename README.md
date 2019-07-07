# 🧪 PotentCodables
## A potent set of implementations and extension to the Swift `Codable` system

### Why?
The framework aims to solve three major pain points experienced with Swift's `Codable` system:

* Reduce the complexity and amount of code required to implement and test new serialization formats
* Allow decoding and/or encoding values of unknown structure (e.g. any encoded value)
* Provide a library of fully featured implementations of popular serialization formats

## Integration

### Swift Package Manager 
PotentCodables currently supports Swift Package Manager for project integration. Add a package dependency similar to the following:  
```swift
  .package(url: "https://github.com/outfoxx/PotentCodables.git", from: "1.0.0")
```

The library name is `PotentCodables` when adding dependencies to your target(s).


## Usage


If your only goal is to use one of the provided implementations of a popular serialization format not much information is needed beyond the
name of the encoder/decoder pair that you are seeking to use.  All of the implementations provided by the package are 100% compatible with
Swift's `Codable` system and they all intentionally mimic the interface of Swift's `Foundation.JSONEncoder` and `Foundation.JSONDecoder`.

For example encoding to CBOR is essentially the same as encoding with Swift's standard JSONEncoder
```swift
let data = try CBOREncoder.default.encode(myValue)
```

### Currently Available Implementations

- JSON - `JSONEncoder`/`JSONDecoder`
  A conformant [JSON](https://tools.ietf.org/html/rfc8259) implementation that is a drop-in replacement for Swift's JSON encoder and decoder
  provided by Foundation. These implementations offer enhancements to what items can be encoded to (e.g. to/from Strings and to/from
  native value trees) and offer performance enhancements when using `AnyValue`.
- CBOR - `CBOREncoder`/`CBORDecoder`
  A conformant implementation of the [CBOR](cbor.io) serialization format written in pure Swift.


### Encoder/Decoder Interface

#### Standard Encoding/Decoding

All PotentCodable encoders and decoders and be "dropped in" in place of Swift's JSON/PropertyList encoders and decoders and as such
provide methods that allow direct serialization to and from `Data` instances.

#### Data Encoding/Decoding Interface

Each encoder provides the following method to transform `Encodable` instances into `Data` values.
```swift
  func encode<T : Encodable>(_ value: T) throws -> Data
```

Each decoder provides the following method to to transform `Data` into an instance of a `Decodable` type.
```swift
  func decode<T : Decodable>(_ type: T.Type, from: Data) throws -> T
```

#### Native Value Trees
All PotentCodable encoders and decoders use a two stage serialization system. For example, when encoding an `Encodable` value it is first
transformed into a native "value tree" that is defined by the serialization format. Secondarily, a serialization utility type is used to transform
the value tree into the final serialized data.  For example, when encoding to CBOR the `Encodable` value is first transformed into
`CBOR` values that closely match the CBOR specification and then the `CBOR` value tree is serialized into `Data`.  The same process is done
for decoding but in reverse, `Data` is turned into a value tree and then the value tree is decoded into a `Decodable` value as requested.

This two stage system is important to ensure that we can implement new serialization formats with a reduced amount of code. All of the 
machinery to encode `Encodable`s and  decode `Decodable`s are isolated in a common set of classes that need to be implemented only once.

Aside from providing code structure that allows us to employ code re-use this required feature ensures that we can always encode/decode
to an in-memory value tree. This allows us to easily examine or manipulate everything that is encoded and decoded.

**Note:** Inevitably somebody will want to point out the inefficiency of using a two stage system of serialization. It is our belief that the added
features and reduced implementation cost far outweigh any slight performance/memory improvement that might be gained from serializing
directly to the target format.  _Also_, Swift's JSON implementations already use this same two stage method. In that implementation 
encodables are turned into Objective-C values and then Objective-C's JSONSerialiazation class is used to create serialized JSON data.

##### Value Tree Encoding/Decoding Interface

Due to the requirement that all of our encoders and decoders support a native value tree representation it provides the capability to encode
or decode to native value trees using the following methods:

Each encoder provides the following method with `Value` being the `Encoder`'s native value tree type; allowing us to transform an `Encodable`
instance into a native value tree.
```swift
  func encodeTree<T : Encodable, V : Value>(_ value: T) throws -> V
```

Each decoder provides the following method with `Value` being the `Decoder`'s native value tree type; allowing us to transform a native
value tree into an instance of a `Decodable` type.
```swift
  func decodeTree<T : Decodable, V : Value>(_ type: T.Type, from: V) throws -> T
```

#### String Encoding/Decoding

Any PotentCodable encoder or decoder that is implementing a text based serialization format (e.g. JSON, YAML, etc.) provides the extra 
capability to encode to and decode from `String` values.

#### String Encoding/Decoding Interface

Each encoder provides the following method to transform `Encodable` instances into `String` values.
```swift
  func encodeString<T : Encodable>(_ value: T) throws -> String
```

Each decoder provides the following method to to transform `String` into an instance of a `Decodable` type.
```swift
  func decodeString<T : Decodable>(_ type: T.Type, from: String) throws -> T
```


**Note:** While Swift's public JSON(Encoder|Decoder) and ProperyList(Encoder|Decoder) do not implement a protocal that defines their
public interface, all of PotentCodable's public encoders and decoders are required to share the same public interface which is enforced 
through a combination of protocol conformance and derivation.


### Encoding/Decoding values of unknown structure (aka `AnyValue`)

Often times it is desirable to decode a type that contains values that are of unknown structure. To provide this capability PotentCodables
provides `AnyValue`.   `AnyValue` is a `Codable` type that can take the shape of any encodable or decodable type.

An example is in order:
```swift
struct Account : Codable {
  let id: UUID
  let name: String
  let freeform: AnyValue
}
```
The example `Account` struct above has a `freeform` property that can take on any format supported by the codable system. For example
when decoding from JSON, any value or tree of valeus (including _null_, _bool_, _string_, _number_, _arrray_ or _object_) could be saved in
the `freeform` property. Encoding the same `Account` value back to JSON will produce equivalent serialized JSON regardless of the contents
of the `freeform` field.

#### Programmatically generating `AnyValue`s

If needed `AnyValue` is a fully featured enum that can store nearly any value and it can be done manually in code as well as through the
encoding and decoding process.

#### Notes

Essentially, there's not a lot of information required to use `AnyValue` properly; use it anywhere unstructured or freeform values need to be
stored. 

* **Performance** -
  Although `AnyValue` is compatible with any conformant `Codable` encoder or decoder, PotentCodables decoders specifically have shortcuts
  to decode the proper values in a more performant fashion and should be used when possible.


### Implementing new serialization formats

One of the stated goals of PotentCodables is to reduce the complexity and amount of code required when implementing new serialization
formats. We have achieved that goal only requiring new formats to implement the "boxing" and "unboxing" into their native value tree 
representation without regard for any of the inner working of Swit's `Codable` framework.

The following list of steps can be followed to easily implement a new serialization format.

#### 1. Define a native value tree representation
Each provided implementation is built upon a native value tree in-memory representation; JSON uses the `JSON` values, CBOR uses `CBOR`
values, etc.  Examining any of the provided native value trees will reveal they closely mimic their serialized format.

##### Required Protocols

- `Value`
  The native value tree representation (usually an enum) **must** implement the `Value` protocol which provides null/nil testing and the
  capability to "unwrap" themselves into a Swift primitive value tree.

##### See/Examples

* `JSON`
  The JSON native value tree is a great example of a full featured tree.
* `CBOR`
  The CBOR native value tree is another great example of a full featured tree.

#### 2. Provide a "serialization" type 
The next step requires you to provide a serialization class that can serialize native value trees into their final serialized representation and
conversely deserialize the serialized representation into a native value tree.

##### Required Protocols
There are no required protocols for the serialization type to timplement because it will be used privately in the encoder and decoder
implementations.

##### See/Example

* `JSONSerialization`
  The JSONSerialization type serializes `JSON` values to/from `Data` values. Also, because JSON is a text based format, it supports serialization
  to/from `String` values.
* `CBORSerialization`
  The CBORSerialization type serializes `CBOR` values to/from `Data` values.

#### 3. Provide "transformer" types
As the serialization type is used to translate from native value trees into their serialized forms, a "transformer" type transforms native value
trees to/from `Encodable`/`Decodable`. The good news here is that only the boxing and unboxing code is requried.

An encoding transformer and a decoding transformer are required. All of the protocols are prefixed with `Internal` to denote that they are
not intended for public use.

##### Required Protocols (Encoding)

- `InternalEncoderTransform`
  Provides the boxing of Swift primitives generated by `Encodable` instances.
- `InternalValueSerializer` - (only if format can target `Data` values)
  If the serialization format supports targeting `Data` values then this protocol is required to be implemented.
- `InternalValueStringifier` - (only if format targets `String` values)
  If the serialization format supports targeting `String` values then this protocol is required to be implemented.


##### Required Protocols (Decoding)

- `InternalDecoderTransform`
  Provides the unboxing of native value tree types.
- `InternalValueDeserializer` - (only if format targets `Data` values)
  If the serialization format supports targeting `Data` values then this protocol is required to be implemented.
- `InternalValueParser` - (only if format targets `String` values)
  If the serialization format supports targeting `String` values then this protocol is required to be implemented.

##### See/Example

* `JSONEncoderTransform`/`JSONDecoderTransform`
* `CBOREncoderTransform`/`CBORDecoderTransform`


#### 4. Create an "Encoder" and a "Decoder"
The final step is to implement the public encoder and decoder by deriving from the base implementations.

Encoders are created in the following manner:
```swift
struct MyFormatEncoder : ValueEncoder<MyFormat, MyFormatEncoderTransform> {...}
```

Decoders are created in the following manner:
```swift
struct MyFormatDecoder : ValueDecoder<MyFormat, MyFormatDecoderTransform> {...}
```

