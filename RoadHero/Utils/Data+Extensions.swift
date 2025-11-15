//
//  Data+Extensions.swift
//  RoadHero
//
//  Created by Ansh Srivastava on 14/11/25.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
