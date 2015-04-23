//
//  PPIntroVC.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 17/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.

//ViewController that introduces activity before initiating a push

import UIKit

class PPintroVC: UIViewController {

    var titleText:UITextView = UITextView(frame: CGRect(x: 50, y: 50, width: 900.00, height: 200.00));
    let startQstns = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    var currentQstn = 1
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(qstnsArray: [String]) {
        
        self.init()
        
        //Get array of questions to ask from login VC here
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        titleText.text = "Welcome! Instructions to go here"
        titleText.font = UIFont(name: "Arial", size: 80)
        //UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleText.editable = false
        self.view.addSubview(titleText)
        
        //Button to start questions
        startQstns.frame = CGRectMake(300, 450, 500, 250)
        startQstns.backgroundColor = UIColor(red: 151.0/255.0, green: 241.0/255.0, blue: 92.0/255.0, alpha: 1.0)
        startQstns.setTitle("Begin activity", forState: UIControlState.Normal)
        startQstns.layer.cornerRadius = 20
        startQstns.layer.borderWidth = 5
        startQstns.layer.borderColor = UIColor.blackColor().CGColor
        startQstns.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        startQstns.addTarget(self, action: "qstnsStart:", forControlEvents: .TouchUpInside)
        self.view.addSubview(startQstns)
        
    }
    
    func qstnsStart(sender:UIButton) {
        //println("lalal")
        var PPcalib:PPcalibVC = PPcalibVC()
        self.navigationController?.pushViewController(PPcalib, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}