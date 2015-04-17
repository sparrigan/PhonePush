//
//  ViewControllerLogin.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 15/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import Foundation
import UIKit
//import SwiftyJSON

class ViewControllerLogin: UIViewController {
    
    let PPButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    //Get size of screen
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    //URL for getting list of teachers from
    var teachersURL = "http://tinyteacher.ngrok.com/teachers"
    //URL for sending back teachers to (formatted for URI template library)
    var sendURL = "http://tinyteacher.ngrok.com/teachers/{teacher}"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Holder logo image whilst student tries to get and select teacher data in order to push activity
        let imageName = "mortarboard.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        var imageScaleFactor = screenSize.width/imageView.bounds.width
        imageView.frame = CGRect(x: (screenSize.width-imageView.bounds.width*imageScaleFactor)/2, y: (screenSize.height-imageView.bounds.height*imageScaleFactor)/2, width: imageView.bounds.width*imageScaleFactor, height: imageView.bounds.height*imageScaleFactor)
        view.addSubview(imageView)
        
        
        //Call funtion that prompts user to select teacher (note recursively calls itself on
        //retrys)
        
        teacherSelection()
        
        
        //Button to start an activity for debugging
        /*
        PPButton.frame = CGRectMake((screenSize.width-500)/2, 450, 500, 250)
        PPButton.backgroundColor = UIColor(red: 151.0/255.0, green: 241.0/255.0, blue: 92.0/255.0, alpha: 1.0)
        PPButton.setTitle("Start", forState: UIControlState.Normal)
        PPButton.layer.cornerRadius = 20
        PPButton.layer.borderWidth = 5
        PPButton.layer.borderColor = UIColor.blackColor().CGColor
        PPButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        PPButton.addTarget(self, action: "PPStart:", forControlEvents: .TouchUpInside)
        self.view.addSubview(PPButton)
        */
    }
    
    
    func teacherSelection() {
        //Get list of teachers from server, passing completionhandler that runs on main queue
        DataManager.getFromServer(teachersURL, success: { (data, error) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                //What to do (on main queue) if get data...
                //First check whether we have an error:
                if let err = error {
                    //If we have an error (error optional is not nil) Then present
                    //alert with options for more info or to retry
                    let alertController = UIAlertController(title: "There was an error", message: "Try again or see more info", preferredStyle: .Alert)
                    let infobutton = UIAlertAction(title: "Info", style: .Default)
                        {(action) in
                            //UIAlertController that gives more detailed error info
                            let infoalertController = UIAlertController(title: "Error info", message: "\(err.localizedDescription)", preferredStyle: .Alert)
                            let retrybutton = UIAlertAction(title: "Retry", style: .Default)
                                {(action) in
                                    //To retry fetching teachers recursively call this function again
                                    self.teacherSelection()
                            }
                            infoalertController.addAction(retrybutton)
                            self.presentViewController(infoalertController, animated: true) {
                            }
                    }
                    alertController.addAction(infobutton)
                    let retrybutton = UIAlertAction(title: "Retry", style: .Default)
                        {(action) in
                            //To retry fetching teachers recursively call this function again
                            self.teacherSelection()
                    }
                    alertController.addAction(retrybutton)
                    self.presentViewController(alertController, animated: true) {
                    }
                    //If there is no error then unwrap JSON and display teachers
                    //NOTE: SHOULD REALLY CATCH IF DATA NO GOOD AND IF TEACHERLIST NO GOOD
                } else {
                    //Extract data from Json into object using swiftyJSON
                    var tempList = JSON(data: data)
                    //Unwrap JSON to get at array of teacher names - NEED TO CATCH THIS
                    if let teacherList = tempList["teachers"].array {
                        //Initialise Alertcontroller for presenting teacher options to user
                        let alertController = UIAlertController(title: "Choose your teacher", message: "Click retry to reload list", preferredStyle: .Alert)
                        //Loop through teachers names and add them as options in the alert
                        for ii in teacherList {
                            let tempbutton = UIAlertAction(title: "\(ii)", style: .Default)
                                {(action) in
                                    //Completion handler for what to do if teacher is clicked
                                    //Run returnTeacher function that sends back choice to server
                                    self.returnTeacher(String(stringInterpolationSegment: ii))
                            }
                            alertController.addAction(tempbutton)
                        }
                        //Add a retry button after all teacher options
                        var retrybutton = UIAlertAction(title: "Retry", style: .Cancel) { (_) in
                        //To retry fetching teachers recursively call this function again
                        self.teacherSelection()
                        }
                        alertController.addAction(retrybutton)
                        //Display alertcontroller - NOTE POTENTIAL ISSUE WITH ACTUALLY
                        //NEEDING TO PUT THIS IN VIEWDIDAPPEAR AS OPPOSED TO VIEWDIDLOAD
                        self.presentViewController(alertController, animated: true) {
                        }
                    }
                    
                }
            }
        })
    }
    
    
    func returnTeacher(teacherName: String) {
        //Template URL to visit in order to notify server of teacher choice 
        //(and then retrieve appropriate setting file
        var replyString = ExpandURITemplate(sendURL,
            values: ["teacher": teacherName])
        //Get from server at URL that corresponds to students teacher choice
        DataManager.getFromServer(replyString, success: { (data) -> Void in
            //We get back a JSON from this call that contains the activity and 
            //activity settings for that teacher. Act accordingly by opening VC 
            //for appropriate activity
            
            
            
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }
    
    /*
    func PPStart(sender:UIButton) {
        var PhonePushVC:ViewController = ViewController()
        
        self.navigationController?.pushViewController(PhonePushVC, animated: true)
    }
    */
    
}