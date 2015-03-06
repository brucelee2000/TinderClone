# TinderClone
Facebook Framework Configuration
--------------------------------
The detailed steps can be found https://developers.facebook.com/docs/ios/getting-started

* **Step 1. Download and install facebook iOS SDK**

* **Step 2. Create a Facebook App**

  creating an App in facebook developer page to obtain its App id

* **Step 3. Configure an Xcode Project**

  Add the SDK for iOS to your project and configure your .plist file with App id.
  
* **Step 4. Start Coding by creating a bridge header file (xxx.h) with only this code inside**

        #import <FacebookSDK/FacebookSDK.h>
        
Integrate Parse with Facebook
-----------------------------
The details steps can be found https://www.parse.com/docs/ios_guide#fbusers/iOS

* **Step 1. Add Facebook Application ID on your Parse application's settings page**

* **Step 2. Download Parse iOS SDK and add *ParseFacebookUtils.framework* by dragging it into project folder**

* **Step 3. Add the following where you initialize the Parse SDK**
  
  Import this header into your Swift bridge header file
      
      #import <FacebookSDK/FacebookSDK.h>
      #import <Parse/Parse.h>
      #import <ParseFacebookUtils/PFFacebookUtils.h>

  Add these codes into function *didFinishLaunchingWithOptions* in AppDelegate.swift
  
      // First, Connect to Parse
      Parse.setApplicationId("****parseAppId****", clientKey: "****parseClientKey****")
      // Then, Initialize facebook Parse plugin
      PFFacebookUtils.initializeFacebook()

      
  Add following handles into AppDelegate.swift

      func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
          return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,withSession:PFFacebookUtils.session())
      }
      
      func applicationDidBecomeActive(application: UIApplication) {
          FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
      }  
    
Facebook&Parse - Login and Signup
---------------------------------
* **Method 1: Login/Signup as a Facebook user and creating a PFUser with method *logInWithPermissions*.**

        // Set required permission when user login facebook
        var permissions = ["public_profile", "email"]
        
        // Request permission
          PFFacebookUtils.reauthorizeUser(PFUser.currentUser(), withPublishPermissions:permissions, audience:FBSessionDefaultAudienceFriends, {(succeeded: Bool!, error: NSError!) -> Void in
            if succeeded {
              // Your app now has publishing permissions for the user
            }
          })
        
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
  
* **Method 2: Linking Facebook to an existing PFUser**

        // Link facebook with the existing PFUser
        if !PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
          PFFacebookUtils.linkUser(PFUser.currentUser(), permissions:permissions, {
            (succeeded: Bool!, error: NSError!) -> Void in
            if succeeded {
              println("Woohoo, user logged in with Facebook!")
            }
          })
        }
        
        // Unlink the user from his facebook account
        PFFacebookUtils.unlinkUserInBackground(PFUser.currentUser(), {(succeeded: Bool!, error: NSError!) -> Void in
          if succeeded {
            println("The user is no longer associated with their Facebook account.")
          }
        })

Facebook - Access profile information
-------------------------------------

* **Method 1: From URL and same as normal URL information retreivement**

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

* **Method 2: From Facebook API**

    * Call method *startForMeWithCompletionHandler*

            // Method 1. Call "startForMeWithCompletionHandler"
            FBRequestConnection.startForMeWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                println(result)
            }

    * Call method *startWithCompletionHandler*

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

Parse - Push Notication
-----------------------
* **Step 1. Push notification setup in AppDelegate**

        // Push notification setup
        // - Step1. Create alert type notification
        var pushSettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: .Alert, categories: nil)
        
        // - Step2. Registers your preferred options for notifying the user
        application.registerUserNotificationSettings(pushSettings)
        
        // - Step3. Register to receive push notifications via Apple Push Service.
        application.registerForRemoteNotifications()

* **Step 2. Configure Push notication related funactions in AppDelegate**

        // +-- Push Notification Related Functions --+
        // +-----------------------------------------+
        
        // Tells the delegate that the app successfully registered with Apple Push Service (APS)
        func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
            println("Success registered Push Notification")
        }
    
        // Sent to the delegate when Apple Push Service cannot successfully complete the registration process.
        func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
            println("Failed to register Push Notification")
        }
        
* **Step 3. Send push notification via Parse**

        // Send push notifcation via Parse
        var push = PFPush()
        push.setMessage("This is a test for push notification via Parse")
        push.sendPushInBackgroundWithBlock { (isSuccessful:Bool, error:NSError!) -> Void in
            println(isSuccessful)
        }
        
Parse - Update user location
----------------------------
        // Do any additional setup after loading the view.
        var user = PFUser.currentUser()
        
        // Update user location with Parse
        PFGeoPoint.geoPointForCurrentLocationInBackground { (myGeopoint:PFGeoPoint!, error:NSError!) -> Void in
            if error != nil  {
                println(error)
            } else {
                println(myGeopoint)
                user["location"] = myGeopoint
                
                // Create a query for places
                var query = PFUser.query()
                // Interested in locations near user
                query.whereKey("location", nearGeoPoint: myGeopoint)
                // Limit what could be lots of points
                query.limit = 10
                
                // Final list of objects
                query.findObjectsInBackgroundWithBlock({ (usersFound:[AnyObject]!, error:NSError!) -> Void in
                    for user in usersFound {
                        println(user.username)
                        self.userNamesList.append(user.username)
                        self.userImagesList.append(user["image"] as NSData)
                    }
                })
                
                user.saveInBackgroundWithBlock(nil)         // user.save() takes too much time in realtime
            }
        }

