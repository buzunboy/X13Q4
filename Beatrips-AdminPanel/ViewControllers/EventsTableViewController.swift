//
//  EventsTableViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 2.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseDatabase

var approvedEvent: [String] = []
var dateList: [String] = []
var list: [String] = []
var venueLists: [String] = ["8087014348"]
var pictureList: [String] = []
var eventIDList: [String] = []
var selectedID: String = ""
var ref = Database.database().reference()

class cellClass: UITableViewCell{
    
    @IBOutlet weak var eventLink: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var venueDateName: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var editorChoiceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var approveButtonView: UIButton!
    
    
    
    @IBAction func approveButton(_ sender: Any) {
        
        let addedDictionary = [
        "EventName":eventName.text,
        "DateAndVenue":venueDateName.text
        ]
        ref.child("Events").child(eventLink.text!).setValue(addedDictionary)
       
        if(approvedEvent.contains(eventLink.text!)){
            approveButtonView.setTitle("Approved", for: .normal)
            approveButtonView.backgroundColor = UIColor.blue
        } else {
            approveButtonView.backgroundColor = UIColor.orange
            approveButtonView.setTitle("Approves", for: .normal)
        }
        approvedEvent.append(eventLink.text!)
        
    }
    
    
}

class EventsTableViewController: UITableViewController {
    
    @IBOutlet var tableList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.setHidesBackButton(true, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewDidAppear(_ animated: Bool) {
        getList()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    
    func getList(){
        
        if FBSDKAccessToken.current() != nil {
            
            for venue in venueLists{
                let venueEventID = "/" + venue + "/events"
                let request: FBSDKGraphRequest  = FBSDKGraphRequest(graphPath: venueEventID, parameters: ["fields": "id, name, start_time, picture, place"])
                request.start { (connection, results, error) in
                    
                    // Something went wrong
                    if (error != nil) {
                        print(error as Any)
                    }
                    // print(results)
                    
                    if let eventData = results as? NSDictionary{
                        
                        let events = eventData["data"] as? NSArray
                        for event in events! {
                            let eventDictionary = event as? NSDictionary
                            let eventName = eventDictionary?["name"] as! String
                            let eventID = eventDictionary?["id"] as! String
                            eventIDList.append(eventID)
                            let eventDate = eventDictionary?["start_time"] as! String
                            var dateArray = eventDate._split(separator: "-")
                            let month = dateArray[1]
                            let dayArray = dateArray[2]._split(separator: "T")
                            let date = dayArray[0]
                            var timeArray = dayArray[1]._split(separator: ":")
                            let hour = timeArray[0]
                            let minutes = timeArray[1]
                            let pictureData = eventDictionary?["picture"] as? NSDictionary
                            let picture = pictureData?["data"] as? NSDictionary
                            let pictureURL = picture?["url"] as! String
                            pictureList.append(pictureURL)
                            list.append(eventName)
                            let venuesData = eventDictionary?["place"] as? NSDictionary
                            let venueName = venuesData?["name"] as? String
                            let convertedDate = String(date) + " " + convertMonth(month: month) + " " + String(hour) + ":" + String(minutes)
                            dateList.append(venueName! + " @ " + convertedDate)
                            self.tableList.reloadData()
                        }
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! cellClass
        
        cell.eventName.text = list[indexPath.row]
        cell.venueDateName.text = dateList[indexPath.row]
        cell.eventLink.text = eventIDList[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedID = eventIDList[indexPath.row]
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
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
