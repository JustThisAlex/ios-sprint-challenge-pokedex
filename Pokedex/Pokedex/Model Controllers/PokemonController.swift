//
//  PokemonController.swift
//  Pokedex
//
//  Created by Alexander Supe on 1/16/20.
//  Copyright © 2020 Alexander Supe. All rights reserved.
//

import Foundation

class PokemonController {
    
    // MARK: - Attributes
    var pokeList: PokemonList?
    var addedPokemon = [Pokemon]()
    var currentPokemon: Pokemon?
    var sortByName = UserDefaults.standard.bool(forKey: "sortingByName"){ didSet { sortPokemon() } }
    private var baseURL = URLComponents(string: "https://pokeapi.co/api/v2/pokemon")!
    
    // MARK: - Lifecycle Functions
    init() {
        loadFromPersistantStore()
        sortPokemon()
        allPokemon()
    }
    
    // MARK: - Basic Functions
    func savePokemon() {
        guard let currentPokemon = currentPokemon else { return }
        addedPokemon.append(currentPokemon)
        self.currentPokemon = nil
        sortPokemon()
        saveToPersistentStore()
    }
    
    func removePokemon(index: Int) {
        addedPokemon.remove(at: index)
        saveToPersistentStore()
    }
    
    // MARK: - Networking
    func catchPokemon(name: String, completion: @escaping (NetworkError?) -> Void) {
        var currentBase = baseURL
        currentBase.path.append("/\(name.lowercased())")
        
        guard let finalURL = currentBase.url else { print("Failed to build Url"); return }
        var request = URLRequest(url: finalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.badAuth)
                return
            }
            if let _ = error { completion(.otherError); return }
            guard let data = data else { completion(.badData); return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                self.currentPokemon = try decoder.decode(Pokemon.self, from: data)
                completion(nil)
            } catch {
                print("Error decoding object: \(error)")
                completion(.noDecode); return
            }
        }.resume()
    }
    
    // MARK: - Persistence
    var locationURL: URL? {
        guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return docDir.appendingPathComponent("Pokedex.plist")
    }
    
    func saveToPersistentStore() {
        let encoder = PropertyListEncoder()
        do {
            guard let fileURL = locationURL else { return }
            try encoder.encode(addedPokemon).write(to: fileURL)
        } catch { print(error) }
    }
    
    func loadFromPersistantStore() {
        let fileManager = FileManager.default
        guard let fileURL = locationURL,
            fileManager.fileExists(atPath: fileURL.path) else { return }
        do {
            let dexData = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            addedPokemon = try decoder.decode([Pokemon].self, from: dexData)
        } catch  { print(error) }
    }
    
    // MARK: - Sorting
    func sortPokemon() {
        if sortByName {
            addedPokemon.sort{ $0.name < $1.name }
            UserDefaults.standard.set(true, forKey: "sortingByName")
        } else {
            addedPokemon.sort{ $0.id < $1.id }
            UserDefaults.standard.set(false, forKey: "sortingByName")
        }
    }
    
    // MARK: - Suggestions
    func allPokemon() {
        var currentBase = baseURL
        currentBase.queryItems = [URLQueryItem(name: "limit", value: "1000")]
        var request = URLRequest(url: currentBase.url!)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                return
            }
            if let _ = error { return }
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do { self.pokeList = try decoder.decode(PokemonList.self, from: data) }
            catch { print("Error decoding object: \(error)"); return }
        }.resume()
    }
}

// MARK: - Convenience Enums
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}
