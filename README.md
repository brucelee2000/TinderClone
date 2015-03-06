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

    2a. Call method *startForMeWithCompletionHandler*

        // Method 1. Call "startForMeWithCompletionHandler"
        FBRequestConnection.startForMeWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            println(result)
        }

    2b. Call method *startWithCompletionHandler*

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

    

