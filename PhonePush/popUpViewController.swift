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
    var messageLabel: UILabel = UILabel(frame: CGRectMake(5,5,400,300))
    var logoImg: UIImageView = UIImageView(frame: CGRectMake(0,0,0,0))
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    func showInView(aView: UIView, withImage image : UIImage!, withMessage message: String!, animated: Bool, correct: Bool)
    {
      
        println("ee")
       
        if correct == true {
            self.view.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.6)
        } else if correct == false {
            self.view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.6)
        }
        
        var imgWidth = image.size.width
        var imgHeight = image.size.height
        logoImg.layer.cornerRadius = 10.0
        logoImg.layer.borderColor = UIColor.blackColor().CGColor
        logoImg.layer.borderWidth = 5.0
        logoImg.layer.masksToBounds = true
        logoImg.frame = CGRectMake(view.bounds.width/2-imgWidth/2,view.bounds.height/2-imgHeight/2, imgWidth ,imgHeight)
        logoImg.image = image
        view.addSubview(logoImg)
        //logoImg.image = image
        aView.addSubview(self.view)
        messageLabel.font = UIFont(name: "Arial", size: 40)
        messageLabel.text = message
        messageLabel.adjustsFontSizeToFitWidth = true
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