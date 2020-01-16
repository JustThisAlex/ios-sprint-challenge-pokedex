//
//  Pokemon.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation

struct Pokemon: Codable {
    let name: String
    let id: Int
    let sprites: Sprite
    let abilities: [Ability]
    let types: [Type]
}

//Sprite
struct Sprite: Codable {
    let frontDefault: URL
}

//Ability
struct Ability: Codable, Equatable {
    let ability: AbilityDet
}
struct AbilityDet: Codable, Equatable {
    let name: String
}

//Type
struct Type: Codable, Equatable {
    let type: TypeDet
}
struct TypeDet: Codable, Equatable {
    let name: String
}

// MARK: PokemonList
struct PokemonList: Codable {
    let results: [PokeResult]
}
struct PokeResult: Codable {
    var name: String
}
