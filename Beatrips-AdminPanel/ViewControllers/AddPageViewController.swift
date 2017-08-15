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
    @IBOutlet weak var pageID: UITextField!
    
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
         var pageIDString = ""
         
         if let pageData = results as? NSDictionary{
         pageName = pageData["name"] as? String ?? ""
         pageIDString = pageData["id"] as? String ?? ""
         self.pageID.text = pageIDString
         }
         let addPage = ["Name":pageName]
        // self.ref.child("Pages").child(pageIDString).updateChildValues(addPage)
         connection?.cancel()
         })
         }
        if pageID.text != "" {
        if FBSDKAccessToken.current() != nil {
            let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: pageID.text, parameters: ["fields":"name,id,location,cover,website,picture,about"])
            request.start(completionHandler: { (connection, results, error) in
                if(error != nil){
                    print(error as Any)
                }
                
                if let resultArray = results as? NSDictionary {
                    let locationDictionary = resultArray["location"] as? NSDictionary
                    let coverDictionary = resultArray["cover"] as? NSDictionary
                    let pictureDictionary = resultArray["picture"] as? NSDictionary
                    let pictureData = pictureDictionary?["data"] as? NSDictionary
                    
                    let name = resultArray["name"] as? String ?? ""
                    let ID = resultArray["id"] as? String ?? ""
                    let about = resultArray["about"] as? String ?? ""
                    let website = resultArray["website"] as? String ?? ""
                    let coverPhoto = coverDictionary?["source"] as? String ?? ""
                    let picture = pictureData?["url"] as? String ?? ""
                    let city = locationDictionary?["city"] as? String ?? ""
                    let country = locationDictionary?["country"] as? String ?? ""
                    let latitude = locationDictionary?["latitude"] as? Double ?? 0
                    let longitude = locationDictionary?["longitude"] as? Double ?? 0
                    let address = locationDictionary?["street"] as? String ?? ""
                    
                    let venueDictionary = [
                    "Name":name,
                    "ID":ID,
                    "About":about,
                    "Website":website,
                    "CoverPhoto":coverPhoto,
                    "Picture":picture,
                    "City":city,
                    "Country":country,
                    "Latitude":latitude,
                    "Longitude":longitude,
                    "Address":address
                    ] as [String : Any]
                    
                    self.ref.child("Pages").child(self.pageID.text!).updateChildValues(venueDictionary)
                }
         
            })
        }
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
