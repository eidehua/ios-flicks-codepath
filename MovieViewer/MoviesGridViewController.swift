//
//  MoviesGridViewController.swift
//  MovieViewer
//
//  Created by Edward Xue on 1/12/16.
//  Copyright © 2016 eidehua. All rights reserved.
//

import UIKit

class MoviesGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    
    var movies : [NSDictionary]?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        networkErrorView.hidden = true
        
        // Do any additional setup after loading the view.
        collectionView.backgroundColor = UIColor.whiteColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //rows
        if let movies = movies {
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
        let movie = movies![indexPath.row+(indexPath.section*2)]

        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imgUrl = NSURL(string: 	baseUrl + posterPath)
        
        cell.imageView.setImageWithURL(imgUrl!) //Cocoapod AFNetworking
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toList") {
            let secondViewController = segue.destinationViewController as! MoviesViewController
            secondViewController.movies = movies
        }
    }
    

}
