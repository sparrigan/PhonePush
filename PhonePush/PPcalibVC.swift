//  PPcalibVC.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/03/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.

//ViewController that obtains calibration information and records a phone push
//NOTE: There is a check for the average constant acceleration recorded to be negative,
//this will need to be turned off for more general uses of this class

import UIKit

    infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}


class PPcalibVC: UIViewController, UIDocumentInteractionControllerDelegate, accelRecorderDelegate, UITextFieldDelegate {

    
    
    //This variable determines whether students will be asked to calculate acceleration (0)
    //or initial velocity (1)
    
    var mockSetting = 0
    

    var tb = UITextField(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
    //Initialise with empty value
    var aRec:accelRecorder = accelRecorder(tb: UITextField(frame: CGRectMake(0,0,0,0)))
    var calibcheck:Int = 0
    let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let startButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let sendAccelButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let sendVelButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let sendPosButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    var stopped = 0
    var aDbl: [Double] = []
    var vDbl: [Double] = []
    var pDbl: [Double] = []
    var tDbl: [Double] = []
    var velinit = 0.0
    //var indexConstAccel: Int?
    var constAccel = 0.0
    var timeConstAccel = 0.0
    var distConstAccel = 0.0
    var titleText:UITextView = UITextView(frame: CGRect(x: 50, y: 50, width: 90.00, height: 10.00));
    var calibText:UITextView = UITextView(frame: CGRect(x: 70, y: 250, width: 90.00, height: 10.00));
    var settingVar = 2
    var currentQstn:Int = 0
    //Tolerance for a right answer
    let tolerance:Double = 0.11

    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    //DON'T NEED THIS CONVENIENCE INIT ANYMORE, AS DEAL WITH
    //INCREMENTING QUESTION NUMBER IN NEXTQSTN CLASS
    convenience init(cQstn: Int) {
        self.init()
        currentQstn = cQstn
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()

        //Instantiate accelerator recorder object
        
        aRec = accelRecorder(tb: tb)
        aRec.delegate = self
        
        //Phone pushing prompts (all subsequent code follows from button press functions):
        titleText.text = "Ready, steady..."
        titleText.font = UIFont(name: "Arial", size: 120)
        //UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleText.editable = false
        self.view.addSubview(titleText)
        //Code that resizes UITextField to fit contents
        fitToText(titleText)
        calibText.text = "Place phone in stable starting position and then push calibrate"
        calibText.font = UIFont(name: "Arial", size: 30)
        calibText.editable = false
        self.view.addSubview(calibText)
        fitToText(calibText)
        button.frame = CGRectMake(300, 450, 500, 250)
        button.backgroundColor = UIColor(red: 127.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button.setTitle("Calibrate", forState: UIControlState.Normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        button.addTarget(self, action: "calibrateStart:", forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
    }
    
    func calibrateStart(sender:UIButton) {
        if calibcheck == 0 {
        calibcheck = 1
        aRec.calibrate()
        }
    }
    
    func endOfCalib() {
     button.removeFromSuperview()
        
    startButton.frame = CGRectMake(300, 450, 500, 250)
    startButton.backgroundColor = UIColor(red: 151.0/255.0, green: 241.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    startButton.setTitle("Start", forState: UIControlState.Normal)
    startButton.layer.cornerRadius = 20
    startButton.layer.borderWidth = 5
    startButton.layer.borderColor = UIColor.blackColor().CGColor
    startButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
    startButton.addTarget(self, action: "recStart:", forControlEvents: .TouchUpInside)
    self.view.addSubview(startButton)
        
    }
    
    func recStart(sender:UIButton) {
        if stopped == 0 {
            //Call recording method in accelRecorder model
            aRec.startRec()
            startButton.setTitle("Finished", forState: .Normal)
            stopped = 1
            //Stop recording if currently recording
        } else if stopped == 1 {
            stopped = 0
            
            //Call stop recording method in model and receive data
            
            //Make final accel return an optional that is set to nil if less than 10 data
            //passed to it (or in any other case that would want someone to do a repush)
            //Check that we have more than 10 values recorded from accelerometer (stop
            //method returns nil otherwise). If not, alert user of bad push and ask to redo
            
            if let finalaccel = aRec.stopRec() {
            
                aDbl = finalaccel.aDbl
                tDbl = finalaccel.tDbl
                vDbl = finalaccel.vDbl
                pDbl = finalaccel.pDbl
                
            
            
                //Find the index at which constant acceleration starts
                //(Find index at which the time appears in tDbl)
                //Check that can unwrap optional result of find and if not alert and redo push
                if let indexConstAccel = find(tDbl,finalaccel.startConstAccel) {
                    
                    //Find initial velocity as vel at time where accel first negative
                        velinit = vDbl[indexConstAccel]
                    //Find average acceleration value from constant region
                    constAccel = aDbl[indexConstAccel..<aDbl.count].reduce(0,combine: +)/Double(aDbl.count-indexConstAccel)
                    //Find total time of constant acceleration
                    timeConstAccel = tDbl[tDbl.count-1] - tDbl[indexConstAccel]
                    //Find total distance moved under constant acceleration
                        distConstAccel = pDbl[pDbl.count-1] - pDbl[indexConstAccel]
                
                    //Check that the average acceleration calculated is negative before
                    //finally collecting data and sending it on to questions. If not
                    //then prompt user to push again
                    if constAccel < 0 {
                        
                        //Build a dictionary with all the recorded data
                        var pushData: [String: Any] = ["aRaw": aDbl, "vRaw": vDbl, "pRaw":pDbl, "tRaw":tDbl, "indexConstAccel":indexConstAccel, "constAccel":constAccel, "timeConstAccel":timeConstAccel, "distConstAccel":distConstAccel, "velInit":velinit]
                    
                        //Add new accelerometer data to class that sorts through questions passing
                        //data between them
                        nQstn.passAccelData(pushData)
           
                        //Open up first question by calling class that sorts through question
                        nQstn.goToNext(self.navigationController!)
                    } else {
                        //Alert for if we get back a positive acceleration
                        //NOTE: This needs to be 'turned off' in cases where we call
                        //acceleration logger for other activities
                        restartCalib("Make sure the phone can slide easily!")
                    }
              
                } else {
                    //Alert for if we cannot unwrap the result of finding element in time
                    //array at which constant acceleration happens (this is forced to be
                    //optional by the inbuilt find method)
                    restartCalib("Something werid happened!")
                }
            } else {
                //Alert for If we get nil back from accelrecorder.stop method 
                //(i.e. not enough data sent)
                restartCalib("Push too short to get any data")
            }
        }
    }
    
    
    //Function that gives user alert and then restarts the calibration VC in case of errors
    //etc... Also passed a string that contains more info dependent on why needed to push again
    func restartCalib(specificProblem: String) {
        
        //Present alert:
        let alertController = UIAlertController(title: "Oops! " + specificProblem, message: "Please push again. \n (you'll also need to recalibrate)", preferredStyle: .Alert)
        //When retry button is clicked, reload a new instance of calibration VC to top
        //of stack
        var retrybutton = UIAlertAction(title: "Redo push", style: .Cancel) { (_) in
        
            if let navi = self.navigationController {
                var VCstack = navi.viewControllers
                //Remove top VC root is at 0, top is at count
                VCstack.removeLast()
                var restartCalib: PPcalibVC = PPcalibVC()
                //Add nextVC to top of stack
                VCstack.append(restartCalib)
                //Animate transition from old stack to newly formed one
                navi.setViewControllers(VCstack, animated: false)
            }
            
        }
        alertController.addAction(retrybutton)
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    //OLD FUNCTION FOR OPENING QUESTIONS AFTER CALIBRATION DIRECTLY
    /*
    func openQstnWithData(pushData: [String: Any]) {
        
        //Make this all depend on index value
        
        //Get what VCs are currently in stack
        var VCstack = self.navigationController!.viewControllers
        //Remove top VC root is at 0, top is at count
        VCstack.removeLast()
        //Create instance of new VC to add in place of old top
        var nextVC:calcQstns? = calcQstns(pushData: pushData, currentQstn: currentQstn)
        //Add new VC
        VCstack.removeLast()
        VCstack.append(nextVC!)
        //Animate transition from old stack to newly formed one
        navigationController!.setViewControllers(VCstack, animated: true)
        
    }
    */
    
    func getCalibration(acC: CGPoint, aCount: Double) {
        //For debugging, AccelRecorder calls this function with calib data
    }
    
    
    //Function for exporting data to email
    //Call this from a button fired function
    func ExportToCSVVEL(delegate: UIDocumentInteractionControllerDelegate, data: String){
        let fileName = NSTemporaryDirectory().stringByAppendingPathComponent("myFile.csv")
        let url: NSURL! = NSURL(fileURLWithPath: fileName)
        data.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        if url != nil {
            let docController = UIDocumentInteractionController(URL: url)
            docController.UTI = "public.comma-separated-values-text"
            docController.delegate = delegate
            docController.presentPreviewAnimated(true)
        }
    }
    
    //Takes in two Arrays of Doubles and converts each element to a string, and cocatenates
    //corresponding entries of arrays with a comma. Note: Order of inputs is important
    func dblToStringRows (AA: [Double], BB: [Double])->[String] {
        var temp:[String] = []
        //Only concatenate strings up until the length of shortest array input
        var shortestCount = [AA.count,BB.count].reduce(Int.max, combine: { min($0, $1) })
        for i in 0...shortestCount-1 {
            temp += [",".join([String(format:"%f",AA[i]),String(format:"%f",BB[i])])]
        }
        return temp
    }
    
    //Required method to be delegate of UIInteractionControllerView
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }


    //Function that fits a textfield to its content (NOTE: MUST HAVE BEEN ADDED AS SUBVIEW FIRST)
    func fitToText(textField: UITextView) {
        var fixedWidth:CGFloat = textField.frame.size.width
        var newSize:CGSize = textField.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        var newFrame:CGRect = textField.frame
        newFrame.size = CGSizeMake(newSize.height,CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))))
        textField.frame = newFrame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
}