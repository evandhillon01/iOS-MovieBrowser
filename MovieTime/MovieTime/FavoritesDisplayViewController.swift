//
//  FavoritesDisplayViewController.swift
//  MovieTime
//
//  Created by Evan Dhillon on 10/22/17.
//  Copyright © 2017 Evan Dhillon. All rights reserved.
//

import Foundation
import UIKit

class FavoriteDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var favorites:[String] = []
    
    @IBOutlet weak var favTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favTable.delegate = self
        favTable.dataSource = self
        let fault = UserDefaults.standard
        favorites = fault.stringArray(forKey: "Faved") ?? [String]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let defaults = UserDefaults.standard
            self.favorites = defaults.stringArray(forKey: "Faved") ?? [String]()
            
            DispatchQueue.main.async {
                self.favTable.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated);
        let defaults = UserDefaults.standard
        favorites = defaults.stringArray(forKey: "Faved") ?? [String]()
        self.favTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favMovie = UITableViewCell(style: .default, reuseIdentifier: nil)
        favMovie.textLabel?.text = favorites[indexPath.row]
        
        return favMovie
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            favorites.remove(at: indexPath.row)
            favTable.deleteRows(at: [indexPath], with: .fade)
            UserDefaults.standard.set(favorites, forKey: "Faved")
        }
    }
    
}
