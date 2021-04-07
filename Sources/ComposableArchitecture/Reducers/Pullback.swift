import CasePaths

public extension Reducers {
  struct Pullback<LocalReducer: ReducerProtocol, GlobalState, GlobalAction>: ReducerProtocol {
    public var child: LocalReducer
    public var toLocalState: WritableKeyPath<GlobalState, LocalReducer.State>
    public var toLocalAction: CasePath<GlobalAction, LocalReducer.Action>

    public func run(
      _ parentState: inout GlobalState,
      _ parentAction: GlobalAction
    ) -> Effect<GlobalAction, Never> {
      guard let localAction = toLocalAction.extract(from: parentAction) else { return .none }
      return child
        .run(&parentState[keyPath: toLocalState], localAction)
        .map(toLocalAction.embed)
    }
  }
}

public extension ReducerProtocol {
  func pullback<ParentState, ParentAction>(
    state toLocalState: WritableKeyPath<ParentState, Self.State>,
    action toLocalAction: CasePath<ParentAction, Self.Action>
  ) -> Reducers.Pullback<Self, ParentState, ParentAction> {
    .init(child: self, toLocalState: toLocalState, toLocalAction: toLocalAction)
  }
}
