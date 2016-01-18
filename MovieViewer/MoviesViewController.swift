//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Edward Xue on 1/8/16.
//  Copyright © 2016 eidehua. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftLoader

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]? //optional: movies may be an array or nil
    var refreshControl: UIRefreshControl!
    var filteredMovies: [NSDictionary]?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        networkErrorView.hidden = true
        
        gridView.dataSource = self
        gridView.delegate = self
        gridView.hidden = true
        
        searchBar.delegate = self

        // Do any additional setup after loading the view.

        gridView.backgroundColor = UIColor.whiteColor()
        
        //Movies API Now Playing
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            //set our instance movies variable to the jsonArray (which is the value of key="results" we know it is an [NSDictionary] so we force it to be, and we do as! to take our optional jsonArray to an actual concrete value. Thus we get an optional array of NSDictionary, aka [NSDictionary]?
                         	self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.tableView.reloadData()
                            self.gridView.reloadData()
                            SwiftLoader.hide()
                    }
                }
                if error != nil {
                    //Network Error!
                    self.networkErrorView.hidden = false
                    SwiftLoader.hide()
                }
        });
        if movies == nil {
            task.resume()
        }
        //pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 150
        config.spinnerColor = .redColor()
        config.foregroundColor = .blackColor()
        config.foregroundAlpha = 0.5
        SwiftLoader.setConfig(config)
        
        if movies == nil {
            SwiftLoader.show(title: "Loading...", animated: true)	
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Conforming to protocol UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tableView and section are parameters
        //if movies is not nil, then assign it to a constant called movies
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        //! = unwrap = tell compiler I am SURE movies is not nil
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as? String
        if posterPath != nil {
            let imgUrl = NSURL(string: 	baseUrl + posterPath!)
            cell.posterView.setImageWithURL(imgUrl!) //From CocoaPod AFNetworking
        }
        else{
         cell.posterView.image = UIImage(named:"/Users/edwardxue/Documents/Xcode/MovieViewer/MovieViewer/Assets.xcassets/1452942469_101_Warning.imageset/1452942469_101_Warning.png")
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        print("row \(indexPath.row)")
        return cell
    }
    
    //Conforming to protocol UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //rows
        if let movies = filteredMovies {
            if (movies.count % 2 == 0){
                //even
                return movies.count/2
            }
            else{
                //odd, say 5/2 = 2.5 rounds to 2, but we need to display 5 movies so need 3 rows
                return movies.count/2 + 1
            }
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //columns
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCellCollection", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        // Configure the cell
        cell.testLabel.text = "\(indexPath.row+(indexPath.section*2))"
        /*
        indexPath.row =  0  1 ;   0  1 ; etc...
        indexPath.section = 0  0 ;  0  0 ;
        so the math makes it do 0  1 ;  2  3 ;  etc...
        */
        let movie = filteredMovies![indexPath.row+(indexPath.section*2)]
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as? String
        if posterPath != nil {
            let imgUrl = NSURL(string: 	baseUrl + posterPath!)
            cell.imageView.setImageWithURL(imgUrl!) //From CocoaPod AFNetworking
        }
        else {
        cell.imageView.image = UIImage(named:"/Users/edwardxue/Documents/Xcode/MovieViewer/MovieViewer/Assets.xcassets/1452942469_101_Warning.imageset/1452942469_101_Warning.png")
        }
        return cell
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    
    @IBAction func onGridButtonTouchUpInside(sender: AnyObject) {
       let currState =  toggleButton.titleLabel?.text!
        print("hii")
        if currState == "Grid" {
            print("1")
            toggleButton.setTitle("Text", forState: .Normal)
            gridView.hidden = false;
            tableView.hidden = true;
        }
        else {
            print("2")
            toggleButton.setTitle("Grid", forState: .Normal)
            tableView.hidden = false;
            gridView.hidden = true;
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({(movie: NSDictionary) -> Bool in
            //return movie["title!"]!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        tableView.reloadData()
        gridView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toGrid") {
            let secondViewController = segue.destinationViewController as! MoviesGridViewController
            secondViewController.movies = movies
        }
    }
    

}
