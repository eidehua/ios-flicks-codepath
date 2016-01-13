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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]? //optional: movies may be an array or nil
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        networkErrorView.hidden = true
        // Do any additional setup after loading the view.
        
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
                            self.tableView.reloadData()
                            SwiftLoader.hide()
                    }
                }
                if error != nil {
                    //Network Error!
                    self.networkErrorView.hidden = false
                    SwiftLoader.hide()
                }
        });
        task.resume()
        
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
        
        SwiftLoader.show(title: "Loading...", animated: true)
        if movies != nil {
            SwiftLoader.hide()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //tableView and section are parameters
        //if movies is not nil, then assign it to a constant called movies
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        //! = unwrap = tell compiler I am SURE movies is not nil
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imgUrl = NSURL(string: 	baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imgUrl!) //From CocoaPod AFNetworking
        print("row \(indexPath.row)")
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
        print("hi")
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
