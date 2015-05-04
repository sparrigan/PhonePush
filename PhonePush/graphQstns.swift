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
    
    var checkViewAppearedForFirstTime = 0
    var timeArray:[Double] = []
    var accelArray:[Double] = []
    var velArray:[Double] = []
    var posArray:[Double] = []
    var qstntype: Int = 0
    var questionText = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var graphView:UIView = UIView(frame: CGRectMake(0,0,0,0))
    var ansButtonsView:UIView = UIView(frame: CGRectMake(0,0,0,0))
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var ansTxt1 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var ansTxt2 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var ansTxt3 = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    
    //Variables for holding graphplotter instances for a-t, v-t and x-t graphs
    var graph1:graphPlotter = graphPlotter()
    var graph2:graphPlotter = graphPlotter()
    var graph3:graphPlotter = graphPlotter()
    //variables for holding the hostviews of each graph (which we allow autolayout to manage)
    var gD:UIView = UIView()
    var gD2:UIView = UIView()
    var gD3:UIView = UIView()
    
    //VC for popups for right or wrong answers
    var popViewController : PopUpViewControllerSwift!
    //Instance of font resizing object for auto-layout
    var textResizer:findTextSize?
    
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
        graph1 = graphPlotter(vSize: CGRectMake(10,210,30,30), xArray: timeArray, yArray: accelArray)
        graph1.loadgraph()
        graph2 = graphPlotter(vSize: CGRectMake(0,0,0,0), xArray: timeArray, yArray: velArray)
        graph2.loadgraph()
        graph3 = graphPlotter(vSize: CGRectMake(0,0,0,0), xArray: timeArray, yArray: posArray)
        graph3.loadgraph()
        
        //Assign hostViews of each graph
        gD = graph1.hostView as UIView
        gD2 = graph2.hostView as UIView
        gD3 = graph3.hostView as UIView
        
        //Call function that places all the views we need and setups autolayout constraints
        setupViews()
        
     
    }
    
    override func viewDidAppear(animated: Bool) {
        textResizer!.updateViewFont("")
    
        checkViewAppearedForFirstTime = 1
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //Need this check to prevent crashes
        if checkViewAppearedForFirstTime == 1 {
            if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation))
            {
                //Check whether there is already a value for that view set in dictionary?
                println("landscape")
                textResizer!.updateViewFont("Landscape")
            }
            if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
            {
                println("Portrait")
                textResizer!.updateViewFont("Portrait")
            }
        }
        
    }
    
    
    func setupViews() {
        
        //Ask question based on data according to mock setting
        questionText = UITextView(frame: CGRect(x: 50, y: 25, width: screenSize.width-100, height: 200.00));
        questionText.font = UIFont(name: "Arial", size: 60)
        questionText.backgroundColor = UIColor.clearColor()
        questionText.editable = false
        questionText.text = "What variable is plotted on the y-axis in each graph?"
        //questionText.backgroundColor = UIColor.greenColor()
        
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
        
        //Answer submit button
        submitButton.frame = CGRectMake(screenSize.width-275, screenSize.height-140, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        submitButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        //View to contain all graphs and view to contain all answer buttons
        graphView = UIView(frame: CGRectMake(0,0,screenSize.width,300))
        //Color for testing
        graphView.backgroundColor = UIColor.clearColor()
        ansButtonsView = UIView(frame: CGRectMake(0,0,screenSize.width,100))
        //Color for testing
        ansButtonsView.backgroundColor = UIColor.clearColor()
        
        //Stop swift from adding its own constraints for all views in use by autolayout
        questionText.setTranslatesAutoresizingMaskIntoConstraints(false)
        graphView.setTranslatesAutoresizingMaskIntoConstraints(false)
        ansButtonsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        gD.setTranslatesAutoresizingMaskIntoConstraints(false)
        gD2.setTranslatesAutoresizingMaskIntoConstraints(false)
        gD3.setTranslatesAutoresizingMaskIntoConstraints(false)
        ansTxt1.setTranslatesAutoresizingMaskIntoConstraints(false)
        ansTxt2.setTranslatesAutoresizingMaskIntoConstraints(false)
        ansTxt3.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Add subviews to relevant parent views.
        //NOTE: May need to add these subviews in viewDidAppear instead of viewDidLoad...
        self.view.addSubview(graphView)
        self.view.addSubview(ansButtonsView)
        self.view.addSubview(questionText)
        self.view.addSubview(submitButton)
        //add graphs as subviews to graphView UIView
        graphView.addSubview(gD)
        graphView.addSubview(gD2)
        graphView.addSubview(gD3)
        //add answer textfields to ansButtonView UIView
        ansButtonsView.addSubview(ansTxt1)
        ansButtonsView.addSubview(ansTxt2)
        ansButtonsView.addSubview(ansTxt3)
        
        //Dictionary for all views to be managed by autolayout
        let viewsDictionary = ["questionText":questionText,"graphView":graphView, "ansButtonsView":ansButtonsView,"submitButton":submitButton,"gD":gD,"gD2":gD2,"gD3":gD3,"ansTxt1":ansTxt1,"ansTxt2":ansTxt2,"ansTxt3":ansTxt3]
        //Metrics used by autolayout
        let metricsDictionary = ["minGraphWidth": 20]
        
        //CONSTRAINT FOR SELF.VIEW
        let constraintsV:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[questionText]-(<=20)-[graphView]-[ansButtonsView]-(<=30)-[submitButton]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //QUESTIONTEXT specific contraints
        let wConstraint = NSLayoutConstraint(item: questionText, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let centConstraint = NSLayoutConstraint(item: questionText, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let hConstraint = NSLayoutConstraint(item: questionText, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.25, constant: 0)
        //GRAPHVIEW specific constraints
        let wGraphConstraint = NSLayoutConstraint(item: graphView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let hGraphConstraint = NSLayoutConstraint(item: graphView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.4, constant: 0)
        //ANSBUTTONS specific constraints
        let wAnsConstraint = NSLayoutConstraint(item: ansButtonsView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let hAnsConstraint = NSLayoutConstraint(item: ansButtonsView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        let hSubmitButtonConstraint = NSLayoutConstraint(item: submitButton, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        let sumbitCentConstraint = NSLayoutConstraint(item: submitButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        //Add constraints to self.view
        self.view.addConstraints(constraintsV+[wConstraint,centConstraint,hConstraint,wGraphConstraint, hGraphConstraint,wAnsConstraint,hAnsConstraint,hSubmitButtonConstraint,sumbitCentConstraint])
        
        //CONSTRAINTS FOR GRAPHVIEW
        //Heights of graphs within graphView
        let hgDConstraint = NSLayoutConstraint(item: gD, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hgD2Constraint = NSLayoutConstraint(item: gD2, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hgD3Constraint = NSLayoutConstraint(item: gD3, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        //Center vertically in graphView
        let gDcentConstraint = NSLayoutConstraint(item: gD, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        let gD2centConstraint = NSLayoutConstraint(item: gD2, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        let gD3centConstraint = NSLayoutConstraint(item: gD3, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        //layout within graphView (including widths - min as set in metric, but fill out to
        //view with equal widths)
        let gDconstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[gD(>=minGraphWidth)]-[gD2(==gD)]-[gD3(==gD)]-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //Add constraints to graphView
        graphView.addConstraints([hgDConstraint,hgD2Constraint,hgD3Constraint,gDcentConstraint,gD2centConstraint,gD3centConstraint]+gDconstraintH)
        
        //CONSTRAINTS FOR ANSBUTTONSVIEW
        //Heights of answer textfields within ansbuttonsview
        let hAns1Constraint = NSLayoutConstraint(item: ansTxt1, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hAns2Constraint = NSLayoutConstraint(item: ansTxt2, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hAns3Constraint = NSLayoutConstraint(item: ansTxt3, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        //Center vertically in ansbuttonsview
        let ans1centConstraint = NSLayoutConstraint(item: ansTxt1, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        let ans2centConstraint = NSLayoutConstraint(item: ansTxt2, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        let ans3centConstraint = NSLayoutConstraint(item: ansTxt3, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        //layout within ansbuttonsview (including widths - min as set in metric, but fill out
        //to view with equal widths)
        let ansTxtconstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[ansTxt1(>=minGraphWidth)]-[ansTxt2(==ansTxt1)]-[ansTxt3(==ansTxt1)]-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //Add constraints to ansbuttonsview
        ansButtonsView.addConstraints([hAns1Constraint,hAns2Constraint,hAns3Constraint,ans1centConstraint,ans2centConstraint,ans3centConstraint]+ansTxtconstraintH)
        
        //Font resizing function: send list of views for resizing to font resizer object
        textResizer = findTextSize(vArray: [questionText])
        
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

