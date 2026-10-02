import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .visible
            titlebar.toolbar = nil
        }
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 980, height: 680)
        #endif

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = CatalystViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
