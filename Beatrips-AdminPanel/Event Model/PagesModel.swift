//
//  PagesModel.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 14.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit

class PagesModel: NSObject {
    
    var name: String = ""
    var ID: String = ""
    
    init(name: String, ID: String){
        self.name = name.capitalized
        self.ID = ID
    }

}
