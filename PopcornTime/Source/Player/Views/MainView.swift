//
//  MainView.swift
//  PopcornTime
//
//  Created by Abel Pascual on 28/01/16.
//  Copyright © 2016 com.PPinera. All rights reserved.
//

import UIKit
import Alamofire

import AVKit
import AVFoundation
import PopcornTorrent


class MainView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var _movies: NSArray?
    var movies: NSArray? {
        get {
            return self._movies
        }
        set {
            self._movies = newValue
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMovies()
    }
    
    func loadMovies() {
        Alamofire.request(.GET, "https://yts.ag/api/v2/list_movies.json?sort_by=download_count", parameters: nil, encoding:.JSON).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
//                print("Success with JSON: \(JSON)")
                
                let response = JSON as! NSDictionary
                let status = response["status"] as! String
                if(status == "ok") {
                    self.movies = response["data"]!["movies"] as? NSArray
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath)
        
        let movieDic = self.movies![indexPath.row] as! NSDictionary
        let titleString = movieDic["title"] as! String
        let coverImageString = movieDic["large_cover_image"] as! String
        
        (cell as! MovieCollectionViewCell).titleLabel.text = titleString

        Alamofire.request(.GET, coverImageString).response() {
            (_, _, data, _) in
            let image = UIImage(data: data! )
            (cell as! MovieCollectionViewCell).posterImageView.image = image
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(213, 380)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let movieDic = self.movies![indexPath.row] as! NSDictionary
        let torrentURL = movieDic["torrents"]?[0]["url"] as! String

        let playerView = PlayerView()
        playerView.torrentUrl = torrentURL
        self .presentViewController(playerView, animated: true) { () -> Void in
            //
        }
    }

    func playURL(torrentUrl: String) {
        
    }
}
