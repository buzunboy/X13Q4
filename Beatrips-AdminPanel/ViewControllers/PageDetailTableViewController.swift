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
    @IBOutlet weak var venueSmallImage: UIImageView!
    @IBOutlet weak var venueName: UITextView!
    @IBOutlet weak var venueID: UITextField!
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
        
        createRoundImage()
        
        createReloadView()
        
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar(isComeFromViewDidAppear: true)
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
        

        
        ref.child("Pages").child(selectedPageID).observe(.value, with: { (snapshot) in
            let approvedTitleDecider = snapshot.childSnapshot(forPath: "isActive").value as! String
            
            let approvedTitle = (approvedTitleDecider == "0") ? "Activate" : "Update"
            let approveItem = UIBarButtonItem(title: approvedTitle, style: .done, target: self, action: #selector(EventDetailTableViewController.approveEvent(sender:)))
            self.navigationItem.rightBarButtonItem = approveItem
            
        })
    }
    
    func keyBoardWillShow(notification: NSNotification) {
        //handle appearing of keyboard here
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        var items = [UIBarButtonItem]()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: #selector(PageDetailTableViewController.dismissKeyboard))
        items.append(doneButton)
        keyBoardHeight = keyboardRectangle.height
        
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - keyBoardHeight - 44 + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        keyboardDone.items = items
        self.view.addSubview(keyboardDone)
    }
    
    func keyBoardWillHide(notification: NSNotification) {
        //handle dismiss of keyboard here
        keyboardDone.frame = CGRect(x: 0, y: UIScreen.main.bounds.height + tableView.contentOffset.y, width: UIScreen.main.bounds.width, height: 44)
        keyboardDone.removeFromSuperview()
    }

    func changeStatusBarColor(){
        currentStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func createRoundImage(){
        venueSmallImage.contentMode = .scaleToFill
        venueSmallImage.clipsToBounds = true
        venueSmallImage.layer.cornerRadius = venueSmallImage.frame.size.width / 2
        venueSmallImage.layer.borderWidth = 2.0
        venueSmallImage.layer.borderColor = UIColor.orange.cgColor
    }
    
    func createReloadView(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.color = UIColor.gray
        activityIndicator.frame = CGRect(x: venueImage.frame.origin.x, y: venueImage.frame.origin.y, width: venueImage.frame.size.width, height: venueImage.frame.size.height)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        venueImage.image = UIImage()
    }
    
    func getInfo(){
        
        ref.child("Pages").child(selectedPageID).observeSingleEvent(of: .value, with: { (snasphot) in

            self.venueName.text = snasphot.childSnapshot(forPath: "Name").value as? String ?? ""
            self.websiteField.text = snasphot.childSnapshot(forPath: "Website").value as? String ?? ""
           
            self.addressField.text = snasphot.childSnapshot(forPath: "Address").value as? String ?? ""
            self.cityField.text = snasphot.childSnapshot(forPath: "City").value as? String ?? ""
            self.countryField.text = snasphot.childSnapshot(forPath: "Country").value as? String ?? ""
            self.descriptionText.text = snasphot.childSnapshot(forPath: "About").value as? String ?? ""
            
            let latitude = snasphot.childSnapshot(forPath: "Latitude").value as? Double ?? 0
            let longitude = snasphot.childSnapshot(forPath: "Longitude").value as? Double ?? 0
            self.longitudeField.text = String(describing: longitude)
            self.latitudeField.text = String(describing: latitude)

            
            let isApproved = snasphot.childSnapshot(forPath: "isActive").value as? String ?? "0"
            self.isApprovedLabel.text = isApproved == "1" ? "YES" : "NO"
            
            let url = URL(string: snasphot.childSnapshot(forPath: "CoverPhoto").value as? String ?? "")
            let pictureUrl = URL(string: snasphot.childSnapshot(forPath: "Picture").value as? String ?? "")
            self.venueID.text = snasphot.childSnapshot(forPath: "ID").value as? String ?? ""
            
            
            
            let maxHeight = self.descriptionText.sizeThatFits(CGSize(width: self.descriptionText.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            if (maxHeight.height <= 50){
                self.seeMore.isHidden = true
                self.descriptionTextBottomConstraint.constant = 2
            }
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                let dataP = try? Data(contentsOf: pictureUrl!)
                DispatchQueue.main.async {
                    self.venueImage.image = UIImage(data: data!)
                    self.imageS = UIImage(data: data!)!
                    self.venueSmallImage.image = UIImage(data: dataP!)
                    self.activityIndicator.stopAnimating()
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            self.mapView.setRegion(region, animated: true)
        })
    
    }
    
    func approveEvent(sender: UIBarButtonItem){
        
        let venueDictionary = [
            "Name":venueName.text,
            "ID":venueID.text,
            "About":descriptionText.text,
            "Website":websiteField.text,
            //"CoverPhoto":venueImage.,
            //"Picture":picture,
            "City":cityField.text,
            "Country":countryField.text,
            "Latitude":Double(latitudeField.text!),
            "Longitude":Double(longitudeField.text!),
            "Address":addressField.text,
            "isActive":"1"
            ] as [String : Any]
        ref.child("Pages").child(selectedPageID).updateChildValues(venueDictionary)
        
        
    }

    @IBAction func deletePage(_ sender: Any) {
        let deleteDictionary = ["isActive":"0"]
        ref.child("Pages").child(selectedPageID).updateChildValues(deleteDictionary)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 9
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
        if (selectedRow == 5){
            let maxHeight = descriptionText.sizeThatFits(CGSize(width: descriptionText.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
            row6Height = (maxHeight.height >= 50) ? maxHeight.height + 40 : 70
            descriptionTextBottomConstraint.constant = 0
            seeMore.isHidden = true
        }
        switch indexPath.row {
        case 0:
            return 170
        case 1:
            return 80
        case 2:
            return 70
        case 3:
            return 40
        case 4:
            return 155
        case 5:
            return row6Height
        case 6:
            return 235
        case 7:
            return 75
        case 8:
            return 55
        default:
            return 50
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 5){
            selectedRow = 5
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
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
