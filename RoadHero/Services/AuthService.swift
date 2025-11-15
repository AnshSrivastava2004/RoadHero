//
//  AuthService.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import Foundation
import Supabase

class AuthService {
    
    private let supabase = SupabaseManager.shared.client
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            SessionManager.shared.session = session
            print("Login successful for user: \(session.user.email ?? "unknown")")
            
        } catch {
            print("Login failed: \(error)")
            throw error
        }
    }
    
    func updatePassword(_ newPassword: String) async throws {
        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            print("Password updated successfully.")
        } catch {
            print("Password update error: \(error)")
            throw error
        }
    }
    
    func resetPassword(for email: String) async throws {
        do {
            try await supabase.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "roadhero://reset-password")!
            )
            print("Password reset link sent to \(email).")
        } catch {
            print("Password reset error: \(error)")
            throw error
        }
    }
    
    func signUpAndSignIn(email: String, password: String, name: String) async throws {
        do {
            let signUpResult = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            print("Auth signup success: \(signUpResult.user.email ?? "No user returned")")

            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            print("Signed in successfully, session created.")

            try await supabase
                .from("users")
                .insert([
                    "id": session.user.id.uuidString,
                    "name": name,
                    "email": email
                ])
                .execute()
            print("Inserted user details into 'users' table.")
            
            SessionManager.shared.session = session
            
        } catch {
            print("Auth signup/signin failed: \(error.localizedDescription)")
            throw error
        }
    }
}
