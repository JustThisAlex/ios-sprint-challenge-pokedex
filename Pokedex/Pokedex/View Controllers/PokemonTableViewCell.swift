//
//  PokemonTableViewCell.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    
    // MARK: - Attributes
    var pokemon: Pokemon? { didSet{ updateViews() } }
    
    // MARK: - Helper Functions
    func updateViews() {
        guard let pokemon = pokemon else { return }
        label.text = pokemon.name.capitalized
        
        //Image
        guard let pokemonImage = try? Data(contentsOf: pokemon.sprites.frontDefault) else { return }
        self.pokemonImage.image = UIImage(data: pokemonImage)
    }
}
