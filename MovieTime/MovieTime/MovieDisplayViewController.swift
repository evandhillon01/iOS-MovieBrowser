//
//  MovieDisplayViewController.swift
//  MovieTime
//
//  Created by Evan Dhillon on 10/22/17.
//  Copyright © 2017 Evan Dhillon. All rights reserved.
//

import Foundation
import UIKit

class MovieDisplayViewController: UIViewController {
    
    var info: movie!
    var image: UIImage!
    var isMovie: Bool!
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var movieRelease: UILabel!
    @IBOutlet weak var movieLanguage: UILabel!
    @IBOutlet weak var movieRuntime: UILabel!
    
    @IBAction func addToFavourites(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Added To Favorites", message:
            "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        
        let toAdd = info.name
        
        let defaults = UserDefaults.standard
        var favedArray = defaults.stringArray(forKey: "Faved") ?? [String]()
        
        if favedArray.count == 0{
            favedArray = [toAdd]
        }
        else{
            if favedArray.contains(toAdd){
                alertController.title = "Movie Already Favorited"
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                favedArray.append(toAdd)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        defaults.set(favedArray, forKey: "Faved")
    }
    
    
    @IBAction func similarMovies(_ sender: Any) {
        self.performSegue(withIdentifier: "showSimilarMovies", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showSimilarMovies"){
            
            let infoView = segue.destination as! SearchCollectionViewController
            
            infoView.search = info.name
        }
    }
    
    
    
    
    private func getJSON(path: String) -> JSON {
        guard let url = URL(string: path) else { return JSON.null }
        do {
            let data = try Data(contentsOf: url)
            return try JSON(data: data)
        }
        catch {
            return JSON.null
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let idStr = String(info.id)
        var thisUrl = ""
        if(isMovie){
            thisUrl = "https://api.themoviedb.org/3/movie/"+idStr+"?api_key=e9cf06d9f65ff54c36ddde7dbd65f9df"
        }
        else{
            thisUrl = "https://api.themoviedb.org/3/tv/"+idStr+"?api_key=e9cf06d9f65ff54c36ddde7dbd65f9df"
        }
        let data = getJSON(path: thisUrl)
        
        let rating = Double(round(100*data["vote_average"].doubleValue)/100)
        
        
        movieImage.image = image
        movieTitle.text = info.name
        movieRating.text = "Rating: " + String(rating)
        movieLanguage.text = "Language: " + data["original_language"].stringValue
        if(isMovie){
            movieRelease.text = "Released: " + data["release_date"].stringValue
            movieRuntime.text = "Runtime: " + data["runtime"].stringValue + " minutes"
        }
        else{
            movieRelease.text = "Released: " + data["first_air_date"].stringValue
            movieRuntime.text = "Number of Episodes: " + data["number_of_episodes"].stringValue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
