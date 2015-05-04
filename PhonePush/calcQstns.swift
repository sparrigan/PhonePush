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
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    var answerText = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    var velinit = 0.0
    var constAccel = 0.0
    var timeConstAccel = 0.0
    var distConstAccel = 0.0
    //Tolerance for a right answer
    var tolerance:Double = 0.0
    var qstntype: Int = 0
    var givenVal = 0.0
    //Instance of font resizing object for auto-layout
    var textResizer:findTextSize?
    var checkViewAppearedForFirstTime = 0
    var ansView:UIView = UIView(frame: CGRectMake(0,0,0,0))
    
    init() {

        super.init(nibName: nil, bundle: nil)
    }
    

    convenience init(pushData: [String: Any]) {
        
        self.init()
       
        //Need to check for all these values properly
        self.velinit = pushData["velInit"] as! Double
        self.constAccel = pushData["constAccel"] as! Double
        self.timeConstAccel = pushData["timeConstAccel"] as! Double
        self.distConstAccel = pushData["distConstAccel"] as! Double
        self.tolerance = 0.2
        self.qstntype = 0
        
        self.view.backgroundColor = UIColor.whiteColor()

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        //Listen for keyboard in order to move view so can still see textfield
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        rightWrongText.backgroundColor = UIColor.clearColor()
        
        calcAccelQstn(qstntype)
        
        //Correct answer for debugging:
        println("Correct constant acceleration answer is: \(constAccel)")
        
        
        setupViews()
        
    }
    
    func calcAccelQstn(calcVar: Int) {
        
        
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
        
        
    }
    
    func setupViews() {
        
        //Ask question based on data according to mock setting
        resultsText = UITextView(frame: CGRect(x: 50, y: 50, width: screenSize.width-100, height: 500.00));
        resultsText.font = UIFont(name: "Arial", size: 60)
        resultsText.backgroundColor = UIColor.greenColor()
        resultsText.editable = false
        //resultsText.scrollEnabled = false
        
        resultsText.text = "Phone slid for \(round(100*timeConstAccel)/100) seconds, for a distance of \(round(100*distConstAccel)/100) meters. The \(notCalcVarString) of your push was \(round(100*givenVal)/100) \(notCalcVarUnit). What was the phones \(calcVarString)?"
        self.view.addSubview(resultsText)
        //fitToText(resultsText)
        
        //Add text to go around answer
        answerPreText.font = UIFont(name: "Arial", size: 100)
        answerPreText.text = "\(calcVarSymbol) = "
        answerPreText.editable = false
        answerPreText.backgroundColor = UIColor.clearColor()
        
        answerPostText.font = UIFont(name: "Arial", size: 70)
        answerPostText.text = "\(calcVarUnit)"
        answerPostText.editable = false
        answerPostText.backgroundColor = UIColor.clearColor()
        
        //Add textbox for answer
        answerText = UITextField(frame: CGRect(x: 0, y: 0, width: 250.00, height: 120.00));
        answerText.placeholder = "2 d.p"
        answerText.layer.cornerRadius = 4.0
        answerText.layer.masksToBounds = true
        answerText.layer.borderColor = UIColor.blueColor().CGColor
        answerText.font = UIFont(name: "Arial", size: 90)
        answerText.layer.borderWidth = 2.0
        answerText.delegate = self;
        answerText.keyboardType = UIKeyboardType.DecimalPad
        
        //Answer submit button
        submitButton.frame = CGRectMake(0, 0, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        
        //View to contain all graphs and view to contain all answer buttons
        ansView = UIView(frame: CGRectMake(0,0,screenSize.width,300))
        //Color for testing
        ansView.backgroundColor = UIColor.clearColor()
        
        //Stop swift from adding its own constraints for all views in use by autolayout
        resultsText.setTranslatesAutoresizingMaskIntoConstraints(false)
        ansView.setTranslatesAutoresizingMaskIntoConstraints(false)
        answerPreText.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        answerPostText.setTranslatesAutoresizingMaskIntoConstraints(false)
        answerText.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Add subviews to relevant parent views.
        //NOTE: May need to add these subviews in viewDidAppear instead of viewDidLoad...
        self.view.addSubview(resultsText)
        self.view.addSubview(ansView)
        
        //add graphs as subviews to graphView UIView
        ansView.addSubview(answerPreText)
        ansView.addSubview(answerPostText)
        ansView.addSubview(submitButton)
        ansView.addSubview(answerText)
        
        //Dictionary for all views to be managed by autolayout
        let viewsDictionary = ["resultsText":resultsText,"ansView":ansView, "answerPreText":answerPreText,"answerPostText":answerPostText,"submitButton":submitButton,"answerText":answerText]
        //Metrics used by autolayout
        let metricsDictionary = ["minGraphWidth": 20]
        
        //CONSTRAINT FOR SELF.VIEW
        let constraintsV:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[resultsText]-(<=20)-[ansView]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //RESULTSTEXT specific contraints
        let wConstraint = NSLayoutConstraint(item: resultsText, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let centConstraint = NSLayoutConstraint(item: resultsText, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let hConstraint = NSLayoutConstraint(item: resultsText, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.5, constant: 0)
        //ANSVIEW specific constraints
        let wAnsConstraint = NSLayoutConstraint(item: ansView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let hAnsConstraint = NSLayoutConstraint(item: ansView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        //Add constraints to self.view
        self.view.addConstraints(constraintsV+[wConstraint,centConstraint,hConstraint,wAnsConstraint, hAnsConstraint])
        
        //CONSTRAINTS FOR ANSVIEW
        //Heights of graphs within ansView
        
        let aPreTConstraint = NSLayoutConstraint(item: answerPreText, attribute: .Height, relatedBy: .Equal, toItem: ansView, attribute: .Height, multiplier: 1.0, constant: 0)
        let aTConstraint = NSLayoutConstraint(item: answerText, attribute: .Height, relatedBy: .Equal, toItem: ansView, attribute: .Height, multiplier: 1.0, constant: 0)
        let aPostTConstraint = NSLayoutConstraint(item: answerPostText, attribute: .Height, relatedBy: .Equal, toItem: ansView, attribute: .Height, multiplier: 1.0, constant: 0)
        let sButtonConstraint = NSLayoutConstraint(item: submitButton, attribute: .Height, relatedBy: .Equal, toItem: ansView, attribute: .Height, multiplier: 1.0, constant: 0)
        //Center vertically in ansView
        let aPreTcentConstraint = NSLayoutConstraint(item: answerPreText, attribute: .CenterY, relatedBy: .Equal, toItem: ansView, attribute: .CenterY, multiplier: 1, constant: 0)
        let aTcentConstraint = NSLayoutConstraint(item: answerText, attribute: .CenterY, relatedBy: .Equal, toItem: ansView, attribute: .CenterY, multiplier: 1, constant: 0)
        let aPostTcentConstraint = NSLayoutConstraint(item: answerPostText, attribute: .CenterY, relatedBy: .Equal, toItem: ansView, attribute: .CenterY, multiplier: 1, constant: 0)
        let sButtoncentConstraint = NSLayoutConstraint(item: submitButton, attribute: .CenterY, relatedBy: .Equal, toItem: ansView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        //layout within ansView (including widths - min as set in metric, but fill out to
        //view with equal widths)
        let gDconstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=10)-[answerPreText(>=200)][answerText(>=200)][answerPostText(>=200)]-[submitButton]-(>=10)-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //Add constraints to graphView
        ansView.addConstraints(gDconstraintH+[aPreTConstraint,aTConstraint,aPostTConstraint,sButtonConstraint,aPreTcentConstraint,aTcentConstraint,aPostTcentConstraint,sButtoncentConstraint])
        
        
        //Font resizing function: send list of views for resizing to font resizer object
        textResizer = findTextSize(vArray: [resultsText])
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        textResizer!.updateViewFont("")
        
        checkViewAppearedForFirstTime = 1
        println(checkViewAppearedForFirstTime)
    }
    
    override func viewDidLayoutSubviews() {
        
        println("Trying to run with...\(checkViewAppearedForFirstTime)")
        
        //Need this check to prevent crashes
        if checkViewAppearedForFirstTime == 1 {
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            {
                //Check whether there is already a value for that view set in dictionary?
                println("landscape")
                println("Sending a view of size: width:\(resultsText.frame.size.width), height:\(resultsText.frame.size.height)")
                textResizer!.updateViewFont("Landscape")
            }
            if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
            {
                println("Portrait")
                println("Sending a view of size: width:\(resultsText.frame.size.width), height:\(resultsText.frame.size.height)")
                textResizer!.updateViewFont("Portrait")
            }
        }
        println("BACK IN MAIN AND FONTSIZE IS: \(resultsText.font.pointSize)")
        
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
            //println("NOT cool dude. NOT COOL")
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
        //Probs don't need all the above shit now
        
        nQstn.goToNext(self.navigationController!)
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
