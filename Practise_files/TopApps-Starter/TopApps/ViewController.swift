//
//  ViewController.swift
//  TopApps
//
//  Created by Dani Arnaout on 9/1/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import UIKit

import SwiftyJSON

class ViewController: UIViewController {
 
    
    var questionText = UITextView(frame: CGRect(x: 50, y: 25, width: 600, height: 200.00));
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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

    
}
