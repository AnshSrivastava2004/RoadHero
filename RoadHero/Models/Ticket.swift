//
//  Ticket.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

struct Ticket: Decodable {
    let id: String
    let status: String
    let created_at: String
    let pothole_metadata: PotholeMetadata
}
