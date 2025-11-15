//
//  SessionManager.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import Foundation
import Supabase

final class SessionManager {
    static let shared = SessionManager()

    private init() {}

    var session: Session?
    var user: User? {
        return session?.user
    }

    func loadSession() async {
        let supabase = SupabaseManager.shared.client
        do {
            let currentSession = try await supabase.auth.session
            self.session = currentSession
            print("Session loaded for user: \(currentSession.user.email ?? "Unknown")")
        } catch {
            print("No active session found: \(error)")
        }
    }

    func clearSession() {
        self.session = nil
        print("Session cleared.")
    }
}
