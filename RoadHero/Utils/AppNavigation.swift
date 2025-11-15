//
//  AppNavigation.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import UIKit
import Supabase

func switchToHome() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
    let delegate = windowScene.delegate as? SceneDelegate else { return }

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController")
    let navController = UINavigationController(rootViewController: homeVC)
    delegate.window?.rootViewController = navController
    delegate.window?.makeKeyAndVisible()
}

func restoreSession() async {
    do {
        let supabase = SupabaseManager.shared.client
        _ = try await supabase.auth.session
        
        DispatchQueue.main.async {
            switchToHome()
        }
    } catch {
        print("🟡 No session found.")
        print("❌ Session restoration failed: \(error)")
    }
}
