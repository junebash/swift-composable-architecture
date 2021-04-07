public typealias AnyReducer<State, Action> = Reducer<State, Action, Void>

extension Reducer: ReducerProtocol where Environment == Void {
  public init<R: ReducerProtocol>(_ reducer: R) where R.State == State, R.Action == Action {
    self.init { state, action, _ in reducer.run(&state, action) }
  }

  public func run(_ state: inout State, _ action: Action) -> Effect<Action, Never> {
    self.run(&state, action, ())
  }
}

public extension ReducerProtocol {
  func eraseToAnyReducer() -> AnyReducer<State, Action> {
    .init(self)
  }
}
