//
//  PokemonTableViewController.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import UIKit

class PokemonTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    // MARK: - Attributes
    var pokemonController = PokemonController()
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: "sortingByName"){ sortSegment.selectedSegmentIndex = 1 }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonController.addedPokemon.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pokeCell", for: indexPath) as? PokemonTableViewCell
        cell?.pokemon = pokemonController.addedPokemon[indexPath.row]
        return cell!
    }
    
    // Deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            pokemonController.removePokemon(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addSegue" {
            guard let destination = segue.destination as? PokemonAddViewController else { return }
            destination.pokemonController = self.pokemonController
        } else if segue.identifier == "showSegue" {
            guard let destination = segue.destination as? PokemonDetailViewController else { return }
            destination.pokemon = self.pokemonController.addedPokemon[tableView.indexPathForSelectedRow?.row ?? 0]
        }
    }
    
    // MARK: - Sorting
    @IBAction func indexChanged(_ sender: Any) {
        switch sortSegment.selectedSegmentIndex
        { case 0: pokemonController.sortByName = false; tableView.reloadData()
          default: pokemonController.sortByName = true; tableView.reloadData() }
    }
}
