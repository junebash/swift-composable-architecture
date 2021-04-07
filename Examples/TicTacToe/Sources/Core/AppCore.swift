import AuthenticationClient
import ComposableArchitecture
import Dispatch
import LoginCore
import NewGameCore

public struct AppState: Equatable {
  public var login: LoginState? = LoginState()
  public var newGame: NewGameState?

  public init() {}
}

public enum AppAction: Equatable {
  case login(LoginAction)
  case newGame(NewGameAction)
}

public struct AppReducer: ReducerProtocol {
  public var combined: AnyReducer<AppState, AppAction>

  public init(authenticationClient: AuthenticationClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.combined = Reducers.Combine3(
      LoginReducer(
        authenticationClient: authenticationClient,
        mainQueue: mainQueue
      )
      .optional()
      .pullback(
        state: \.login,
        action: /AppAction.login
      ),
      NewGameReducer()
        .optional()
        .pullback(
          state: \.newGame,
          action: /AppAction.newGame
        ),
      Main(authenticationClient: authenticationClient, mainQueue: mainQueue)
    )
    .eraseToAnyReducer()
  }

  public func run(_ state: inout AppState, _ action: AppAction) -> Effect<AppAction, Never> {
    combined.run(&state, action)
  }

  struct Main: ReducerProtocol {
    var authenticationClient: AuthenticationClient
    var mainQueue: AnySchedulerOf<DispatchQueue>

    func run(_ state: inout AppState, _ action: AppAction) -> Effect<AppAction, Never> {
      switch action {
      case let .login(.twoFactor(.twoFactorResponse(.success(response)))),
           let .login(.loginResponse(.success(response))):
        guard !response.twoFactorRequired else { return .none }
        state.newGame = NewGameState()
        state.login = nil
        return .none

      case .login:
        return .none

      case .newGame(.logoutButtonTapped):
        state.newGame = nil
        state.login = LoginState()
        return .none

      case .newGame:
        return .none
      }
    }
  }
}
