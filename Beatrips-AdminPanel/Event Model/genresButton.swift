//
//  genresButton.swift
//  Beatrips-AdminPanel
//
//  Created by Burak Uzunboy on 16.08.2017.
//  Copyright © 2017 Burak Uzunboy. All rights reserved.
//

import UIKit

class genresButton: UIButton {
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel?.textColor = UIColor.white
        self.tintColor = UIColor.white
        let size = self.sizeThatFits(CGSize(width: (self.titleLabel?.frame.size.width)!, height: CGFloat.greatestFiniteMagnitude))
        self.frame.size.width = size.width + 20
        self.frame.size.height = 20
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.orange
        let cancelView = UIView()
        let cancelLabel = UILabel()
        cancelView.frame = CGRect(x: self.frame.size.width - 10, y: 5.5, width: 10, height: 10)
        cancelLabel.textColor = UIColor.orange
        cancelView.backgroundColor = UIColor.white
        cancelLabel.textAlignment = .center
        cancelView.layer.cornerRadius = 5
        cancelLabel.font = UIFont.systemFont(ofSize: 8)
        cancelLabel.text = "X"
        
        cancelView.addSubview(cancelLabel)
        self.addSubview(cancelView)
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
