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



class EventDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var ticketLink: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    
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
        
        self.navigationController?.navigationBar.isHidden = true
        statusFrame = UIView(frame:     CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 20))
        navBar = UINavigationBar(frame: CGRect(x: 0, y: self.tableView.contentOffset.y + 20, width: UIScreen.main.bounds.width, height: 44))
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: Selector("goBack"))
        navBar.isTranslucent = true
        
        
        self.view.addSubview(navBar)
        self.view.addSubview(statusFrame)
        let navItem = UINavigationItem(title: "SomeTitle")
        navItem.leftBarButtonItem = doneItem
        
        navBar.setItems([navItem], animated: false)
        
        getInfo()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func getInfo(){
        
        if FBSDKAccessToken.current() != nil {
            let request: FBSDKGraphRequest  = FBSDKGraphRequest(graphPath: selectedID, parameters: ["fields": "attending_count,category,cover,description,interested_count,name,owner,picture,ticket_uri"])
            request.start { (connection, results, error) in
                
                // Something went wrong
                if (error != nil) {
                    print(error as Any)
                }
                print(results)
                
                if let eventData = results as? NSDictionary{
                    self.eventName.text = eventData["name"] as? String
                    self.descriptionText.text = eventData["description"] as? String
                    self.ticketLink.text = eventData["ticket_uri"] as? String
                    
                    let pictureData = eventData["cover"] as? NSDictionary
                    let pictureURL: String = pictureData?["source"] as! String
                    
                    let url = URL(string: pictureURL)
                    
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!)
                        DispatchQueue.main.async {
                            self.eventImage.image = UIImage(data: data!)
                        }
                    }
                    
                }
                
                /*  if let eventData = results as? NSDictionary{
                 
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
                 let venuesData = eventDictionary?["place"] as? NSDictionary
                 let venueName = venuesData?["name"] as? String
                 let convertedDate = String(date) + " " + convertMonth(month: month) + " " + String(hour) + ":" + String(minutes)
                 dateList.append(venueName! + " @ " + convertedDate)
                 }
                 } */
            }
        }
    }
    
    
    func goBack(){
        self.performSegue(withIdentifier: "goBack", sender: self)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        navBar.frame = CGRect(x: 0, y: self.tableView.contentOffset.y + 20, width: UIScreen.main.bounds.width, height: 44)
        statusFrame.frame = CGRect(x: 0, y: self.tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 20)
        print(self.tableView.contentOffset.y)
        if(self.tableView.contentOffset.y >= 170){
            UIView.animate(withDuration: 0.5, animations: {
                self.statusFrame.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                self.navBar.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                self.changeStatusBarColor()
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.statusFrame.backgroundColor = UIColor.clear
                self.navBar.backgroundColor = UIColor.clear
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
            return 50
        default:
            return 50
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
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
