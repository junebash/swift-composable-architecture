public protocol ReducerProtocol {
  associatedtype State
  associatedtype Action

  func run(_ state: inout State, _ action: Action) -> Effect<Action, Never>
}

public extension ReducerProtocol {
  func callAsFunction(_ state: inout State, _ action: Action) -> Effect<Action, Never> {
    self.run(&state, action)
  }

  func reduce(_ state: inout State, _ action: Action) -> Effect<Action, Never> {
    self.run(&state, action)
  }
}

public enum Reducers {}
