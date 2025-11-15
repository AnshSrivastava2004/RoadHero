//
//  SceneDelegate.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 20/10/25.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        Task {
            await restoreSession()
        }
        
        Task {
            await SessionManager.shared.loadSession()
        }
        
        if let url = connectionOptions.urlContexts.first?.url {
                handleDeepLink(url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url)
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "roadhero",
        url.host == "reset-password" else { return }
        handlePasswordResetLink(url: url)
    }
    
    func handlePasswordResetLink(url: URL) {
        print("Handling password reset URL: \(url.absoluteString)")

        var queryItems: [URLQueryItem] = []
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            queryItems = items
        }

        if queryItems.isEmpty, let fragment = url.fragment {
            let fragmentItems = fragment
                .components(separatedBy: "&")
                .compactMap { pair -> URLQueryItem? in
                    let parts = pair.components(separatedBy: "=")
                    guard parts.count == 2 else { return nil }
                    return URLQueryItem(name: parts[0], value: parts[1])
                }
            queryItems = fragmentItems
        }

        let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value
        let code = queryItems.first(where: { $0.name == "code" })?.value
        let token = accessToken ?? code
        let type = queryItems.first(where: { $0.name == "type" })?.value ?? "recovery"

        print("Parsed type=\(type), token=\(token ?? "nil")")

        guard let token = token else {
            print("Invalid password reset link. No token found.")
            return
        }

        print("Received password reset link. Setting Supabase session...")

        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.exchangeCodeForSession(authCode: token)
                print("Successfully restored session for password reset: \(session.user.email ?? "Unknown user")")

                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let resetVC = storyboard.instantiateViewController(withIdentifier: "NewPasswordViewController") as? NewPasswordViewController else {
                        print("Could not instantiate NewPasswordViewController from storyboard.")
                        return
                    }

                    if let topVC = self.topMostViewController() {
                        resetVC.modalPresentationStyle = .fullScreen
                        topVC.present(resetVC, animated: true)
                        print("NewPasswordViewController presented successfully.")
                    } else {
                        print("Could not find a view controller to present from.")
                    }
                }
            } catch {
                print("Failed to restore Supabase session for password reset:", error)
            }
        }
    }
    
    private func presentNewPasswordVC(on rootVC: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resetVC = storyboard.instantiateViewController(withIdentifier: "NewPasswordViewController") as? NewPasswordViewController {
            resetVC.modalPresentationStyle = .fullScreen
            rootVC.present(resetVC, animated: true)
        }
    }

    func topMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        return topController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

