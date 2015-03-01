//
//  ContactsTableViewController.swift
//  TinderClone
//
//  Created by Yosemite on 2/24/15.
//  Copyright (c) 2015 Yosemite. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    
    var imagesforContacts:[NSData] = []
    var emailsforContacts:[String] = []
    var namesforContacts:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        var query = PFUser.query()
        // Find users who have accepted current user
        query.whereKey("accepted", equalTo: PFUser.currentUser().username)
        // Find users who have been accepted by current user
        query.whereKey("username", containedIn: PFUser.currentUser()["accepted"] as [AnyObject])
        // Execute the query
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error != nil {
                println(error)
            } else {
                for result in results {
                    self.imagesforContacts.append(result["image"] as NSData)
                    self.emailsforContacts.append(result["email"] as String)
                    self.namesforContacts.append(result["name"] as String)
                }
                
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return emailsforContacts.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = namesforContacts[indexPath.row]
        cell.imageView?.image = UIImage(data: imagesforContacts[indexPath.row])

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Compose Email subject and address
        var subject = "?subject=beautiful!"
        var url = NSURL(string: "mailto:" + emailsforContacts[indexPath.row] + subject)
        println(url!)
        // Call default email client to email
        UIApplication.sharedApplication().openURL(url!)
    }

}
