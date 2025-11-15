//
//  UserService.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import Foundation
import Supabase

class UserService {
    
    private let supabase = SupabaseManager.shared.client
    
    func fetchUserName(for user: User) async throws -> String {
        do {
            let response = try await supabase
                .from("users")
                .select("name")
                .eq("id", value: user.id.uuidString)
                .single()
                .execute()
            
            if !response.data.isEmpty,
               let json = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
               let name = json["name"] as? String {
                return name
            } else {
                return "User"
            }
        } catch {
            print("Error fetching user name: \(error)")
            throw error
        }
    }
}
