//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Edward Xue on 1/18/16.
//  Copyright © 2016 eidehua. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            //basically same as if posterPath != nil, and also makes it non optional
            let imgUrl = NSURL(string: 	baseUrl + posterPath)
            posterImageView.setImageWithURL(imgUrl!) //From CocoaPod AFNetworking
        }
        else{
            posterImageView.image = UIImage(named:"/Users/edwardxue/Documents/Xcode/MovieViewer/MovieViewer/Assets.xcassets/1452942469_101_Warning.imageset/1452942469_101_Warning.png")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
