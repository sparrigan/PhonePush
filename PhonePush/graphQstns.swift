//
//  graphQstns.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 11/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

//import CorePlot

class graphQstns: UIViewController, UITextFieldDelegate {
    
    var timeArray:[Double] = []
    var accelArray:[Double] = []
    var velArray:[Double] = []
    var posArray:[Double] = []
    var qstntype: Int = 0
    var questionText = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var ansTxt1 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var ansTxt2 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var ansTxt3 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    //VC for popups for right or wrong answers
    var popViewController : PopUpViewControllerSwift!
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(pushData: [String: Any]) {
        self.init()
        
        //Extract needed push data (passed from nextQstn)
        self.timeArray = pushData["tRaw"] as! [Double]
        self.accelArray = pushData["aRaw"] as! [Double]
        self.velArray = pushData["vRaw"] as! [Double]
        self.posArray = pushData["pRaw"] as! [Double]
        
        //Set whether to ask for accel or initial velocity
        self.qstntype = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        //Add observers for moving screen when keyboard appears and dissapears
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        //Get plots for a-t, v-t and x-t graphs
        var gD:graphPlotter = graphPlotter(vSize: CGRectMake(10,210,300,300), xArray: timeArray, yArray: accelArray)
        gD.loadgraph()
        
        var gD2:graphPlotter = graphPlotter(vSize: CGRectMake(350,210,300,300), xArray: timeArray, yArray: velArray)
        gD2.loadgraph()
        
        var gD3:graphPlotter = graphPlotter(vSize: CGRectMake(700,210,300,300), xArray: timeArray, yArray: posArray)
        gD3.loadgraph()
        //Add graphs to view with positions and sizes they were created with
        self.view.addSubview(gD)
        self.view.addSubview(gD2)
        self.view.addSubview(gD3)
        
        //Ask question based on data according to mock setting
        questionText = UITextView(frame: CGRect(x: 50, y: 25, width: screenSize.width-100, height: 200.00));
        questionText.font = UIFont(name: "Arial", size: 60)
        questionText.backgroundColor = UIColor.clearColor()
        questionText.editable = false
        
        questionText.text = "What variable is plotted on the y-axis in each graph?"
        self.view.addSubview(questionText)
        
        
        //Add textboxes for answers
        ansTxt1 = UITextField(frame: CGRect(x: 10, y: 520, width: 300.00, height: 100.00));
        ansTxt1.placeholder = "y-axis ?"
        ansTxt1.layer.cornerRadius = 4.0
        ansTxt1.layer.masksToBounds = true
        ansTxt1.layer.borderColor = UIColor.blueColor().CGColor
        ansTxt1.font = UIFont(name: "Arial", size: 50)
        ansTxt1.textAlignment = NSTextAlignment.Center
        ansTxt1.layer.borderWidth = 2.0
        ansTxt1.delegate = self;
        ansTxt1.keyboardType = UIKeyboardType.Default
        self.view.addSubview(ansTxt1)
     
        ansTxt2 = UITextField(frame: CGRect(x: 350, y: 520, width: 300.00, height: 100.00));
        ansTxt2.placeholder = "y-axis ?"
        ansTxt2.layer.cornerRadius = 4.0
        ansTxt2.layer.masksToBounds = true
        ansTxt2.layer.borderColor = UIColor.blueColor().CGColor
        ansTxt2.font = UIFont(name: "Arial", size: 50)
        ansTxt2.textAlignment = NSTextAlignment.Center
        ansTxt2.layer.borderWidth = 2.0
        ansTxt2.delegate = self;
        ansTxt2.keyboardType = UIKeyboardType.Default
        self.view.addSubview(ansTxt2)

        ansTxt3 = UITextField(frame: CGRect(x: 700, y: 520, width: 300.00, height: 100.00));
        ansTxt3.placeholder = "y-axis ?"
        ansTxt3.layer.cornerRadius = 4.0
        ansTxt3.layer.masksToBounds = true
        ansTxt3.layer.borderColor = UIColor.blueColor().CGColor
        ansTxt3.font = UIFont(name: "Arial", size: 50)
        ansTxt3.textAlignment = NSTextAlignment.Center
        ansTxt3.layer.borderWidth = 2.0
        ansTxt3.delegate = self;
        ansTxt3.keyboardType = UIKeyboardType.Default
        self.view.addSubview(ansTxt3)
        
        //Answer submit button
        submitButton.frame = CGRectMake(screenSize.width-275, screenSize.height-140, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
        
    }
    
    //Answer button action
    func submitAnswer(sender: UIButton) {
        //If have some empty values, then don't bother checking yet, ask user to input
        //all values
        if (ansTxt1.text == "" || ansTxt2.text == "" || ansTxt3.text == "") {
            let alertController = UIAlertController(title: "Hang about!", message: "You still have some questions to answer. \n Fill in all answers before submitting", preferredStyle: .Alert)
            var okbutton = UIAlertAction(title: "OK", style: .Cancel) { (_) in
            //Do nothing - will return to screen.
            }
            alertController.addAction(okbutton)
            self.presentViewController(alertController, animated: true) {
            }
        } else {
            self.checkAns()
        }
    }
    
    
    func checkAns() {
        
        var numCorrect = 0
        var accelAnswers:[String] = ["acceleration","accel"]
        var accelMistakes:[String] = ["aceleration", "acel"]
        if contains(accelAnswers+accelMistakes,ansTxt1.text.lowercaseString) {
            //println("Correct acceleration")
            numCorrect++
            }
        
        var velAnswers:[String] = ["velocity","vel","speed"]
        var velMistakes:[String] = ["veolcity", "vilocity", "sped"]
        if contains(velAnswers+velMistakes,ansTxt2.text.lowercaseString) {
            //println("Correct velocity")
            numCorrect++
        }
        
        var posAnswers:[String] = ["position","distance","displacement", "dist","pos"]
        var posMistakes:[String] = ["postion", "distence", "displacemint"]
        if contains(posAnswers+posMistakes,ansTxt3.text.lowercaseString) {
            //println("Correct position")
            numCorrect++
        }
        
        if numCorrect == 3 {

            let imageCorrect = UIImage(named: "tickbox")
            self.popViewController = PopUpViewControllerSwift()
            self.popViewController.title = "Correct :)"
            self.popViewController.showInView(self.view, withImage: imageCorrect, withMessage: "You got all three correct :)", animated: true, correct: true)
            var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("closePopUpCorrect"), userInfo: nil, repeats: false)
            
        } else {
            
            let imageWrong = UIImage(named: "crossBox")
            self.popViewController = PopUpViewControllerSwift()
            self.popViewController.title = "Wrong :("
            self.popViewController.showInView(self.view, withImage: imageWrong, withMessage: "You got \(3-numCorrect) wrong :(", animated: true, correct: false)
            var timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("closePopUp"), userInfo: nil, repeats: false)
            
        }
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.view.frame.origin.y -= keyboardFrame.height
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.view.frame.origin.y += keyboardFrame.height
    }
    
    func textFieldShouldReturn(txtField: UITextField) -> Bool {
        txtField.resignFirstResponder()
        return true;
    }
    
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    
    func closePopUp() {
        popViewController.closePopup()
        
    }
    
    func closePopUpCorrect() {
        popViewController.closePopup()
        nQstn.goToNext(self.navigationController!)
        
    }
    
}

