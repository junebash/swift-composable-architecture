import ComposableArchitecture
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  let appStore: Store<AppState, AppAction> = Store(
    initialState: AppState(),
    reducer: AppReducer(
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      uuid: UUID.init
    ).analytics(client: .mock)
  )

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    self.window = (scene as? UIWindowScene).map(UIWindow.init(windowScene:))

    self.window?.rootViewController = UIHostingController(rootView: AppView(store: appStore))
    self.window?.makeKeyAndVisible()
  }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    true
  }
}
