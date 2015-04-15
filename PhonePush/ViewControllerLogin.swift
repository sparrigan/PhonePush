//
//  ViewControllerLogin.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 15/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit
import swiftyJSON

class ViewControllerLogin: UIViewController {
    
    var questionText = UITextView(frame: CGRect(x: 50, y: 25, width: 600, height: 200.00));
    let PPButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        PPButton.frame = CGRectMake(300, 450, 500, 250)
        PPButton.backgroundColor = UIColor(red: 151.0/255.0, green: 241.0/255.0, blue: 92.0/255.0, alpha: 1.0)
        PPButton.setTitle("Start", forState: UIControlState.Normal)
        PPButton.layer.cornerRadius = 20
        PPButton.layer.borderWidth = 5
        PPButton.layer.borderColor = UIColor.blackColor().CGColor
        PPButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        PPButton.addTarget(self, action: "PPStart:", forControlEvents: .TouchUpInside)
        self.view.addSubview(PPButton)

        //Testing get and post
        
        questionText.font = UIFont(name: "Arial", size: 60)
        questionText.backgroundColor = UIColor.clearColor()
        questionText.editable = false
        
        var teachersURL = "http://tinyteacher.ngrok.com/teachers"
        
        DataManager.getFromServer(teachersURL, success: { (data) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.lalala(data)
            }
        })
        
        
        var URLStr = "http://626c02b0.ngrok.com/login"
        
        DataManager.postToServer(["username":"jameson", "password":"password"], url: URLStr) { (succeeded: Bool, msg: String) -> () in
            var alert = UIAlertView(title: "Success!", message: msg, delegate: nil, cancelButtonTitle: "Okay.")
            if(succeeded) {
                alert.title = "Success!"
                alert.message = msg
            }
            else {
                alert.title = "Failed : ("
                alert.message = msg
            }
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                alert.show()
            })
        }
        
    

        
    }
    
    
    func lalala(dat: NSData) {
        let json = JSON(data: dat)
        if let teacherNames = json["teachers"].array {
            self.questionText.text = teacherNames[0].string
        }
        self.view.addSubview(self.questionText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    func PPStart(sender:UIButton) {
        var PhonePushVC:ViewController = ViewController()
        
        self.navigationController?.pushViewController(PhonePushVC, animated: true)
    }
    
}