//
//  PotholeMetadata.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

struct PotholeMetadata: Decodable {
    let id: String
    let description: String?
    let image_url: String?
    let severity: String?
}
