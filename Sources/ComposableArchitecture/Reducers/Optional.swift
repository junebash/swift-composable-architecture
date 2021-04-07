public extension Reducers {
  struct Optional<Upstream: ReducerProtocol, WrappedState>: ReducerProtocol
  where Upstream.State == WrappedState {
    public var upstream: Upstream
    public var breakpointOnNil: Bool
    public var file: StaticString
    public var line: UInt

    public init(
      upstream: Upstream,
      breakpointOnNil: Bool = false,
      file: StaticString = #file,
      line: UInt = #line
    ) {
      self.upstream = upstream
      self.breakpointOnNil = breakpointOnNil
      self.file = file
      self.line = line
    }

    public func run(
      _ state: inout WrappedState?,
      _ action: Upstream.Action
    ) -> Effect<Upstream.Action, Never> {
      guard state != nil else {
        #if DEBUG
        if breakpointOnNil {
          fputs(
            """
              ---
              Warning: Reducer.optional@\(file):\(line)

              "\(debugCaseOutput(action))" was received by an optional reducer when its state was \
              "nil". This is generally considered an application logic error, and can happen for a \
              few reasons:

              * The optional reducer was combined with or run from another reducer that set \
              "\(State.self)" to "nil" before the optional reducer ran. Combine or run optional \
              reducers before reducers that can set their state to "nil". This ensures that \
              optional reducers can handle their actions while their state is still non-"nil".

              * An in-flight effect emitted this action while state was "nil". While it may be \
              perfectly reasonable to ignore this action, you may want to cancel the associated \
              effect before state is set to "nil", especially if it is a long-living effect.

              * This action was sent to the store while state was "nil". Make sure that actions \
              for this reducer can only be sent to a view store when state is non-"nil". In \
              SwiftUI applications, use "IfLetStore".
              ---

              """,
            stderr
          )
          raise(SIGTRAP)
        }
        #endif
        return .none
      }
      return upstream.run(&state!, action)
    }
  }
}

public extension ReducerProtocol {
  func optional<WrappedState>(
    breakpointOnNil: Bool = true,
    file: StaticString = #file,
    line: UInt = #line
  ) -> Reducers.Optional<Self, WrappedState> {
    .init(upstream: self, breakpointOnNil: breakpointOnNil, file: file, line: line)
  }
}