Drag an Element
---------------
* **Step 1. Add the element manually into VC**

        // Add customized element manully
        let screenCenterX = self.view.bounds.width / 2
        let screenCenterY = self.view.bounds.height / 2
        
        var userImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        userImageView.image = UIImage(named: "femalePlaceHolder.jpeg")
        userImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.view.addSubview(userImageView)
        
* **Step 2. Add action selector to the guesture**

        // Add action selector to guesture
        var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))

* **Step 3. Add guesture to the element and enable its interaction**

        // Add guesture to customized element
        userImageView.addGestureRecognizer(gesture)
        
        // Enable user interaction for customized element
        userImageView.userInteractionEnabled = true

* **Step 4. Add details for action selector**

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
            
            // Check if the dragged element is out of defined boundary
            if label.center.x < 100 {
                println("dragged into not chosen area")
            } else if label.center.x > (self.view.bounds.width - 100) {
                println("dragger into chosen area")
            }
            
            ...
            
            // Check the guesture status - Reset the element if dragging is over
            if guesture.state == UIGestureRecognizerState.Ended {
                xFromCenter = 0
                
                // Remove the old ImageView
                label.removeFromSuperview()
                
                // Add the new ImageView
                var userImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                userImageView.image = UIImage(named: "femalePlaceHolder.jpeg")
                userImageView.contentMode = UIViewContentMode.ScaleAspectFit
                
                self.view.addSubview(userImageView)
                
                // --- Drag an element ---
                // Add guesture for dragging
                var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
                // Add guesture to customized element
                userImageView.addGestureRecognizer(gesture)
                // Enable user interaction for customized element
                userImageView.userInteractionEnabled = true
                
                ...
                
                
            }
        }
    
    }

Rotate/Scale an Element
-----------------------
* **Step 0. Configure initial rotation for the element**

        // --- Rotate an element ---
        // Create an affine transformation matrix constructed from a rotation (radians) value you provide.
        var rotation:CGAffineTransform = CGAffineTransformMakeRotation(0)
        
        // Apply rotation transform to the element
        userImageView.transform = rotation
        
* **Step 1. Change the ratation and scaling for the element**

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
        
Send an Email
-------------
* **Method 1: Call default email client**

        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            // Compose Email subject and address
            var subject = "?subject=beautiful!"
            var url = NSURL(string: "mailto:" + emailsforContacts[indexPath.row] + subject)
            println(url!)
            // Call default email client to email
            UIApplication.sharedApplication().openURL(url!)
        }

* **Method 2: Send email in App**

  Use *MFMailComposeViewControllerDelegate* protocol in ViewController

  * **Step 1. Email content configuration**

          func configureMailComposeViewController() -> MFMailComposeViewController {
              // Setup for configuration
              let mailComposerVC = MFMailComposeViewController()
              mailComposerVC.mailComposeDelegate = self
              
              // Configuration
              var emailTitle = titleLabel.text
              var messageBody = bodyTextView.text
              //var toRecipts = ["ros4net@gmail.com"]
              var toRecipts = [email]
              mailComposerVC.setToRecipients(toRecipts)
              mailComposerVC.setSubject(emailTitle)
              mailComposerVC.setMessageBody(messageBody, isHTML: false)
              
              return mailComposerVC
          } 
          
  * **Step 2. Configure Email sending status**

          func showSendMailErrorAlert() {
              let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check your configuration and try again", delegate: self, cancelButtonTitle: "OK")
              sendMailErrorAlert.show()
          }

  * **Step 3. Add send/cancell action**

          @IBAction func cancellButtonPressed(sender: UIBarButtonItem) {
              self.dismissViewControllerAnimated(true, completion: nil)
          }
          
          
          @IBAction func sendEmailButtonPressed(sender: UIBarButtonItem) {
              let mailComposerVC = configureMailComposeViewController()
              
              // Check if the user has set up the device for sending email.
              if MFMailComposeViewController.canSendMail() {
                  self.presentViewController(mailComposerVC, animated: true, completion: { () -> Void in
                      println("Sent successfully!")
                  })
              } else {
                  self.showSendMailErrorAlert()
              }
          }
          
  * **Step 4. Configure the action after email is sent**

          // +--- Method for MFMailComposeViewControllerDelegate ---+
          // +---------------------------------------------------------------+
          
          // Tells the delegate that the user wants to dismiss the mail composition view.
          func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
              switch result.value {
              case MFMailComposeResultCancelled.value:
                  println("Mail cancelled")
              case MFMailComposeResultSaved.value:
                  println("Mail saved")
              case MFMailComposeResultSent.value:
                  println("Mail sent")
              case MFMailComposeResultFailed.value:
                  println("Mail sent failure: \(error.localizedDescription)")
              default:
                  break
              }
              self.dismissViewControllerAnimated(true, completion: nil)
          }
  
