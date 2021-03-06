import ComposableArchitecture
import SwiftUI
import Combine

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
  case all = "All"
  case active = "Active"
  case completed = "Completed"
}

struct AppState: Equatable {
  var editMode: EditMode = .inactive
  var filter: Filter = .all
  var todos: IdentifiedArrayOf<Todo> = []

  var filteredTodos: IdentifiedArrayOf<Todo> {
    switch filter {
    case .active: return self.todos.filter { !$0.isComplete }
    case .all: return self.todos
    case .completed: return self.todos.filter { $0.isComplete }
    }
  }
}

enum AppAction: Equatable {
  case addTodoButtonTapped
  case clearCompletedButtonTapped
  case delete(IndexSet)
  case editModeChanged(EditMode)
  case filterPicked(Filter)
  case move(IndexSet, Int)
  case sortCompletedTodos
  case todo(id: UUID, action: TodoAction)
}

struct MainAppReducer: ReducerProtocol {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var uuid: () -> UUID

  func run(_ state: inout AppState, _ action: AppAction) -> Effect<AppAction, Never> {
    switch action {
    case .addTodoButtonTapped:
      state.todos.insert(Todo(id: uuid()), at: 0)
      return .none

    case .clearCompletedButtonTapped:
      state.todos.removeAll(where: { $0.isComplete })
      return .none

    case let .delete(indexSet):
      state.todos.remove(atOffsets: indexSet)
      return .none

    case let .editModeChanged(editMode):
      state.editMode = editMode
      return .none

    case let .filterPicked(filter):
      state.filter = filter
      return .none

    case let .move(source, destination):
      state.todos.move(fromOffsets: source, toOffset: destination)
      return Effect(value: .sortCompletedTodos)
        .delay(for: .milliseconds(100), scheduler: mainQueue)
        .eraseToEffect()

    case .sortCompletedTodos:
      state.todos.sortCompleted()
      return .none

    case .todo(id: _, action: .checkBoxToggled):
      struct TodoCompletionId: Hashable {}
      return Effect(value: .sortCompletedTodos)
        .debounce(id: TodoCompletionId(), for: 1, scheduler: mainQueue.animation())

    case .todo:
      return .none
    }
  }
}

struct AppReducer: ReducerProtocol {
  let upstream: AnyReducer<AppState, AppAction>

  init(mainQueue: AnySchedulerOf<DispatchQueue>, uuid: @escaping () -> UUID) {
    self.upstream = TodoReducer()
      .forEach(state: \.todos, action: /AppAction.todo(id:action:))
      .combined(
        with: MainAppReducer(mainQueue: mainQueue, uuid: uuid)
      )
      .eraseToAnyReducer()
  }

  func run(_ state: inout AppState, _ action: AppAction) -> Effect<AppAction, Never> {
    upstream.run(&state, action)
  }
}

public struct AnalyticsClient {
  var log: (String) -> Effect<Never, Error>

  public struct Error: Swift.Error, CustomStringConvertible {
    public private(set) var description: String = ""
  }

  static let mock = AnalyticsClient { str in
    .fireAndForget { print(str) }
  }
}

extension ReducerProtocol {
  func analytics(
    client: AnalyticsClient,
    log: @escaping (State, Action) -> String = {
      "state: \($0)\naction:\($1)"
    },
    handleError: @escaping (AnalyticsClient.Error) -> Action? = { _ in nil }
  ) -> AnalyticsReducer<Self> {
    .init(
      upstream: self,
      client: client,
      log: log,
      handleError: handleError
    )
  }
}

public struct AnalyticsReducer<Upstream: ReducerProtocol>: ReducerProtocol {
  var upstream: Upstream
  var log: (Upstream.State, Upstream.Action) -> String
  var handleError: (AnalyticsClient.Error) -> Upstream.Action?
  var client: AnalyticsClient

