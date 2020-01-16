//
//  PokemonAddViewController.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import UIKit

class PokemonAddViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var suggestionsTableView: UITableView!
    
    // MARK: - Attributes
    var pokemonController: PokemonController?
    var pokemon: Pokemon? { didSet{ updateViews() } }
    var filteredPokemon: [String] = []
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        searchBar.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(resizeForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resizeForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        saveButton.layer.cornerRadius = 10
    }
    
    // MARK: - IBActions
    @IBAction func saveAction(_ sender: Any) {
        pokemonController?.savePokemon()
        suggestionsTableView.isHidden = false
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredPokemon = []
        for item in pokemonController?.pokeList?.results ?? [] { filteredPokemon.append(item.name.capitalized) }
        filteredPokemon = filteredPokemon.filter { $0.lowercased().contains(searchText.lowercased()) }
        suggestionsTableView.isHidden = false
        suggestionsTableView.reloadData()
    }
    
    // MARK: - Suggestions TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection  section: Int) -> Int {
        return filteredPokemon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:  IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filter", for: indexPath)
        cell.textLabel?.text = filteredPokemon[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = filteredPokemon[indexPath.row]
        performSearch()
    }
    
    // MARK: - Helper Functions
    func performSearch() {
        guard let text = searchBar.text else { return }
        pokemonController?.catchPokemon(name: text){ _ in DispatchQueue.main.async { self.pokemon = self.pokemonController?.currentPokemon } }
        searchBar.resignFirstResponder()
        suggestionsTableView.isHidden = true
        saveButton.isHidden = false
    }
    
    func updateViews() {
        guard let pokemon = pokemon else { return }
        if let childVC = self.children.first as? PokemonDetailViewController { childVC.pokemon = pokemon }
    }
    
    // Resizing TableView for keyboard
    @objc func resizeForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        if notification.name == UIResponder.keyboardWillHideNotification {
            suggestionsTableView.contentInset = .zero
        } else {
            suggestionsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.convert(keyboardValue.cgRectValue, from: view.window).height - view.safeAreaInsets.bottom, right: 0)
        }
        suggestionsTableView.scrollIndicatorInsets = suggestionsTableView.contentInset
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSegue" {
            guard let destination = segue.destination as? PokemonDetailViewController else { return }
            destination.pokemon = self.pokemon
        }
    }
    
}
