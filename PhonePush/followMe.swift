//
//  followMe.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 04/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit


class followMe: UIViewController, accelRecorderDelegate  {
    
    var timeOfPlot:Double = 30.0
    var qstnGraph:calcQstnGraph = calcQstnGraph()
    var graph1:graphPlotter = graphPlotter()
    var gD:UIView = UIView()
    let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let button2   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    //Recorder instance
    var aRec:accelRecorder = accelRecorder()//tb: UITextField(frame: CGRectMake(0,0,0,0)))
    var calibcheck:Int = 0
    //THIS WILL BE THE VC FOR MANAGING THE RUNNING OF THIS ACTIVITY
    var tb = UITextField(frame: CGRect(x: 400, y: 400, width: 200, height: 40))
    //For recorder data
    var aDbl:[Double] = []
    var vDbl:[Double] = []
    var tDbl:[Double] = []
    var pDbl: [Double] = []
    
    //Called when memory for instance is deallocated
    deinit {
        //aRec.delegate = nil
        //println("followMe has been DEINITIALIZED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        aRec = accelRecorder()//tb: tb)
        aRec.delegate = self
        
        var lala = qstnGraph.getXGraph(timeOfPlot, yLimit: 10.0, timeRes: 0.2)
        
        var timeArray = lala.0
        //var timeArray:[Double] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        var accelArray = lala.1
        //var accelArray:[Double] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
        
        graph1 = graphPlotter(vSize: self.view.frame, xArray: timeArray, yArray: accelArray)
        graph1.loadgraph()
        
        gD = graph1.hostView as UIView
        
        self.view.addSubview(graph1)
        
        //Button for retrying for debug
        
        button.frame = CGRectMake(50, 100, 200, 100)
        button.backgroundColor = UIColor(red: 127.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button.setTitle("Reload", forState: UIControlState.Normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.titleLabel!.font =  UIFont(name: "Arial", size: 30)
        button.addTarget(self, action: "retry:", forControlEvents: .TouchUpInside)
        
        button2.frame = CGRectMake(300, 100, 200, 100)
        button2.backgroundColor = UIColor(red: 127.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button2.setTitle("Record", forState: UIControlState.Normal)
        button2.layer.cornerRadius = 20
        button2.layer.borderWidth = 5
        button2.layer.borderColor = UIColor.blackColor().CGColor
        button2.titleLabel!.font =  UIFont(name: "Arial", size: 30)
        button2.addTarget(self, action: "record:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(button)
        self.view.addSubview(button2)
        
    }
    
    
    func retry(sender: UIButton) {
        if let navi = self.navigationController {
            var VCstack = navi.viewControllers
            //Remove top VC root is at 0, top is at count
            
            println("Stack on navigation controller: \(VCstack)")
            
            VCstack.removeLast()
            var restartGraph: followMe = followMe()
            //Add nextVC to top of stack
            VCstack.append(restartGraph)
            //Animate transition from old stack to newly formed one
            navi.setViewControllers(VCstack, animated: false)
        }

    }
    
    
    func record(sender:UIButton) {
        aRec.calibrate()

    }
    
    func endOfCalib() {
            aRec.startRecAll()
        //!!!Replace '5' with timeOfPlot!!!
            NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "finishRecording", userInfo: nil, repeats: false)
    }
    
    func finishRecording() {
        
        
        if let finalaccel = aRec.stopRec() {
            
            aDbl = finalaccel.aDbl
            tDbl = finalaccel.tDbl
            vDbl = finalaccel.vDbl
            pDbl = finalaccel.pDbl
        }
    
        println("FINISHED")
        println("tDbl: \(tDbl)")
        println("")
        println("tDbl: \(aDbl)")
        println("")
        println("pDbl: \(pDbl)")
        
        
        graph1.addGraph(tDbl, yVals: pDbl)
        
    }
    
    
    func getCalibration(acC: CGPoint, aCount: Double) {
        //For debugging, AccelRecorder calls this function with calib data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("******************************")
        println("ARRRRRRR!!! MEMORY WARNING")
        println("******************************")
    }
    
    
}
