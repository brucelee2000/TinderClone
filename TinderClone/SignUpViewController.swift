//
//  SignUpViewController.swift
//  TinderClone
//
//  Created by Yosemite on 2/16/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    var user = PFUser.currentUser()
    
    @IBOutlet weak var genderSwitch: UISwitch!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func signUpButtonPressed(sender: UIButton) {
        if genderSwitch.on {
            println("Women chosen")
            self.user["interest"] = "female"
        } else {
            println("Men chose")
            self.user["interest"] = "male"
        }
        self.user.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        user = PFUser.currentUser()
        
        if let userImageData = user["image"] as? NSData {
            
            println("Image loaded from Parse")
            profileImage.image = UIImage(data: userImageData)
            
        } else {
            // +--- Access Facebook Information by URL ---+
            // +------------------------------------------+
            
            // Step1. Gets the Facebook session for the current user
            var fbSession = PFFacebookUtils.session()
            // Step2. Obtain facebook access token
            var userAccessToken = fbSession.accessTokenData.accessToken
            // Step3. Locate user profile picture URL
            let profileImageURL = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + userAccessToken)
            // Step4. Create URL request
            let profileImageURLRequest = NSURLRequest(URL: profileImageURL!)
            // Step5. Send the request
            NSURLConnection.sendAsynchronousRequest(profileImageURLRequest, queue: NSOperationQueue.mainQueue()) { (webResponse:NSURLResponse!, webData:NSData!, webError:NSError!) -> Void in
                let image = UIImage(data: webData)
                self.profileImage.image = image
                println("Image loaded from facebook")
                
                // Save profile image data onto Parse if user image doesnt exist
                self.user["image"] = webData
                self.user.save()
            }
        }
        
        // +--- Access Facebook Profile Info by API ---+
        // +-------------------------------------------+
        
        /*
        // Method 1. Call "startForMeWithCompletionHandler"
        FBRequestConnection.startForMeWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            println(result)
        }
        */
        
        // Method 2. Call "startWithCompletionHandler"
        var userFBRequest = FBRequest.requestForMe()
        // Simple method to make a graph API request for user info (/me).
        userFBRequest.startWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            // Save profile information onto Parse
            self.user["gender"] = result["gender"]
            self.user["name"] = result["name"]
            self.user["email"] = result["email"]
            self.user.save()
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
