public extension Reducers {
  struct Combine2<
    A: ReducerProtocol,
    B: ReducerProtocol
  >: ReducerProtocol where A.State == B.State, A.Action == B.Action {
    public var a: A
    public var b: B

    public init(_ a: A, _ b: B) {
      self.a = a
      self.b = b
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(with: b.run(&state, action))
        .eraseToEffect()
    }
  }

  struct Combine3<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State,
    A.Action == B.Action, A.Action == C.Action
  {
    public var a: A
    public var b: B
    public var c: C

    public init(_ a: A, _ b: B, _ c: C) {
      self.a = a
      self.b = b
      self.c = c
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action)
        ).eraseToEffect()
    }
  }

  struct Combine4<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State, A.State == D.State,
    A.Action == B.Action, A.Action == C.Action, A.Action == D.Action
  {
    public var a: A
    public var b: B
    public var c: C
    public var d: D

    public init(_ a: A, _ b: B, _ c: C, _ d: D) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action),
          d.run(&state, action)
        ).eraseToEffect()
    }
  }

  struct Combine5<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State, A.State == D.State, A.State == E.State,
    A.Action == B.Action, A.Action == C.Action, A.Action == D.Action, A.Action == E.Action
  {
    public var a: A
    public var b: B
    public var c: C
    public var d: D
    public var e: E

    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action),
          d.run(&state, action),
          e.run(&state, action)
        ).eraseToEffect()
    }
  }

  struct Combine6<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State, A.State == D.State,
    A.State == E.State, A.State == F.State,
    A.Action == B.Action, A.Action == C.Action, A.Action == D.Action,
    A.Action == E.Action, A.Action == F.Action
  {
    public var a: A
    public var b: B
    public var c: C
    public var d: D
    public var e: E
    public var f: F

    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action),
          d.run(&state, action),
          e.run(&state, action),
          f.run(&state, action)
        ).eraseToEffect()
    }
  }

  struct Combine7<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol,
    G: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State, A.State == D.State,
    A.State == E.State, A.State == F.State, A.State == G.State,
    A.Action == B.Action, A.Action == C.Action, A.Action == D.Action,
    A.Action == E.Action, A.Action == F.Action, A.Action == G.Action
  {
    public var a: A
    public var b: B
    public var c: C
    public var d: D
    public var e: E
    public var f: F
    public var g: G

    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
      self.g = g
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action),
          d.run(&state, action),
          e.run(&state, action),
          f.run(&state, action),
          g.run(&state, action)
        ).eraseToEffect()
    }
  }

  struct Combine8<
    A: ReducerProtocol,
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol,
    G: ReducerProtocol,
    H: ReducerProtocol
  >: ReducerProtocol
  where
    A.State == B.State, A.State == C.State, A.State == D.State,
    A.State == E.State, A.State == F.State, A.State == G.State, A.State == H.State,
    A.Action == B.Action, A.Action == C.Action, A.Action == D.Action,
    A.Action == E.Action, A.Action == F.Action, A.Action == G.Action, A.Action == H.Action
  {
    public var a: A
    public var b: B
    public var c: C
    public var d: D
    public var e: E
    public var f: F
    public var g: G
    public var h: H

    public init(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) {
      self.a = a
      self.b = b
      self.c = c
      self.d = d
      self.e = e
      self.f = f
      self.g = g
      self.h = h
    }

    public func run(_ state: inout A.State, _ action: A.Action) -> Effect<A.Action, Never> {
      a.run(&state, action)
        .merge(
          with: b.run(&state, action),
          c.run(&state, action),
          d.run(&state, action),
          e.run(&state, action),
          f.run(&state, action),
          g.run(&state, action),
          h.run(&state, action)
        ).eraseToEffect()
    }
  }
}

public extension ReducerProtocol {
  func combined<Other: ReducerProtocol>(with other: Other) -> Reducers.Combine2<Self, Other>
  where Self.State == Other.State, Self.Action == Other.Action {
    Reducers.Combine2(self, other)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol
  >(with b: B, _ c: C) -> Reducers.Combine3<Self, B, C>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine3(self, b, c)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol
  >(with b: B, _ c: C, _ d: D) -> Reducers.Combine4<Self, B, C, D>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine4(self, b, c, d)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol
  >(with b: B, _ c: C, _ d: D, _ e: E) -> Reducers.Combine5<Self, B, C, D, E>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine5(self, b, c, d, e)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol
  >(with b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> Reducers.Combine6<Self, B, C, D, E, F>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine6(self, b, c, d, e, f)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol,
    G: ReducerProtocol
  >(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> Reducers.Combine7<Self, B, C, D, E, F, G>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine7(self, b, c, d, e, f, g)
  }

  func combined<
    B: ReducerProtocol,
    C: ReducerProtocol,
    D: ReducerProtocol,
    E: ReducerProtocol,
    F: ReducerProtocol,
    G: ReducerProtocol,
    H: ReducerProtocol
  >(with b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H)
  -> Reducers.Combine8<Self, B, C, D, E, F, G, H>
  where Self.State == B.State, Self.Action == B.Action {
    Reducers.Combine8(self, b, c, d, e, f, g, h)
  }
}
