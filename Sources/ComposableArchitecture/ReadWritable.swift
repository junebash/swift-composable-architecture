import SwiftUI

public protocol Gettable {
  associatedtype Root
  associatedtype Value

  func get(from root: Root) -> Value
}

public protocol Settable {
  associatedtype Root
  associatedtype Value

  func set(_ root: inout Root, to value: Value)
}

public extension Settable {
  func setting(_ root: Root, to value: Value) -> Root {
    var copy = root
    set(&copy, to: value)
    return copy
  }
}

// e.g. Lens
public typealias ReadWritable = Gettable & Settable

extension KeyPath: Gettable {
  public func get(from root: Root) -> Value {
    root[keyPath: self]
  }
}

extension WritableKeyPath: Settable {
  public func set(_ root: inout Root, to value: Value) {
    root[keyPath: self] = value
  }
}

extension CasePath: Gettable {
  public func get(from root: Root) -> Value? {
    extract(from: root)
  }
}

extension CasePath: Settable {
  public func set(_ root: inout Root, to value: Value?) {
    guard let value = value else { return }
    root = embed(value)
  }
}

public struct AnyGettable<Root, Value>: Gettable {
  public var get: (Root) -> Value

  public init(get: @escaping (Root) -> Value) {
    self.get = get
  }

  public init<G: Gettable>(_ g: G) where G.Root == Root, G.Value == Value {
    self.init(get: g.get(from:))
  }

  public func get(from root: Root) -> Value {
    get(root)
  }
}

public extension Gettable {
  func eraseToAnyGettable() -> AnyGettable<Root, Value> {
    .init(self)
  }
}

public struct AnySettable<Root, Value>: Settable {
  public var set: (inout Root, Value) -> Void

  public init(set: @escaping (inout Root, Value) -> Void) {
    self.set = set
  }

  public init<S: Settable>(_ s: S) where S.Root == Root, S.Value == Value {
    self.init(set: s.set(_:to:))
  }

  public func set(_ root: inout Root, to value: Value) {
    set(&root, value)
  }
}

public extension Settable {
  func eraseToAnySettable() -> AnySettable<Root, Value> {
    .init(self)
  }
}

public struct AnyReadWritable<Root, Value>: ReadWritable {
  public var get: (Root) -> Value
  public var set: (inout Root, Value) -> Void

  public init(get: @escaping (Root) -> Value, set: @escaping (inout Root, Value) -> Void) {
    self.get = get
    self.set = set
  }

  public init<Wrapped: ReadWritable>(_ wrapped: Wrapped)
  where Wrapped.Root == Root, Wrapped.Value == Value {
    self.init(get: wrapped.get, set: wrapped.set)
  }

  public func get(from root: Root) -> Value {
    get(root)
  }

  public func set(_ root: inout Root, to value: Value) {
    set(&root, value)
  }
}

public extension Gettable where Self: Settable {
  func eraseToAnyReadWritable() -> AnyReadWritable<Root, Value> {
    .init(self)
  }
}

public extension Binding {
  func map<GetSet: ReadWritable, NewValue>(
    _ readWritable: GetSet
  ) -> Binding<NewValue>
  where GetSet.Root == Value, GetSet.Value == NewValue {
    .init(
      get: { readWritable.get(from: wrappedValue) },
      set: { newValue in readWritable.set(&wrappedValue, to: newValue) }
    )
  }
}
