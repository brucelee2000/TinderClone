//
//  TinderViewController.swift
//  TinderClone
//
//  Created by Yosemite on 2/16/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class TinderViewController: UIViewController {
    
    var newUserArray:[String] = [
        "http://img.allw.mn/content/www/2009/08/evangeline-fin-1.jpg",
        "http://img.allw.mn/content/www/2009/08/leona-fin-1.jpg",
        "http://img.allw.mn/content/www/2009/08/cameron-fin-1.jpg",
        "http://img.allw.mn/content/www/2009/08/mila-kunis-fin.jpg",
        "http://img.allw.mn/content/www/2009/08/aishwarya-fin.jpg",
        "http://img.allw.mn/content/www/2009/08/scarlet-fin-2.jpg",
        "http://img.allw.mn/content/www/2009/08/charlize-fin-fin.jpg",
        "http://img.allw.mn/content/www/2009/08/jessica-fin-1.jpg",
        "http://img.allw.mn/content/www/2009/08/megan-fox-1.jpg"
        ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var user = PFUser.currentUser()
        
        // Update user location with Parse
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint:PFGeoPoint!, error:NSError!) -> Void in
            if error != nil  {
                println(error)
            } else {
                println(geopoint)
                user["location"] = geopoint
                user.saveInBackgroundWithBlock(nil)         // user.save() takes too much time in realtime
            }
        }
        
        for var index = 0; index < newUserArray.count; index++ {
            addPerson(newUserArray[index], count: index)
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
    
    func addPerson(urlString:String, count:Int) {
        var newUser = PFUser()
        
        // Step1. Locate user profile picture URL
        let profileImageURL = NSURL(string: urlString)
        // Step2. Create URL request
        let profileImageURLRequest = NSURLRequest(URL: profileImageURL!)
        // Step3. Send the request
        NSURLConnection.sendAsynchronousRequest(profileImageURLRequest, queue: NSOperationQueue.mainQueue()) { (webResponse:NSURLResponse!, webData:NSData!, webError:NSError!) -> Void in
            if webError != nil {
                println(webError)
            } else {
                // Save profile image data onto Parse if user image doesnt exist
                newUser["image"] = webData
                newUser["gender"] = "female"
                
                // Fake the location for the new user
                var lat = Double(37 + count * 3)
                var lon = Double(-122 + count * 3)
                var location = PFGeoPoint(latitude: lat, longitude: lon)
                newUser["location"] = location
                
                newUser.username = "FakeUser \(count)"
                newUser.password = "password"
                
                // Add the new user into Parse
                newUser.signUp()
            }
        }

    }

}
