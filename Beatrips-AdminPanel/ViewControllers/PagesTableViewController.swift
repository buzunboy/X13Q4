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

class PagesTableViewController: UITableViewController, UIViewControllerPreviewingDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    var ref = Database.database().reference()
    var Pages = [PagesModel]()
    var refreshControls = UIRefreshControl()
    var visualEffectView = UIVisualEffectView()
    var filteredData = [PagesModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControls.attributedTitle = NSAttributedString(string: "Let's see what is new?")
        refreshControls.addTarget(self, action: #selector(PagesTableViewController.getPages), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControls)
        refreshControls.beginRefreshing()
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.placeholder = "Search Page or Venue"
        
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView: view)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
        Pages.removeAll()
        self.tableView.reloadData()
        getPages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setNavigationBar(isDisappear: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        setNavigationBar(isDisappear: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "PageDetailTableViewController") as? PageDetailTableViewController else { return nil }
        
        selectedPageID = Pages[indexPath.row].ID
        
        return detailVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func setNavigationBar(isDisappear: Bool) {
        
        if(isDisappear){
            visualEffectView.removeFromSuperview()
        }else {
            let bounds = self.navigationController?.navigationBar.bounds as CGRect!
            visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            visualEffectView.frame = CGRect(x: (bounds?.origin.x)!, y: (bounds?.origin.y)! - 20, width: (bounds?.size.width)!, height: 64)
            visualEffectView.alpha = 0.8
            
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let topView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
            topView.textColor = UIColor.white
            topView.text = "Pages & Venues"
            
            self.navigationController?.navigationBar.topItem?.titleView = topView
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "background"), for: .default)
            let addPage = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(PagesTableViewController.addPageSegue))
            self.navigationItem.rightBarButtonItem = addPage
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            self.navigationController?.navigationBar.insertSubview(visualEffectView, at: 0)
        }
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
    }

    
    func getPages(){
        let pageCount = self.Pages.count
        if (pageCount >= 1){
            self.Pages.removeAll()
            self.tableView.reloadData()
        }
        DispatchQueue.global().async {

        self.ref.child("Pages").observe( .childAdded, with: { (snapshot) in
            if let pageID = snapshot.key as? String {
                self.ref.child("Pages").child(pageID).observeSingleEvent(of: .value, with: { (snap) in
                    let pageName = snap.childSnapshot(forPath: "Name").value as? String ?? ""
                    if(pageName != ""){
                        
                        let isActive = snap.childSnapshot(forPath: "isActive").value as? String ?? "0"
                        if(isActive != "0"){
                            self.Pages.append(PagesModel(name: pageName, ID: pageID))
                        }
                        
                    }
                    self.tableView.reloadData()
                })
            }
        })
        self.refreshControls.endRefreshing()
        }
    }
    
    
    func addPageSegue(){
        self.performSegue(withIdentifier: "addPageSegue", sender: self)
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
            return Pages.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   

        let cell = tableView.dequeueReusableCell(withIdentifier: "pagesCell", for: indexPath)
             DispatchQueue.main.async {
        if(self.isSearching){
            cell.textLabel?.text = self.filteredData[indexPath.row].name
            cell.detailTextLabel?.text = self.filteredData[indexPath.row].ID
        } else {
            cell.textLabel?.text = self.Pages[indexPath.row].name
            cell.detailTextLabel?.text = self.Pages[indexPath.row].ID
        }
        
    
        }
        // Configure the cell...
        return cell

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil {
            isSearching = false
            filteredData = Pages
            view.endEditing(true)
            tableView.reloadData()
        } else if searchBar.text == "" {
            isSearching = false
            filteredData = Pages
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredData = Pages.filter({ (mod) -> Bool in
                return mod.name.lowercased().contains(searchBar.text!.lowercased()) || mod.ID.lowercased().contains(searchBar.text!.lowercased())
            })
            tableView.reloadData()
        }
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
        if(isSearching){
            selectedPageID = filteredData[indexPath.row].ID
        } else {
            selectedPageID = Pages[indexPath.row].ID
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
