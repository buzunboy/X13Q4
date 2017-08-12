//
//  EventDetailTableViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 11.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseDatabase
import MapKit



class EventDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var ticketLink: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    
    @IBOutlet weak var isApprovedLabel: UILabel!
    @IBOutlet weak var seenCountLabel: UILabel!
    @IBOutlet weak var likedCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var hiddenImageURL: UILabel!
    @IBOutlet weak var seeMore: UIButton!
    
    var selectedRow = -1
    
    @IBOutlet weak var descriptionTextBottomConstraint: NSLayoutConstraint!
    
    var currentStyle = UIStatusBarStyle.lightContent
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStyle
    }
    
    @IBAction func swipedLeft(_ sender: Any) {
        self.performSegue(withIdentifier: "goBack", sender: self)
    }
    var list: [String] = []
    var navBar: UINavigationBar!
    var statusFrame: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectionView = UIView()
        UITableViewCell.appearance().selectedBackgroundView = selectionView
        
        self.navigationController?.navigationBar.isHidden = true
        statusFrame = UIView(frame:     CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 20))
        navBar = UINavigationBar(frame: CGRect(x: 0, y: self.tableView.contentOffset.y + 20, width: UIScreen.main.bounds.width, height: 44))
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let backItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: Selector("goBack"))
        let approveItem = UIBarButtonItem(title: "Approve", style: .done, target: nil, action: Selector("approveEvent"))
        navBar.isTranslucent = true
        
        
        self.view.addSubview(navBar)
        self.view.addSubview(statusFrame)
        let navItem = UINavigationItem(title: "")
        navItem.leftBarButtonItem = backItem
        navItem.rightBarButtonItem = approveItem
        
        navBar.setItems([navItem], animated: false)
        
        getInfo()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getInfo(){
        
        let ref = Database.database().reference()
        
        ref.child("Events").child(selectedID).observe(.value, with: { (snapshot) in
            let eventInfo = [
                "EventName": snapshot.childSnapshot(forPath: "EventName").value as! String,
                "VenueName": snapshot.childSnapshot(forPath: "VenueName").value as! String,
                "EventImage": snapshot.childSnapshot(forPath: "EventImage").value as! String,
                "VenueID": snapshot.childSnapshot(forPath: "VenueID").value as! String,
                "Details": snapshot.childSnapshot(forPath: "Details").value as! String,
                "Day": snapshot.childSnapshot(forPath: "Day").value as! String,
                "Month": snapshot.childSnapshot(forPath: "Month").value as! String,
                "Year": snapshot.childSnapshot(forPath: "Year").value as! String,
                "Hour": snapshot.childSnapshot(forPath: "Hour").value as! String,
                "Minutes": snapshot.childSnapshot(forPath: "Minutes").value as! String,
                "isApproved": snapshot.childSnapshot(forPath: "isApproved").value as! String,
                "likeCount": snapshot.childSnapshot(forPath: "likeCount").value as! Int,
                "seenCount": snapshot.childSnapshot(forPath: "seenCount").value as! Int,
                "commentCount": snapshot.childSnapshot(forPath: "commentCount").value as! Int,
                ] as [String:Any]
            self.eventName.text = eventInfo["EventName"] as? String
            self.venueName.text = eventInfo["VenueName"] as? String
            self.descriptionText.text = eventInfo["Details"] as? String
            self.dayLabel.text = eventInfo["Day"] as? String
            self.monthLabel.text = eventInfo["Month"] as? String
            self.yearLabel.text = eventInfo["Year"] as? String
            self.hourLabel.text = eventInfo["Hour"] as? String
            self.minuteLabel.text = eventInfo["Minutes"] as? String
            
            let isApproved = eventInfo["isApproved"] as? String
            self.isApprovedLabel.text = (isApproved == "1") ? "YES" : "NO"
            
            self.likedCountLabel.text = String(describing: eventInfo["likeCount"]!)
            self.seenCountLabel.text = String(describing: eventInfo["seenCount"]!)
            self.commentCountLabel.text = String(describing:eventInfo["commentCount"]!)
            
            let url = URL(string: eventInfo["EventImage"] as! String)
            
            let maxHeight = self.descriptionText.sizeThatFits(CGSize(width: self.descriptionText.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            if (maxHeight.height <= 70){
                self.seeMore.isHidden = true
                self.descriptionTextBottomConstraint.constant = 2
            }
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.eventImage.image = UIImage(data: data!)
                    self.hiddenImageURL.text = eventInfo["EventImage"] as? String
                }
            }
            
        })
        
        
        /* if FBSDKAccessToken.current() != nil {
         let request: FBSDKGraphRequest  = FBSDKGraphRequest(graphPath: selectedID, parameters: ["fields": "attending_count,category,cover,description,interested_count,name,owner,picture,ticket_uri,place,start_time"])
         request.start { (connection, results, error) in
         
         // Something went wrong
         if (error != nil) {
         print(error as Any)
         }
         print(results)
         
         if let eventData = results as? NSDictionary{
         let placeData = eventData["place"] as? NSDictionary
         
         DispatchQueue.global().async {
         DispatchQueue.main.async {
         
         self.eventName.text = eventData["name"] as? String
         self.descriptionText.text = eventData["description"] as? String
         self.ticketLink.text = eventData["ticket_uri"] as? String
         self.venueName.text = placeData?["name"] as? String
         
         }
         }
         
         let pictureData = eventData["cover"] as? NSDictionary
         let pictureURL: String = pictureData?["source"] as! String
         
         let url = URL(string: pictureURL)
         
         DispatchQueue.global().async {
         let data = try? Data(contentsOf: url!)
         DispatchQueue.main.async {
         self.eventImage.image = UIImage(data: data!)
         self.hiddenImageURL.text = pictureURL
         }
         
         
         let placeLocationData = placeData?["location"] as? NSDictionary
         let annotation = MKPointAnnotation()
         let latitude = placeLocationData?["latitude"] as! Double
         let longitude = placeLocationData?["longitude"] as! Double
         annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
         self.mapView.addAnnotation(annotation)
         let region: MKCoordinateRegion = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
         self.mapView.setRegion(region, animated: true)
         
         DispatchQueue.global().async {
         let startTime = eventData["start_time"] as! String
         var dateArray = startTime._split(separator: "T")
         var splitDate = dateArray[0]._split(separator: "-")
         var timeArray = dateArray[1]._split(separator: ":")
         
         DispatchQueue.main.async {
         self.yearLabel.text = splitDate[0]
         self.monthLabel.text = splitDate[1]
         self.dayLabel.text = splitDate[2]
         self.hourLabel.text = timeArray[0]
         self.minuteLabel.text = timeArray[1]
         }
         }
         
         
         }
         
         }
         }
         } */
    }
    
    
    func goBack(){
        self.performSegue(withIdentifier: "goBack", sender: self)
    }
    
    func approveEvent(){
        let ref = Database.database().reference()
        let addedDictionary = [
            "isApproved":"1",
            ]
        ref.child("Events").child(selectedID).updateChildValues(addedDictionary)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navBar.frame = CGRect(x: 0, y: self.tableView.contentOffset.y + 20, width: UIScreen.main.bounds.width, height: 44)
        statusFrame.frame = CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 20)
        if(self.tableView.contentOffset.y >= 140){
            UIView.animate(withDuration: 0.5, animations: {
                self.statusFrame.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                self.navBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                let topView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
                topView.textColor = UIColor.white
                topView.text = self.eventName.text
                self.navBar.topItem?.titleView = topView

            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.statusFrame.backgroundColor = UIColor.clear
                self.navBar.backgroundColor = UIColor.clear
                self.navBar.topItem?.titleView = UIView()
            })
        }
        
    }
    
    func changeStatusBarColor(){
        currentStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        self.setNeedsStatusBarAppearanceUpdate()
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var row6Height: CGFloat = 70
        if (selectedRow == 6){
            let maxHeight = descriptionText.sizeThatFits(CGSize(width: descriptionText.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            row6Height = (maxHeight.height >= 70) ? maxHeight.height + 40 : 70
            descriptionTextBottomConstraint.constant = 0
            seeMore.isHidden = true
        }
        switch indexPath.row {
        case 0:
            return 170
        case 1:
            return 70
        case 2:
            return 50
        case 3:
            return 80
        case 4:
            return 50
        case 5:
            return 155
        case 6:
            return row6Height
        case 7:
            return 40
        case 8:
            return 75
        default:
            return 50
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(selectedRow == indexPath.row){
            selectedRow = -1
        } else {
        selectedRow = indexPath.row
        }
        self.tableView.beginUpdates()
     //   self.tableView.reloadRows(at: [IndexPath(row:6, section:0)], with: .fade)
        self.tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
    }
    

    override func  tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        for x in 1...8 {
            let cell = tableView.cellForRow(at: IndexPath(row: x, section: 0))
                cell?.contentView.backgroundColor = UIColor.clear
                cell?.backgroundColor = UIColor.clear
            cell?.selectedBackgroundView?.backgroundColor = UIColor.white
        }
       
        
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
