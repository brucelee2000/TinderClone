//
//  MailViewController.swift
//  TinderClone
//
//  Created by Yosemite on 2/28/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit
import MessageUI

class MailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var name = ""
    var email = ""
    
    @IBOutlet weak var mailVCTitle: UINavigationItem!
    
    @IBOutlet weak var emailAddressLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UITextField!
    
    @IBOutlet weak var bodyTextView: UITextView!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check your configuration and try again", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // +--- Method for MFMailComposeViewControllerDelegate ---+
    // +---------------------------------------------------------------+
    
    // Tells the delegate that the user wants to dismiss the mail composition view.
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        mailVCTitle.title = "New Message"
        emailAddressLabel.text = email
        bodyTextView.text = "Hi, \(name)\n"
        
    }
    
}
