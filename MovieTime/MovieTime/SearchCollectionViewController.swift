//
//  SearchCollectionViewController.swift
//  MovieTime
//
//  Created by Evan Dhillon on 10/22/17.
//  Copyright © 2017 Evan Dhillon. All rights reserved.
//

import UIKit

class SearchCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var tvSwitch: UISwitch!
    @IBOutlet weak var filterBar: UISearchBar!
    @IBOutlet weak var movieCollection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityWheel: UIActivityIndicatorView!
    
    var currentMovies = [movie]()
    var currentShows = [movie]()
    var imageStore = [UIImage]()
    var search = "Star Wars"
    var filter = ""
    
    @IBAction func tvSwitchChanged(_ sender: Any) {
        showSearchResults()
    }
    
    func showSearchResults(){
        
        if(tvSwitch.isOn){
            movieCollection.reloadData()
            
            currentMovies.removeAll()
            imageStore.removeAll()
            
            
            self.activityWheel.startAnimating()
            self.activityWheel.isHidden = false
            
            let editedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            let apiKey = "e9cf06d9f65ff54c36ddde7dbd65f9df"
            let searchURL = "https://api.themoviedb.org/3/search/tv?api_key="+apiKey+"&query="+editedSearch!
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getTVInfo(url: searchURL)
                self.storeImages()
                DispatchQueue.main.async {
                    self.movieCollection.reloadData()
                    self.activityWheel.stopAnimating()
                    self.activityWheel.isHidden = true
                }
            }
        }
        else{
            movieCollection.reloadData()
            
            currentMovies.removeAll()
            imageStore.removeAll()
            
            
            self.activityWheel.startAnimating()
            self.activityWheel.isHidden = false
            
            let editedSearch = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            
            let apiKey = "e9cf06d9f65ff54c36ddde7dbd65f9df"
            let searchURL = "https://api.themoviedb.org/3/search/movie?api_key="+apiKey+"&query="+editedSearch!
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.getMovieInfo(url: searchURL)
                self.storeImages()
                DispatchQueue.main.async {
                    self.movieCollection.reloadData()
                    self.activityWheel.stopAnimating()
                    self.activityWheel.isHidden = true
                }
            }
        }

    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == self.searchBar {
            search = searchBar.text!
            showSearchResults()
        } else if searchBar == self.filterBar{
            filter = filterBar.text!
            showSearchResults()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentMovies.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! SearchCollectionViewCell
        
        if(imageStore.isEmpty && currentMovies.isEmpty){
            
            return cell
        }
        else{
            
            let poster:UIImage = imageStore[indexPath.row]
            
            cell.movieImage.image = poster
            
            cell.movieTitle.text = currentMovies[indexPath.row].name
            
            return cell
        }
    }
    
    func collectionView(_ collectionView:
        UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showMovieInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showMovieInfo"){
            let indexPaths = self.movieCollection.indexPathsForSelectedItems
            let indexPath = indexPaths![0] as IndexPath
            
            let infoView = segue.destination as! MovieDisplayViewController
            
            infoView.info = currentMovies[indexPath.row]
            infoView.image = imageStore[indexPath.row]
            infoView.title = self.currentMovies[indexPath.row].name
            infoView.isMovie = currentMovies[indexPath.row].isMovie
        }
    }
    
    private func getMovieInfo(url: String) {
        let movieData = getJSON(path: url)
        for result in movieData["results"].arrayValue {
            let title = result["original_title"].stringValue
            if title.range(of:filter) != nil {
                continue
            }
            let imgURL = result["poster_path"].stringValue
            let runTime = result["runtime"].floatValue
            let date = result["release_date"].stringValue
            let language = result["original_language"].stringValue
            let id = result["id"].intValue
            currentMovies.append(movie(name: title, imageURL: imgURL, language: language, releaseDate: date, runtime: runTime, id: id, isMovie: true))
        }
    }
    
    private func getTVInfo(url: String) {
        let tvData = getJSON(path: url)
        for result in tvData["results"].arrayValue {
            let title = result["name"].stringValue
            if title.range(of:filter) != nil {
                continue
            }
            let imgURL = result["poster_path"].stringValue
            let runTime = result["number_of_episodes"].floatValue
            let date = result["original_air_date"].stringValue
            let language = result["original_language"].stringValue
            let id = result["id"].intValue
            currentMovies.append(movie(name: title, imageURL: imgURL, language: language, releaseDate: date, runtime: runTime, id: id, isMovie: false))
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

    private func storeImages() {
        for mov in currentMovies {
            let imgURL = "https://image.tmdb.org/t/p/w500/"+mov.imageURL
            let movImg = URL(string: imgURL)
            let data = try? Data(contentsOf: movImg!)
            if (data == nil){
                let image = UIImage?(#imageLiteral(resourceName: "noImage"))
                imageStore.append(image!)
            }
            else{
                let image = UIImage(data: data!)
                imageStore.append(image!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scnSize = UIScreen.main.bounds
        let scnWidth = scnSize.width
        let scnHeight = scnSize.height
        
        
        let format: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        format.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 12, right: 12)
        format.itemSize = CGSize(width: scnWidth / 3.6, height: scnHeight / 4.5)
        
        movieCollection.dataSource = self
        movieCollection.delegate = self
        searchBar.delegate = self
        filterBar.delegate = self
        movieCollection.collectionViewLayout = format
        
        
        self.view.addSubview(self.activityWheel)
        self.activityWheel.startAnimating()
        self.activityWheel.isHidden = true
        
        showSearchResults()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.storeImages()
            
            DispatchQueue.main.async {
                self.movieCollection.reloadData()
                self.activityWheel.isHidden = true
                self.activityWheel.stopAnimating()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
