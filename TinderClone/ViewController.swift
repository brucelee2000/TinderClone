//
//  ViewController.swift
//  TinderClone
//
//  Created by Yosemite on 2/12/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set required permission when user login facebook
        var permissions = ["public_profile", "email"]
        
        // Simple code to login and signup
        PFFacebookUtils.logInWithPermissions(permissions, {(user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                println("Uh oh. The user cancelled the Facebook login.")
            } else if user.isNew {
                println("User signed up and logged in through Facebook!")
            } else {
                println("User logged in through Facebook!")
            }
        })
        
        // Add customized element manully
        let screenCenterX = self.view.bounds.width / 2
        let screenCenterY = self.view.bounds.height / 2
        
        var myLabel:UILabel = UILabel(frame: CGRectMake(screenCenterX - 100, screenCenterY - 50, 200, 100))
        myLabel.text = "Drag Me"
        myLabel.textAlignment = NSTextAlignment.Center      // Align text to center
        
        self.view.addSubview(myLabel)
        
        // Add guesture for dragging
        var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        // Add guesture to customized element
        myLabel.addGestureRecognizer(gesture)
        // Enable user interaction for customized element
        myLabel.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func wasDragged(guesture:UIPanGestureRecognizer) {
        // The translation of the pan gesture in the coordinate system of the specified view.
        let translation = guesture.translationInView(self.view)
        // Obtain the element inside the dragging item
        var label = guesture.view!
        // Set the new coordinate of the dragged element
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        // Reset translation for next movement
        guesture.setTranslation(CGPointZero, inView: self.view)
        println("Draaaaaaagged!")
    }

}

