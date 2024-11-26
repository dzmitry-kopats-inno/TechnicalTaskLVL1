//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let allUsersViewModel = AllUsersViewModel(networkService: NetworkService())
        let allUsersViewController = AllUsersViewController(viewModel: allUsersViewModel)
        window.rootViewController = UINavigationController(rootViewController: allUsersViewController)
        window.makeKeyAndVisible()
        self.window = window
    }
}
