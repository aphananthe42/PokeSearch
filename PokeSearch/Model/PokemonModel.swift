//
//  PokemonModel.swift
//  PokeSearch
//
//  Created by Ryota Miyazaki on 2020/11/14.
//

import Foundation

struct PokemonModel: Codable {
    let id: Int
    let name: String
    let image: Sprites
    
    struct Sprites: Codable {
        var defaultImage: String
        
        enum CodingKeys: String, CodingKey {
            case defaultImage = "front_default"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case image = "sprites"
    }
}