  public init(
    upstream: Upstream,
    client: AnalyticsClient,
    log: @escaping (Upstream.State, Upstream.Action) -> String = {
      "state: \($0)\naction:\($1)"
    },
    handleError: @escaping (AnalyticsClient.Error) -> Upstream.Action? = { _ in nil }
  ) {
    self.upstream = upstream
    self.log = log
    self.handleError = handleError
    self.client = client
  }

  public func run(
    _ state: inout Upstream.State,
    _ action: Upstream.Action
  ) -> Effect<Upstream.Action, Never> {
    let effects = upstream.run(&state, action)
    let logText = log(state, action)
    let logEffects = client.log(logText)
      .fireAndForget(
        outputType: Upstream.Action.self,
        failureType: AnalyticsClient.Error.self
      )
      .catch { (error: AnalyticsClient.Error) -> AnyPublisher<Upstream.Action, Never> in
        handleError(error)
          .map { Just($0).eraseToAnyPublisher() }
          ?? Empty().eraseToAnyPublisher()
      }.eraseToEffect()
    return .merge(effects, logEffects)
  }
}

struct AppView: View {
  struct ViewState: Equatable {
    var editMode: EditMode
    var isClearCompletedButtonDisabled: Bool
  }

  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store.scope(state: { $0.view })) { viewStore in
      NavigationView {
        VStack(alignment: .leading) {
          WithViewStore(self.store.scope(state: { $0.filter }, action: AppAction.filterPicked)) {
            filterViewStore in
            Picker(
              "Filter", selection: filterViewStore.binding(send: { $0 }).animation()
            ) {
              ForEach(Filter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
          }
          .padding([.leading, .trailing])

          List {
            ForEachStore(
              self.store.scope(state: { $0.filteredTodos }, action: AppAction.todo(id:action:)),
              content: TodoView.init(store:)
            )
            .onDelete { viewStore.send(.delete($0)) }
            .onMove { viewStore.send(.move($0, $1)) }
          }
        }
        .navigationBarTitle("Todos")
        .navigationBarItems(
          trailing: HStack(spacing: 20) {
            EditButton()
            Button("Clear Completed") {
              viewStore.send(.clearCompletedButtonTapped, animation: .default)
            }
            .disabled(viewStore.isClearCompletedButtonDisabled)
            Button("Add Todo") { viewStore.send(.addTodoButtonTapped, animation: .default) }
          }
        )
        .environment(
          \.editMode,
          viewStore.binding(get: { $0.editMode }, send: AppAction.editModeChanged)
        )
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}

extension AppState {
  var view: AppView.ViewState {
    .init(
      editMode: self.editMode,
      isClearCompletedButtonDisabled: !self.todos.contains(where: { $0.isComplete })
    )
  }
}

extension IdentifiedArray where ID == UUID, Element == Todo {
  fileprivate mutating func sortCompleted() {
    // Simulate stable sort
    self = IdentifiedArray(
      self.enumerated()
        .sorted(by: { lhs, rhs in
          (rhs.element.isComplete && !lhs.element.isComplete) || lhs.offset < rhs.offset
        })
        .map { $0.element }
    )
  }
}

extension IdentifiedArray where ID == UUID, Element == Todo {
  static let mock: Self = [
    Todo(
      description: "Check Mail",
      id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEDDEADBEEF")!,
      isComplete: false
    ),
    Todo(
      description: "Buy Milk",
      id: UUID(uuidString: "CAFEBEEF-CAFE-BEEF-CAFE-BEEFCAFEBEEF")!,
      isComplete: false
    ),
    Todo(
      description: "Call Mom",
      id: UUID(uuidString: "D00DCAFE-D00D-CAFE-D00D-CAFED00DCAFE")!,
      isComplete: true
    ),
  ]
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(
      store: Store(
        initialState: AppState(todos: .mock),
        reducer: AppReducer(
          mainQueue: .immediate,
          uuid: UUID.init
        )
        .analytics(client: .mock)
      )
    )
  }
}
