//
//  AddPageViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 14.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseDatabase

class AddPageViewController: UIViewController {

    @IBOutlet weak var pageField: UITextField!
    var ref = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPage(_ sender: Any) {
        
         if FBSDKAccessToken.current() != nil {
         let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: pageField.text, parameters: ["fields":"name,id"])
         request.start(completionHandler: { (connection, results, error) in
         if(error != nil){
         print(error as Any)
         }
         
         var pageName = ""
         var pageID = ""
         
         if let pageData = results as? NSDictionary{
         pageName = pageData["name"] as? String ?? ""
         pageID = pageData["id"] as? String ?? ""
         }
         let addPage = ["Name":pageName]
         self.ref.child("Pages").child(pageID).updateChildValues(addPage)
         connection?.cancel()
         })
         }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
