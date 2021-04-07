public struct EmptyReducer<State, Action>: ReducerProtocol {
  public init() {}

  public func run(_ state: inout State, _ action: Action) -> Effect<Action, Never> {
    .none
  }
}

public extension Reducers {
  typealias Empty = EmptyReducer
}
