import CasePaths

public extension Reducers {
  struct ForEach<
    ElementReducer: ReducerProtocol,
    Elements,
    Key,
    GlobalState,
    GlobalAction
  >: ReducerProtocol {
    public var elementReducer: ElementReducer
    public var toLocalState: WritableKeyPath<GlobalState, Elements>
    public var toLocalAction: CasePath<GlobalAction, (Key, ElementReducer.Action)>
    public var toLocalElement: (Key) -> AnyReadWritable<Elements, ElementReducer.State?>
    public var breakpointOnNil: Bool
    var file: StaticString
    var line: UInt

    public init(
      _ element: ElementReducer,
      state toLocalState: WritableKeyPath<GlobalState, Elements>,
      action toLocalAction: CasePath<GlobalAction, (Key, ElementReducer.Action)>,
      element toLocalElement: @escaping (Key) -> AnyReadWritable<Elements, ElementReducer.State?>,
      breakpointOnNil: Bool = true,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      self.elementReducer = element
      self.toLocalState = toLocalState
      self.toLocalAction = toLocalAction
      self.toLocalElement = toLocalElement
      self.breakpointOnNil = breakpointOnNil
      self.file = file
      self.line = line
    }

    public init<RW: ReadWritable>(
      _ element: ElementReducer,
      state toLocalState: WritableKeyPath<GlobalState, Elements>,
      action toLocalAction: CasePath<GlobalAction, (Key, ElementReducer.Action)>,
      element toLocalElement: @escaping (Key) -> RW,
      breakpointOnNil: Bool = true,
      file: StaticString = #file,
      line: UInt = #line
    ) where RW.Root == Elements, RW.Value == ElementReducer.State? {
      self.elementReducer = element
      self.toLocalState = toLocalState
      self.toLocalAction = toLocalAction
      self.toLocalElement = { key in toLocalElement(key).eraseToAnyReadWritable() }
      self.breakpointOnNil = breakpointOnNil
      self.file = file
      self.line = line
    }

    public func run(_ globalState: inout GlobalState, _ globalAction: GlobalAction) -> Effect<GlobalAction, Never> {
      guard let (key, localAction) = toLocalAction.extract(from: globalAction) else {
        return .none
      }
      let lens = toLocalElement(key)
      guard var localElement = lens.get(from: globalState[keyPath: toLocalState]) else {
        #if DEBUG
        if breakpointOnNil {
          fputs(
            """
              ---
              Warning: Reducer.forEach@\(file):\(line)

              "\(debugCaseOutput(localAction))" was received by a "forEach" reducer at \
              \(key) when its state contained no element at this index. This is generally \
              considered an application logic error, and can happen for a few reasons:

              * This "forEach" reducer was combined with or run from another reducer that removed \
              the element at this index when it handled this action. To fix this make sure that \
              this "forEach" reducer is run before any other reducers that can move or remove \
              elements from state. This ensures that "forEach" reducers can handle their actions \
              for the element at the intended index.

              * An in-flight effect emitted this action while state contained no element at this \
              index. While it may be perfectly reasonable to ignore this action, you may want to \
              cancel the associated effect when moving or removing an element. If your "forEach" \
              reducer returns any long-living effects, you should use the identifier-based \
              "forEach" instead.

              * This action was sent to the store while its state contained no element at this \
              index. To fix this make sure that actions for this reducer can only be sent to a \
              view store when its state contains an element at this index. In SwiftUI \
              applications, use "ForEachStore".
              ---

              """,
            stderr
          )
          raise(SIGTRAP)
        }
        #endif
        return .none
      }

      let effects = elementReducer.run(
        &localElement,
        localAction
      )
      .map { toLocalAction.embed((key, $0)) }

      lens.set(&globalState[keyPath: toLocalState], to: localElement)

      return effects
    }
  }
}

public extension ReducerProtocol {
  func forEach<Elements: MutableCollection, GlobalState, GlobalAction>(
    state toLocalState: WritableKeyPath<GlobalState, Elements>,
    action toLocalAction: CasePath<GlobalAction, (Elements.Index, Action)>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducers.ForEach<Self, Elements, Elements.Index, GlobalState, GlobalAction>
  where Elements.Element == State {
    .init(
      self,
      state: toLocalState,
      action: toLocalAction,
      element: { idx in
        AnyReadWritable(
          get: { elements in
            guard elements.indices.contains(idx) else { return nil }
            return elements[idx]
          },
          set: { elements, newValue in
            guard let newValue = newValue, elements.indices.contains(idx) else { return }
            elements[idx] = newValue
          }
        )
      },
      breakpointOnNil: breakpointOnNil
    )
  }

  func forEach<GlobalState, GlobalAction, ID>(
    state toLocalState: WritableKeyPath<GlobalState, IdentifiedArray<ID, State>>,
    action toLocalAction: CasePath<GlobalAction, (ID, Action)>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducers.ForEach<Self, IdentifiedArray<ID, State>, ID, GlobalState, GlobalAction> {
    .init(
      self,
      state: toLocalState,
      action: toLocalAction,
      element: { id in
        \IdentifiedArray<ID, State>.[id: id]
      },
      breakpointOnNil: breakpointOnNil
    )
  }

  func forEach<GlobalState, GlobalAction, Key>(
    state toLocalState: WritableKeyPath<GlobalState, [Key: State]>,
    action toLocalAction: CasePath<GlobalAction, (Key, Action)>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducers.ForEach<Self, [Key: State], Key, GlobalState, GlobalAction> {
    .init(
      self,
      state: toLocalState,
      action: toLocalAction,
      element: { key in \[Key: State].[key] },
      breakpointOnNil: breakpointOnNil
    )
  }
}
