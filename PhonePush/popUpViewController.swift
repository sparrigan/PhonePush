//
//  popUpViewController.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 11/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit
import QuartzCore

class PopUpViewControllerSwift : UIViewController {
    
    var popUpView: UIView = UIView(frame: CGRectMake(200, 200, 300, 300))
    var messageLabel: UILabel = UILabel(frame: CGRectMake(0,0,100,100))
    var logoImg: UIImageView = UIImageView(frame: CGRectMake(200,200,400,200))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    func showInView(aView: UIView, withImage image : UIImage!, withMessage message: String!, animated: Bool)
    {
      
        println("ee")
       
        logoImg.image = image
        view.addSubview(logoImg)
        //logoImg.image = image
        aView.addSubview(self.view)
        messageLabel.text = message
        //Try to add the message as a subview of the image
        logoImg.addSubview(messageLabel)
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    func closePopup() {
        self.removeAnimate()
    }
}