//
//  calcQstns.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 05/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class calcQstns: UIViewController, UIDocumentInteractionControllerDelegate, UITextFieldDelegate {

    var resultsText = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var rightWrongText = UITextView(frame: CGRect(x: 50, y: 50, width: 900, height: 300));
    var answerPreText:UITextView = UITextView(frame: CGRect(x: 30, y: 500, width: 220, height: 120));
    var answerPostText:UITextView = UITextView(frame: CGRect(x: 510, y: 530, width: 200, height: 120));
    var notCalcVarString = ""
    var calcVarString = ""
    var calcVarSymbol = ""
    var calcVarUnit = ""
    var notCalcVarUnit = ""
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var answerText = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    var velinit = 0.0
    var constAccel = 0.0
    var timeConstAccel = 0.0
    var distConstAccel = 0.0
    //Tolerance for a right answer
    var tolerance:Double = 0.0
    var qstntype: Int = 0

    override init() {

        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(velinit: Double, constAccel: Double, timeConstAccel: Double, distConstAccel: Double, tolerance: Double, qstntype: Int) {
        
        self.init()

        self.velinit = velinit
        self.constAccel = constAccel
        self.timeConstAccel = timeConstAccel
        self.distConstAccel = distConstAccel
        self.tolerance = tolerance
        self.qstntype = qstntype
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Listen for keyboard in order to move view so can still see textfield
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        
         rightWrongText.backgroundColor = UIColor.clearColor()
        
        calcAccelQstn(qstntype)
        
    }
    
    func calcAccelQstn(calcVar: Int) {
        
        var givenVal = 0.0
        //decide if asking for accel or initial velocity
        //If asking for accel...
        if calcVar == 0 {
            notCalcVarString = "initial velocity"
            calcVarString = "acceleration"
            calcVarSymbol = "a"
            calcVarUnit = "m/s2"
            notCalcVarUnit = "m/s"
            givenVal = velinit
            //If asking for initial velocity...
        } else {
            notCalcVarString = "acceleration"
            calcVarString = "initial velocity"
            calcVarSymbol = "v0"
            calcVarUnit = "m/s"
            notCalcVarUnit = "m/s2"
            givenVal = constAccel
        }
        
        //Ask question based on data according to mock setting
        resultsText = UITextView(frame: CGRect(x: 50, y: 50, width: screenSize.width-100, height: 500.00));
        resultsText.font = UIFont(name: "Arial", size: 60)
        resultsText.backgroundColor = UIColor.clearColor()
        resultsText.editable = false
        
        resultsText.text = "Phone slid for \(round(100*timeConstAccel)/100) seconds, for a distance of \(round(100*distConstAccel)/100) meters. The \(notCalcVarString) of your push was \(round(100*givenVal)/100) \(notCalcVarUnit). What was the phones \(calcVarString)?"
        self.view.addSubview(resultsText)
        //fitToText(resultsText)
        
        //Add text to go around answer
        answerPreText.font = UIFont(name: "Arial", size: 100)
        answerPreText.text = "\(calcVarSymbol) = "
        answerPreText.editable = false
        answerPreText.backgroundColor = UIColor.clearColor()
        self.view.addSubview(answerPreText)
        
        answerPostText.font = UIFont(name: "Arial", size: 70)
        answerPostText.text = "\(calcVarUnit)"
        answerPostText.editable = false
        answerPostText.backgroundColor = UIColor.clearColor()
        self.view.addSubview(answerPostText)
        
        //Add textbox for answer
        answerText = UITextField(frame: CGRect(x: 250, y: 500, width: 250.00, height: 120.00));
        answerText.placeholder = "2 d.p"
        answerText.layer.cornerRadius = 4.0
        answerText.layer.masksToBounds = true
        answerText.layer.borderColor = UIColor.blueColor().CGColor
        answerText.font = UIFont(name: "Arial", size: 90)
        answerText.layer.borderWidth = 2.0
        answerText.delegate = self;
        answerText.keyboardType = UIKeyboardType.DecimalPad
        self.view.addSubview(answerText)
        
        //Answer submit button
        submitButton.frame = CGRectMake(700, 500, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        self.view.addSubview(submitButton)
    }
    
    func submitAnswer(sender:UIButton) {
        //Here we check answer is numerical and then compare with actual answer
        //up to tolerance. Give student correct or wrong screen. Also note for if
        //they forget negative value
        
        textFieldShouldReturn(answerText)
        //keyboardWillHide()
        
        var aStr = answerText.text
        
        //Check whether for current question we are checking against accel or initial vel
        var checkVal = 0.0
        if calcVarSymbol == "a" {
            checkVal = constAccel
        } else {
            checkVal = velinit
        }
        
        
        //if (aStr =~ "^(?:|0|[1-9]\\d*)(?:\\.\\d*)(?:\\-\\d*)?$") {
        //if (aStr =~ "^\\-(?:|0|[1-9]\\d*)(?:\\.\\d*)?$") {
        if (aStr =~ "^-?[0-9]\\d*(\\.\\d+)?$") {
            if (fabs((aStr as NSString).doubleValue - checkVal) < Double(tolerance)) {
                resultsText.removeFromSuperview()
                rightWrongText.text = "CORRECT!"
                rightWrongText.font = UIFont(name: "Arial", size: 150)
                self.view.addSubview(rightWrongText)
                self.view.backgroundColor = UIColor.greenColor()
                var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("finishRight"), userInfo: nil, repeats: false)
            } else {
                resultsText.removeFromSuperview()
                rightWrongText.text = "WRONG!"
                rightWrongText.font = UIFont(name: "Arial", size: 200)
                self.view.addSubview(rightWrongText)
                self.view.backgroundColor = UIColor.redColor()
                var timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: Selector("finishWrong"), userInfo: nil, repeats: false)
            }
            
        } else {
            println("NOT cool dude. NOT COOL")
        }
        
        
    }
    
    
    func finishWrong() {
        rightWrongText.removeFromSuperview()
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(resultsText)
    }
    
    func finishRight() {
        rightWrongText.removeFromSuperview()
        self.view.backgroundColor = UIColor.whiteColor()
        answerText.removeFromSuperview()
        answerPreText.removeFromSuperview()
        answerPostText.removeFromSuperview()
        submitButton.removeFromSuperview()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        self.view.frame.origin.y -= keyboardFrame.height
    }
    
    func keyboardWillHide(sender: NSNotification) {
        
        var info = sender.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        self.view.frame.origin.y += keyboardFrame.height
    }
    
    func textFieldShouldReturn(txtField: UITextField!) -> Bool {
        txtField.resignFirstResponder()
        return true;
    }
    
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
