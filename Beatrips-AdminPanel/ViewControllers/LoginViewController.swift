//
//  LoginViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 5.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        FBSDKLoginButton.init()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FBSDKAccessToken.current()) != nil {
            // User is logged in, use 'accessToken' here.
            self.performSegue(withIdentifier: "loginSuccess", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(_ sender: FBSDKLoginButton) {
        if (FBSDKAccessToken.current()) != nil {
            // User is logged in, use 'accessToken' here.
            self.performSegue(withIdentifier: "loginSuccess", sender: self)
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
