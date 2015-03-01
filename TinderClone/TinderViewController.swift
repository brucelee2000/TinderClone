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

    var xFromCenter:CGFloat = 0
    
    var userNamesList:[String] = []
    var userImagesList:[NSData] = []
    var currentShownUser = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var currentUser = PFUser.currentUser()
        
        // Update user location with Parse
        PFGeoPoint.geoPointForCurrentLocationInBackground { (myGeopoint:PFGeoPoint!, error:NSError!) -> Void in
            if error != nil  {
                println(error)
            } else {
                println(myGeopoint)
                currentUser["location"] = myGeopoint
                
                // Create a query for places
                var query = PFUser.query()
                // Interested in locations near user
                query.whereKey("location", nearGeoPoint: myGeopoint)
                
                // +--- Multiple query seems to have bugs in Parse ---+
                // +--------------------------------------------------+
                // Condition1. Select the corrsponding interest
                //query.whereKey("gender", equalTo: user["interest"])
                // Condition2. Exclude current user
                //query.whereKey("username", notEqualTo: PFUser.currentUser().username)

                // Limit what could be lots of points
                query.limit = 10
                // Final list of objects
                query.findObjectsInBackgroundWithBlock({ (usersFound:[AnyObject]!, error:NSError!) -> Void in
                    if error != nil {
                        println(error)
                    } else {
                        
                        var acceptedUsers:[String] = []
                        var rejectedUsers:[String] = []
                       
                        if let accepted = currentUser["accepted"] as? [String] {
                            acceptedUsers = accepted
                        }
                        
                        if let rejected = currentUser["rejected"] as? [String] {
                            rejectedUsers = rejected
                        }

                        println(acceptedUsers)
                        println(rejectedUsers)
                        
                        for user in usersFound {
                            println(user.username)
                            
                            // Set criteria here instead of buggy Parse query condition
                            let userGender = user["gender"] as String
                            let currentUserInterest = currentUser["interest"] as String
                            
                            // Exclude the users already in rejected list and accepted list
                            if userGender == currentUserInterest && currentUser.username != user.username && !contains(acceptedUsers, user.username) && !contains(rejectedUsers, user.username){
                                println("Showing..\(user.username)")
                                self.userNamesList.append(user.username)
                                self.userImagesList.append(user["image"] as NSData)
                            }
                            

                        }
                        
                        // Check if found user list is empty
                        if self.userNamesList.isEmpty {
                            println("ERROR")
                            self.showAlertWithText(header: "Sorry", message: "No girls for you atm")
                            // TO do: quit to other VC
                        } else {
                        
                            // Add customized element manully
                            let screenCenterX = self.view.bounds.width / 2
                            let screenCenterY = self.view.bounds.height / 2
                            
                            var userImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            userImageView.image = UIImage(data: self.userImagesList[0])
                            userImageView.contentMode = UIViewContentMode.ScaleAspectFit
                            
                            self.view.addSubview(userImageView)
                            
                            // --- Drag an element ---
                            // Add guesture for dragging
                            var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
                            // Add guesture to customized element
                            userImageView.addGestureRecognizer(gesture)
                            // Enable user interaction for customized element
                            userImageView.userInteractionEnabled = true
                            
                            // --- Rotate an element ---
                            // Create an affine transformation matrix constructed from a rotation (radians) value you provide.
                            var rotation:CGAffineTransform = CGAffineTransformMakeRotation(0)
                            // Apply rotation transform to the element
                            userImageView.transform = rotation
                        
                        }
                        
                    }
                })
                
                currentUser.saveInBackgroundWithBlock(nil)         // user.save() takes too much time in realtime
            }
        }
        
        /*
        // Add some fake users
        for var index = 0; index < newUserArray.count; index++ {
            addPerson(newUserArray[index], count: index)
        }
        */
        

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
    
    func wasDragged(guesture:UIPanGestureRecognizer) {
        // The translation of the pan gesture in the coordinate system of the specified view.
        let translation = guesture.translationInView(self.view)
        // Obtain the element inside the dragging item
        var label = guesture.view!
        
        xFromCenter += translation.x
        var scaleNumber = min(70 / abs(xFromCenter), 1)
        
        // --- Animation for the draggging element ---
        // Set the new coordinate of the dragged element
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        // Reset translation for next movement
        guesture.setTranslation(CGPointZero, inView: self.view)
        
        // --- Animation for the rotating element ---
        // Create an affine transformation matrix constructed from a rotation (radians) value you provide.
        // - similarly, CGAffineTransformRotate(t: CGAffineTransform, angle: CGFloat)
        var rotation:CGAffineTransform = CGAffineTransformMakeRotation(xFromCenter / (self.view.bounds.width / 2))
        // Apply rotation transform to the element
        label.transform = rotation
        
        // --- Animation for scaling an element ---
        // Create an affine transformation matrix constructed by scaling an existing affine transform.
        var scaling:CGAffineTransform = CGAffineTransformScale(rotation, scaleNumber, scaleNumber)
        // Apply scaling transform to the element
        label.transform = scaling
        
        // Check the guesture status
        if guesture.state == UIGestureRecognizerState.Ended {
            
            // Check if the dragged element is out of defined boundary
            if label.center.x < 100 {
                println("Not chosen")
                
                // Add user to Parse Array
                // - without duping element by "addUniqueObject"
                PFUser.currentUser().addUniqueObject(self.userNamesList[self.currentShownUser], forKey: "rejected")
                PFUser.currentUser().saveInBackgroundWithBlock(nil)
                
            } else if label.center.x > (self.view.bounds.width - 100) {
                println("Chosen")
                
                // Add user to Parse Array 
                // - without duping element by "addUniqueObject"
                PFUser.currentUser().addUniqueObject(self.userNamesList[self.currentShownUser], forKey: "accepted")
                PFUser.currentUser().saveInBackgroundWithBlock(nil)
            }
            
            xFromCenter = 0
            currentShownUser++
            
            // Remove the old ImageView
            label.removeFromSuperview()
            
            // Add the new ImageView
            var userImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
            if currentShownUser >= userImagesList.count {
                userImageView.image = UIImage(named: "femalePlaceHolder.jpeg")
            } else {
                userImageView.image = UIImage(data: self.userImagesList[currentShownUser])
            }

            userImageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            self.view.addSubview(userImageView)
            
            // --- Drag an element ---
            // Add guesture for dragging
            var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
            // Add guesture to customized element
            userImageView.addGestureRecognizer(gesture)
            // Enable user interaction for customized element
            userImageView.userInteractionEnabled = true
            
            // --- Rotate an element ---
            // Create an affine transformation matrix constructed from a rotation (radians) value you provide.
            var rotation:CGAffineTransform = CGAffineTransformMakeRotation(0)
            // Apply rotation transform to the element
            userImageView.transform = rotation

        }
    }
    
    func showAlertWithText(header:String = "Warning", message:String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            // Dismiss current VC and back to previous one
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion:nil)
    }

}
