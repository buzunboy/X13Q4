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
    @IBOutlet weak var ticketLink: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventNameField: UITextView!
    @IBOutlet weak var venueNameField: UITextView!
    
    @IBOutlet weak var dayLabel: UITextField!
    @IBOutlet weak var monthLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    @IBOutlet weak var hourLabel: UITextField!
    @IBOutlet weak var minuteLabel: UITextField!
    
    @IBOutlet weak var isApprovedLabel: UILabel!
    @IBOutlet weak var seenCountLabel: UITextField!
    @IBOutlet weak var likedCountLabel: UITextField!
    @IBOutlet weak var commentCountLabel: UITextField!
    
    @IBOutlet weak var hiddenImageURL: UILabel!
    @IBOutlet weak var seeMore: UIButton!
    
    var selectedRow = -1
    var lastY: CGFloat = 0.0
    var ref = Database.database().reference()
    var imageFrame = UIImageView()
    var imageS = UIImage()
    var keyboardDone = UIToolbar()
    var keyBoardHeight: CGFloat = 0
    var visualEffectView = UIVisualEffectView()
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var descriptionTextBottomConstraint: NSLayoutConstraint!
    
    var currentStyle = UIStatusBarStyle.lightContent
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStyle
    }
    
    var list: [String] = []
    var navBar: UINavigationBar!
    var statusFrame: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        setNavigationBar(isComeFromViewDidAppear: false)
        getInfo()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.color = UIColor.gray
        activityIndicator.frame = CGRect(x: eventImage.frame.origin.x, y: eventImage.frame.origin.y, width: eventImage.frame.size.width, height: eventImage.frame.size.height)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        eventImage.image = UIImage()
        view.addSubview(activityIndicator)
        

        //view.addGestureRecognizer(tap)
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNavigationBar(isComeFromViewDidAppear: true)
        
    }
    
    
    func keyBoardWillShow(notification: NSNotification) {
        //handle appearing of keyboard here
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        var items = [UIBarButtonItem]()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(EventDetailTableViewController.dismissKeyboard))
        items.append(doneButton)
        keyBoardHeight = keyboardRectangle.height
        
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - keyBoardHeight - 44 + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        keyboardDone.items = items
        // keyboardDone.backgroundColor = UIColor.red
        self.view.addSubview(keyboardDone)
    }
    
    func keyBoardWillHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        keyboardDone.removeFromSuperview()
    }
    
    
    func setNavigationBar(isComeFromViewDidAppear: Bool){
        if(isComeFromViewDidAppear){
            navBar.removeFromSuperview()
        }
        
        self.extendedLayoutIncludesOpaqueBars = true
        extendedLayoutIncludesOpaqueBars = true
        tableView.bounces = true
        
        let selectionView = UIView()
        UITableViewCell.appearance().selectedBackgroundView = selectionView
        //self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        
        statusFrame = UIView(frame:     CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 20))
        navBar = UINavigationBar(frame: CGRect(x: 0, y: self.tableView.contentOffset.y + 20, width: UIScreen.main.bounds.width, height: 44))
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        ref.child("Events").child(selectedID).observe(.value, with: { (snapshot) in
            let approvedTitleDecider = snapshot.childSnapshot(forPath: "isApproved").value as! String
            
            let approvedTitle = (approvedTitleDecider == "0") ? "Approve" : "Update"
            let approveItem = UIBarButtonItem(title: approvedTitle, style: .done, target: self, action: #selector(EventDetailTableViewController.approveEvent(sender:)))
            self.navBar.isTranslucent = true
            self.navigationItem.rightBarButtonItem = approveItem

        })
    }
    

    func getInfo(){
        
        
        ref.child("Events").child(selectedID).observe(.value, with: { (snapshot) in
            let eventInfo = [
                "EventName":    snapshot.childSnapshot(forPath: "EventName").value as! String,
                "VenueName":    snapshot.childSnapshot(forPath: "VenueName").value as! String,
                "EventImage":   snapshot.childSnapshot(forPath: "EventImage").value as! String,
                "VenueID":      snapshot.childSnapshot(forPath: "VenueID").value as! String,
                "Details":      snapshot.childSnapshot(forPath: "Details").value as! String,
                "TicketLink":   snapshot.childSnapshot(forPath: "TicketLink").value as? String ?? "",
                "Day":          snapshot.childSnapshot(forPath: "Day").value as! String,
                "Month":        snapshot.childSnapshot(forPath: "Month").value as! String,
                "Year":         snapshot.childSnapshot(forPath: "Year").value as! String,
                "Hour":         snapshot.childSnapshot(forPath: "Hour").value as! String,
                "Minutes":      snapshot.childSnapshot(forPath: "Minutes").value as! String,
                "isApproved":   snapshot.childSnapshot(forPath: "isApproved").value as! String,
                "likeCount":    snapshot.childSnapshot(forPath: "likeCount").value as! String,
                "seenCount":    snapshot.childSnapshot(forPath: "seenCount").value as! String,
                "commentCount": snapshot.childSnapshot(forPath: "commentCount").value as! String,
                
                ] as [String:Any]
            let locationDictionary = [
                "Latitude":     snapshot.childSnapshot(forPath: "Latitude").value as? Double ?? 0,
                "Longitude":    snapshot.childSnapshot(forPath: "Longitude").value as? Double ?? 0
                ]
            self.eventNameField.text = eventInfo["EventName"] as? String
            self.venueNameField.text = eventInfo["VenueName"] as? String
            self.descriptionText.text = eventInfo["Details"] as? String
            self.dayLabel.text = eventInfo["Day"] as? String
            self.monthLabel.text = eventInfo["Month"] as? String
            self.yearLabel.text = eventInfo["Year"] as? String
            self.hourLabel.text = eventInfo["Hour"] as? String
            self.minuteLabel.text = eventInfo["Minutes"] as? String
            self.ticketLink.text = eventInfo["TicketLink"] as? String
            
            let isApproved = eventInfo["isApproved"] as? String
            self.isApprovedLabel.text = (isApproved == "1") ? "YES" : "NO"
            
            let annotation = MKPointAnnotation()
            let latitude = Double(locationDictionary["Latitude"]!)
            let longitude = Double(locationDictionary["Longitude"]!)
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapView.setRegion(region, animated: true)
            
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
                    self.imageS = UIImage(data: data!)!
                    self.activityIndicator.stopAnimating()
                }
            }
            self.hiddenImageURL.text = eventInfo["EventImage"] as? String
        })
    }
 
    
    func approveEvent(sender: UIBarButtonItem){
        
        let addedDictionary = [
            "EventName":self.eventNameField.text,
            "VenueName":self.venueNameField.text,
            "Details": self.descriptionText.text,
            "TicketLink": self.ticketLink.text ?? "",
            "Day": self.dayLabel.text!,
            "Month":self.monthLabel.text!,
            "Year":self.yearLabel.text!,
            "Hour":self.hourLabel.text!,
            "Minutes":self.minuteLabel.text!,
            "EventImage":self.hiddenImageURL.text!,
            "commentCount":self.commentCountLabel.text!,
            "likeCount":self.likedCountLabel.text!,
            "seenCount":self.seenCountLabel.text!,
            "isApproved":"1"
            ] as [String : Any]
        ref.child("Events").child(selectedID).updateChildValues(addedDictionary)
        
        self.navBar.topItem?.rightBarButtonItem?.title = "Approved"
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(self.tableView.contentOffset.y <= 0){
            
            self.imageFrame.removeFromSuperview()
            self.imageFrame = UIImageView(frame: (CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 170 - self.tableView.contentOffset.y)))
            self.imageFrame.image = self.imageS
            self.imageFrame.contentMode = .scaleAspectFill
            self.imageFrame.clipsToBounds = true
            self.view.insertSubview(self.imageFrame, at: 2)
            
        }
        
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - keyBoardHeight - 44 + self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        
        
        if(self.tableView.contentOffset.y >= 130){
            UIView.animate(withDuration: 2, animations: {
                let topView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
                topView.textColor = UIColor.white
                topView.text = self.eventNameField.text
                self.navigationController?.navigationBar.topItem?.titleView = topView
                self.navigationController?.navigationBar.isTranslucent = false
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "background"), for: .default)
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.navigationController?.navigationBar.topItem?.titleView = UIView()
                self.navigationController?.navigationBar.backgroundColor = UIColor.clear
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                self.navigationController?.navigationBar.isTranslucent = true
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
        if(indexPath.row == 6){
            selectedRow = 6
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
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
    
    @IBAction func deleteEvent(_ sender: Any) {
        let deleteDictionary = ["isApproved":"0"]
        ref.child("Events").child(selectedID).updateChildValues(deleteDictionary)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
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
