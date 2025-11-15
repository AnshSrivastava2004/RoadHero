//
//  SupabaseManager.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import Supabase
import Foundation

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Env.supabaseURL)!,
            supabaseKey: Env.supabaseKey
        )
    }
}
