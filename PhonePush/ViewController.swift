//
//  ViewController.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/03/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.


//PHONEPUSH Main ViewController with calibration
import UIKit

protocol PPVCProtocol {
    
    func returnData()

}

    infix operator =~ {}

func =~ (input: String, pattern: String) -> Bool {
    return Regex(pattern).test(input)
}


class ViewController: UIViewController, UIDocumentInteractionControllerDelegate, PPVCProtocol, accelRecorderDelegate, UITextFieldDelegate {

    
    
    //This variable determines whether students will be asked to calculate acceleration (0)
    //or initial velocity (1)
    
    var mockSetting = 0
    
    var aRec:accelRecorder?
    var tb = UITextField(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
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
    var indexConstAccel = 0
    var constAccel = 0.0
    var timeConstAccel = 0.0
    var distConstAccel = 0.0
    var titleText:UITextView = UITextView(frame: CGRect(x: 50, y: 50, width: 90.00, height: 10.00));
    var calibText:UITextView = UITextView(frame: CGRect(x: 70, y: 250, width: 90.00, height: 10.00));
    var calcQstnsVC:calcQstns?
    var graphQstnsVC:graphQstns?
    var settingVar = 2
    
    //Tolerance for a right answer
    let tolerance:Double = 0.11

    override func viewDidLoad() {
        super.viewDidLoad()
        

        

        
        //Instantiate objects
        aRec = accelRecorder(tb: tb)
        
        //Set this viewcontroller as delegate to recieve from accelRecorder
        aRec!.delegate = self
        
        self.view.backgroundColor = UIColor.whiteColor()

        //PROMPT FOR PUSHING PHONE:
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
        
        //let button   = UIButton.buttonWithType(UIButtonType.System) as UIButton
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Function that fits a textfield to its content (NOTE: MUST HAVE BEEN ADDED AS SUBVIEW FIRST)
    func fitToText(textField: UITextView) {
        var fixedWidth:CGFloat = textField.frame.size.width
        println(fixedWidth)
        var newSize:CGSize = textField.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        println(newSize)
        var newFrame:CGRect = textField.frame
        println(newFrame)
        newFrame.size = CGSizeMake(newSize.height,CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))))
        println(newFrame)
        textField.frame = newFrame
        println(textField.frame)
        println("done")
    }
    
    func getCalibration(acC: CGPoint, aCount: Double) {
     //   calibStatus.text = "Calibration completed and available"
        //println(acC)
        //println(aCount)
        //println("[\(Double(acC.x)/aCount), \(Double(acC.y)/aCount)]")
    }
    
    func calibrateStart(sender:UIButton) {
        if calibcheck == 0 {
        calibcheck = 1
        aRec!.calibrate()
        }
    }
    
    func returnData() {
        println("YUS")
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
            aRec!.startRec()
            startButton.setTitle("Finished", forState: .Normal)
            stopped = 1
            //Stop recording if currently recording
        } else if stopped == 1 {
            stopped = 0
            
            /*
            //Remove text from top of screen
            titleText.removeFromSuperview()
            calibText.removeFromSuperview()
            //Remove start button
            startButton.removeFromSuperview()
            */
            
            //Call stop recording method in model and receive data
            var finalaccel = aRec!.stopRec()
            aDbl = finalaccel.aDbl
            tDbl = finalaccel.tDbl
            vDbl = finalaccel.vDbl
            pDbl = finalaccel.pDbl
            //Find the index at which constant acceleration starts
            //(Find index at which the time appears in tDbl)
            indexConstAccel = find(tDbl,finalaccel.startConstAccel)!
            //Find initial velocity as vel at time where accel first negative
            if vDbl.count>0 {
                velinit = vDbl[indexConstAccel]
                //Alternative method: Finding maximum value from whole array
                //velinit = vDbl.reduce(Double(Int.min), { max($0, $1) })
            }
            //Find average acceleration value from constant region
            if aDbl.count>0 {
            constAccel = aDbl[indexConstAccel..<aDbl.count].reduce(0,combine: +)/Double(aDbl.count-indexConstAccel)
            }
            //Find total time of constant acceleration
            if tDbl.count>0 {
            timeConstAccel = tDbl[tDbl.count-1] - tDbl[indexConstAccel]
            }
            //Find total distance moved under constant acceleration
            if pDbl.count>0 {
            distConstAccel = pDbl[pDbl.count-1] - pDbl[indexConstAccel]
            }
            
            //Answer for acceleration question for testing:
            println("CONST ACCEL IS \(constAccel)")
            
          
            
            //DECISION LOGIC HERE FOR WHAT QUESTION TO ASK...
            
            
            
            //Questions on calculating unknown quantities from push data
            //Set qstntype in call to 0 for accel calc, 1 for initial velocity calc
            
            if settingVar == 1 {
            
            calcQstnsVC = calcQstns(velinit: velinit, constAccel: constAccel, timeConstAccel: timeConstAccel, distConstAccel: distConstAccel, tolerance: tolerance,qstntype: 1)
            
            self.navigationController?.pushViewController(calcQstnsVC!, animated: true)
                
            } else {
                
                graphQstnsVC = graphQstns(timeArray: tDbl, accelArray: aDbl, velArray: vDbl, posArray: pDbl, qstntype: 0)
                
            self.navigationController?.pushViewController(graphQstnsVC!, animated: true)
                
            }
            
            
            
            
            
            
            
            /*
            //STUFF FOR PRINTING OUT DATA
            var vString:String = "\n".join(dblToStringRows(tDbl,BB: vDbl))
            //ExportToCSVVEL(self, data: vString)
            //Now concatenate into string
            var pString:String = "\n".join(dblToStringRows(tDbl,BB: pDbl))
            //ExportToCSVVEL(self, data: pString)
            */
            
            
            /*
            //add button for exporting accel data
            sendAccelButton.frame = CGRectMake(50, 225, 250, 125)
            sendAccelButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            sendAccelButton.setTitle("Send accel", forState: UIControlState.Normal)
            sendAccelButton.layer.cornerRadius = 20
            sendAccelButton.layer.borderWidth = 5
            sendAccelButton.layer.borderColor = UIColor.blackColor().CGColor
            sendAccelButton.titleLabel!.font =  UIFont(name: "Arial", size: 20)
            sendAccelButton.addTarget(self, action: "sendAccel:", forControlEvents: .TouchUpInside)
            self.view.addSubview(sendAccelButton)
            //add button for exporting velocity data
            sendVelButton.frame = CGRectMake(350, 225, 250, 125)
            sendVelButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            sendVelButton.setTitle("Send velocity", forState: UIControlState.Normal)
            sendVelButton.layer.cornerRadius = 20
            sendVelButton.layer.borderWidth = 5
            sendVelButton.layer.borderColor = UIColor.blackColor().CGColor
            sendVelButton.titleLabel!.font =  UIFont(name: "Arial", size: 20)
            sendVelButton.addTarget(self, action: "sendVel:", forControlEvents: .TouchUpInside)
            self.view.addSubview(sendVelButton)
            //add button for exporting position data
            sendPosButton.frame = CGRectMake(650, 225, 250, 125)
            sendPosButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
            sendPosButton.setTitle("Send position", forState: UIControlState.Normal)
            sendPosButton.layer.cornerRadius = 20
            sendPosButton.layer.borderWidth = 5
            sendPosButton.layer.borderColor = UIColor.blackColor().CGColor
            sendPosButton.titleLabel!.font =  UIFont(name: "Arial", size: 20)
            sendPosButton.addTarget(self, action: "sendPos:", forControlEvents: .TouchUpInside)
            self.view.addSubview(sendPosButton)
            */
            
            /*
            //Write down values of init vel, time and distance on screen
            var resultsText:UITextView = UITextView(frame: CGRect(x: 50, y: 50, width: 90.00, height: 10.00));
            resultsText.font = UIFont(name: "Arial", size: 60)
            resultsText.editable = false
            if (tDbl.count>0 && pDbl.count>0 && vDbl.count>0) {
                resultsText.text = "t = \(round(100*timeConstAccel)/100), v0 = \(round(100*velinit)/100), s = \(round(100*distConstAccel)/100), a = \(round(100*constAccel)/100)"
                self.view.addSubview(resultsText)
                fitToText(resultsText)
            } else {
                resultsText.text = "!!! Data collection did not start !!!"
                self.view.addSubview(resultsText)
                fitToText(resultsText)
            }
            */
            
            
        }

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

    
 
    
    override func viewDidAppear(animated: Bool) {
        
       
    }

    
    /*
    func sendAccel(sender:UIButton) {
        if (aDbl.count>0 && tDbl.count>0) {
            //Join up data into table structure suitable for CSV
            var alladata = "\n".join(dblToStringRows(tDbl,BB: aDbl))
            //Export data as CSV to email etc...
            //ExportToCSV(self, aDbl: finalaccel.aDbl, tDbl: finalaccel.tDbl)
            ExportToCSVVEL(self, data: alladata)
        }
    }
    
    func sendVel(sender:UIButton) {
        if (vDbl.count>0 && tDbl.count>0) {
            //Join up data into table structure suitable for CSV
            var allvdata = "\n".join(dblToStringRows(tDbl,BB: vDbl))
            //Export data as CSV to email etc...
            //ExportToCSV(self, aDbl: finalaccel.aDbl, tDbl: finalaccel.tDbl)
            ExportToCSVVEL(self, data: allvdata)
        }
    }
    
    func sendPos(sender:UIButton) {
        if (pDbl.count>0 && tDbl.count>0) {
            //Join up data into table structure suitable for CSV
            var allpdata = "\n".join(dblToStringRows(tDbl,BB: pDbl))
            //Export data as CSV to email etc...
            //ExportToCSV(self, aDbl: finalaccel.aDbl, tDbl: finalaccel.tDbl)
            ExportToCSVVEL(self, data: allpdata)
        }
    }
    */


    

    
    
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



