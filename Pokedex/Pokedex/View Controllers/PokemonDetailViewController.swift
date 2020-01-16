//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var abilityLabel: UILabel!
    
    // MARK: - Attributes
    var pokemon: Pokemon? { didSet{ updateViews() } }
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: - Helper Functions
    func updateViews() {
        guard isViewLoaded,
            let pokemon = pokemon else { return }
        if pokemon.name != nameLabel.text {
            guard let pokeImg = try? Data(contentsOf: pokemon.sprites.frontDefault) else { return }
            nameLabel.text = pokemon.name.capitalized
            image.image = UIImage(data: pokeImg)
            idLabel.text = "ID: \(pokemon.id)"
            
            // Type
            var typeText = "Type: "
            for type in pokemon.types {
                if type != pokemon.types[0] {
                    typeText.append(", ")
                }
                typeText.append(type.type.name.capitalized)
            }
            typeLabel.text = typeText
            
            // Abilities
            var abilityText = "Abilities: "
            for ability in pokemon.abilities {
                if ability != pokemon.abilities[0] {
                    abilityText.append(", ")
                }
                abilityText.append(ability.ability.name.capitalized)
            }
            abilityLabel.text = abilityText
        }
    }
}
