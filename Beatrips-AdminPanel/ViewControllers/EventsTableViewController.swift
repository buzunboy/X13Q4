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

var list: [String] = []
var venueLists: [String] = ["8087014348"]
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
    
    
}


class EventsTableViewController: UITableViewController, UISearchBarDelegate, UIViewControllerPreviewingDelegate {
    
    @IBOutlet var tableList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var EventList = [EventModel]()
    var refreshControls = UIRefreshControl()
    var filteredData = [EventModel]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.placeholder = "Search Event"
        
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self, sourceView: view)
            
        }
        refreshControls = UIRefreshControl()
        refreshControls.attributedTitle = NSAttributedString(string: "Let's see what is new?")
        refreshControls.addTarget(self, action: "refresh", for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControls)
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
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "EventDetailTableViewController") as? EventDetailTableViewController else { return nil }
        
        selectedID = EventList[indexPath.row].ID
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        show(viewControllerToCommit, sender: self)
        
    }
    
    func refresh(){
        getList()
        refreshControls.attributedTitle = NSAttributedString(string: "Let me check")
    }
    
    func getList(){
        let eventCount = EventList.count
        
        if FBSDKAccessToken.current() != nil {
            
            for venue in venueLists{
                let venueEventID = "/" + venue + "/events"
                let request: FBSDKGraphRequest  = FBSDKGraphRequest(graphPath: venueEventID, parameters: ["fields": "attending_count,category,cover,description,interested_count,name,owner,picture,ticket_uri,place,start_time"])
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
                            let eventID = eventDictionary?["id"] as! String
                            let placeData = eventDictionary?["place"] as? NSDictionary
                            let placeLocation = placeData?["location"] as? NSDictionary
                            let pictureData = eventDictionary?["cover"] as? NSDictionary
                            let eventName = eventDictionary?["name"] as! String
                            let eventDate = eventDictionary?["start_time"] as! String
                            var dateArray = eventDate._split(separator: "-")
                            let dayArray = dateArray[2]._split(separator: "T")
                            var timeArray = dayArray[1]._split(separator: ":")

                            let startTime = eventDictionary?["start_time"] as! String
                            var dateArrays = startTime._split(separator: "T")
                            var splitDate = dateArrays[0]._split(separator: "-")
                            
                            self.EventList.append(EventModel(name: eventName, ID: eventID, venue: placeData!["name"] as! String, venueID: placeData!["id"] as! String, image: pictureData!["source"] as! String, ticket: eventDictionary!["ticket_uri"] as? String ?? "", descriptionText: eventDictionary!["description"] as! String, day: splitDate[2], month: splitDate[1], year: splitDate[0], hour: timeArray[0], minute: timeArray[1], isApproved: "0", likeCount: "0", seenCount: "0", commentCount: "0", latitude: placeLocation!["latitude"] as? Double ?? 0, longitude: placeLocation!["longitude"] as? Double ?? 0))
                            self.tableView.reloadData()
                            
                        }
                    }
                    if (eventCount >= 1){
                        self.EventList.removeFirst(eventCount)
                        self.tableView.reloadData()
                        self.refreshControls.endRefreshing()
                        self.refreshControls.attributedTitle = NSAttributedString(string: "Let's see what is new?")
                    }
                    self.sendToDatabase()
                }
            }
        }
        
    }
    
    func sendToDatabase() {
        
        for event in EventList {
            ref.child("Events").child(event.ID).observe(.value, with: { (snapshot) in
                let isApproved = snapshot.childSnapshot(forPath: "isApproved").value as? String
                if (isApproved != "1"){
                    event.isApproved = "0"
                    let nonApproved = [
                        "EventName":event.name,
                        "VenueName":event.venue,
                        "EventImage":event.image,
                        "TicketLink": event.ticket,
                        "Details":event.descriptionText,
                        "Day":event.day,
                        "Month":event.month,
                        "Year":event.year,
                        "Hour":event.hour,
                        "Minutes":event.minute,
                        "VenueID":event.venueID,
                        "isApproved": "0",
                        "likeCount":"0",
                        "seenCount":"0",
                        "commentCount":"0",
                        "Latitude":event.latitude,
                        "Longitude":event.longitude
                        ] as [String : Any]
                    ref.child("Events").child(event.ID).updateChildValues(nonApproved)
                    self.tableView.reloadData()
                } else {
                    event.isApproved = "1"
                    self.tableView.reloadData()
                }
            })
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
        if isSearching {
            return filteredData.count
        } else {
            return EventList.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! cellClass
        
        if(isSearching){
            cell.eventImage.image = nil
            cell.eventName.text = filteredData[indexPath.row].name
            cell.venueDateName.text = filteredData[indexPath.row].venue + " @ " + filteredData[indexPath.row].day + " " + convertMonth(month: filteredData[indexPath.row].month) + " " + filteredData[indexPath.row].hour + ":" + filteredData[indexPath.row].minute
            cell.eventLink.text = filteredData[indexPath.row].ID
            cell.statusLabel.text = filteredData[indexPath.row].isApproved != "1" ? "Unapproved" : "Approved"
            
            let url = URL(string: filteredData[indexPath.row].image)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    cell.eventImage.image = UIImage(data: data!)
                }
            }
        } else {
            cell.eventImage.image = nil
            cell.eventName.text = EventList[indexPath.row].name
            cell.venueDateName.text = EventList[indexPath.row].venue + " @ " + EventList[indexPath.row].day + " " + convertMonth(month: EventList[indexPath.row].month) + " " + EventList[indexPath.row].hour + ":" + EventList[indexPath.row].minute
            cell.eventLink.text = EventList[indexPath.row].ID
            cell.statusLabel.text = EventList[indexPath.row].isApproved != "1" ? "Unapproved" : "Approved"
            
            let url = URL(string: EventList[indexPath.row].image)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    cell.eventImage.image = UIImage(data: data!)
                }
            }
        }
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil {
            isSearching = false
            filteredData = EventList
            view.endEditing(true)
            tableView.reloadData()
        } else if searchBar.text == "" {
            isSearching = false
            filteredData = EventList
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = EventList.filter({ (mod) -> Bool in
                return mod.name.lowercased().contains(searchBar.text!.lowercased()) || mod.venue.lowercased().contains(searchBar.text!.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(isSearching){
            selectedID = filteredData[indexPath.row].ID
        } else {
            selectedID = EventList[indexPath.row].ID
        }
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
