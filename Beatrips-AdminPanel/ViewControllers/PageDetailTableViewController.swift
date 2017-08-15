//
//  PageDetailTableViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 15.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit

class PageDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var venueImage: UIImageView!
    @IBOutlet weak var venueName: UITextView!
    @IBOutlet weak var isApprovedLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var seeMore: UIButton!
    @IBOutlet weak var descriptionTextBottomConstraint: NSLayoutConstraint!

    var selectedRow = -1
    var ref = Database.database().reference()
    var currentStyle = UIStatusBarStyle.lightContent
    var imageFrame = UIImageView()
    var imageS = UIImage()
    var keyBoardHeight: CGFloat = 0
    var keyboardDone = UIToolbar()
    var visualEffectView = UIVisualEffectView()
    var activityIndicator = UIActivityIndicatorView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

         setNavigationBar(isComeFromViewDidAppear: false)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        getInfo()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationBar(isComeFromViewDidAppear: Bool){
        self.extendedLayoutIncludesOpaqueBars = true
        extendedLayoutIncludesOpaqueBars = true
        tableView.bounces = true
        
        let selectionView = UIView()
        UITableViewCell.appearance().selectedBackgroundView = selectionView
        //self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        

        /*
        ref.child("Events").child(selectedID).observe(.value, with: { (snapshot) in
            let approvedTitleDecider = snapshot.childSnapshot(forPath: "isApproved").value as! String
            
            let approvedTitle = (approvedTitleDecider == "0") ? "Approve" : "Update"
            let approveItem = UIBarButtonItem(title: approvedTitle, style: .done, target: self, action: #selector(EventDetailTableViewController.approveEvent(sender:)))
            self.navigationItem.rightBarButtonItem = approveItem
            
        }) */
    }

    func changeStatusBarColor(){
        currentStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func getInfo(){
        
        ref.child("Pages").child(selectedPageID).observe(.value, with: { (snasphot) in
            let pageInfo = [
                "Name": snasphot.childSnapshot(forPath: "Name").value as? String ?? "",
                "ID": snasphot.childSnapshot(forPath: "ID").value as? String ?? "",
                "About": snasphot.childSnapshot(forPath: "About").value as? String ?? "",
                "Address": snasphot.childSnapshot(forPath: "Address").value as? String ?? "",
                "CoverPhoto": snasphot.childSnapshot(forPath: "CoverPhoto").value as? String ?? "",
                "Picture": snasphot.childSnapshot(forPath: "Picture").value as? String ?? "",
                "Website": snasphot.childSnapshot(forPath: "Website").value as? String ?? "",
                "City": snasphot.childSnapshot(forPath: "City").value as? String ?? "",
                "Country": snasphot.childSnapshot(forPath: "Country").value as? String ?? "",
                "Latitude": snasphot.childSnapshot(forPath: "Latitude").value as? Double ?? 0,
                "Longitude": snasphot.childSnapshot(forPath: "Name").value as? Double ?? 0,
                "isActive": snasphot.childSnapshot(forPath: "Name").value as? String ?? "0"
            ]
            self.venueName.text = pageInfo["Name"] as? String
            self.websiteField.text = pageInfo["Website"] as? String
            self.latitudeField.text = pageInfo["Latitude"] as? String
            self.longitudeField.text = pageInfo["Longitude"] as? String
            self.addressField.text = pageInfo["Address"] as? String
            self.cityField.text = pageInfo["City"] as? String
            self.countryField.text = pageInfo["Country"] as? String
            self.descriptionText.text = pageInfo["About"] as? String
            
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
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
                topView.text = self.venueName.text
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var row6Height: CGFloat = 70
        if (selectedRow == 4){
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
            return 40
        case 3:
            return 155
        case 4:
            return row6Height
        case 5:
            return 235
        case 6:
            return 75
        default:
            return 50
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 4){
            selectedRow = 4
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
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
