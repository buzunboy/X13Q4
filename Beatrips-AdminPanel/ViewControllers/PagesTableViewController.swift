//
//  PagesTableViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 14.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseDatabase

var selectedPageID = ""

class PagesTableViewController: UITableViewController {
    
    var ref = Database.database().reference()
    var Pages = [PagesModel]()
    var refreshControls = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControls.attributedTitle = NSAttributedString(string: "Let's see what is new?")
        refreshControls.addTarget(self, action: #selector(PagesTableViewController.getPages), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControls)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        Pages.removeAll()
        self.tableView.reloadData()
        getPages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPages(){
        Pages.removeAll()
        ref.child("Pages").observe(.childAdded, with: { (snapshot) in
            if let pageID = snapshot.key as? String {
                self.ref.child("Pages").child(pageID).observe(.value, with: { (snap) in
                    var pageName = snap.childSnapshot(forPath: "Name").value as? String ?? ""
                    if(pageName != ""){
                        
                        let isActive = snap.childSnapshot(forPath: "isActive").value as? String ?? "0"
                        if(isActive != "0"){
                            self.Pages.append(PagesModel(name: pageName, ID: pageID as? String ?? ""))
                        }
                        
                    }
                    self.tableView.reloadData()
                })
            }
        })
        refreshControls.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Pages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pagesCell", for: indexPath)
        
        cell.textLabel?.text = Pages[indexPath.row].name
        cell.detailTextLabel?.text = Pages[indexPath.row].ID
        
        // Configure the cell...
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deactivate = ["isActive":"0"]
            ref.child("Pages").child(Pages[indexPath.row].ID).updateChildValues(deactivate)
            // tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            getPages()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPageID = Pages[indexPath.row].ID
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
