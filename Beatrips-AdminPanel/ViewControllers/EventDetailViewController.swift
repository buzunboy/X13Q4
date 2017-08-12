//
//  EventDetailViewController.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 7.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit
import MapKit

class EventDetailViewController: UIViewController {
    @IBOutlet var viewS: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewS.frame = CGRect(x: 0, y: -90, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.frame.size.width = UIScreen.main.bounds.width
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
