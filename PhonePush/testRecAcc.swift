//
//  testRecAcc.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 12/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import Foundation

import UIKit


class testRecAcc: UIViewController, accelRecorderDelegate  {

    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var timeOfPlot:Double = 30.0
    let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let button2   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    //Recorder instance
    var aRec:accelRecorder = accelRecorder()//tb: UITextField(frame: CGRectMake(0,0,0,0)))
    var calibcheck:Int = 0
    //THIS WILL BE THE VC FOR MANAGING THE RUNNING OF THIS ACTIVITY
    //For recorder data
    var aDbl:[Double] = []
    var vDbl:[Double] = []
    var tDbl:[Double] = []
    var pDbl: [Double] = []
    var graphA = graphPlotter(vSize: CGRectMake(10, 300, 800, 300), xArray: [0.0,0.1,30.0], yArray: [-1.1,1.1,0.0])
    var plotX: CPTScatterPlot?
    var plotY: CPTScatterPlot?
    var plotZ: CPTScatterPlot?
    //Called when memory for instance is deallocated
    deinit {
        //aRec.delegate = nil
        //println("followMe has been DEINITIALIZED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        //Setup graph
        plotX = graphA.loadgraph()
        plotY = graphA.addGraph([0.0,1.0], yVals: [0.0,1.0])
        plotZ = graphA.addGraph([0.0,1.0], yVals: [0.0,1.1], col: CPTColor.blueColor())
        self.view.addSubview(graphA)
        aRec = accelRecorder()//tb: tb)
        aRec.delegate = self
        
        
        //Button for retrying for debug
        
        button.frame = CGRectMake(50, 100, 200, 100)
        button.backgroundColor = UIColor(red: 127.0/255.0, green: 220.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        button.setTitle("Stop", forState: UIControlState.Normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.titleLabel!.font =  UIFont(name: "Arial", size: 30)
        button.addTarget(self, action: "stop:", forControlEvents: .TouchUpInside)
        
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
    
    
    func stop(sender: UIButton) {
        aRec.motionManager.stopAccelerometerUpdates()
        
    }
    
    
    func record(sender:UIButton) {
        aRec.updatePlot(graphA, plot: [plotX!,plotY!,plotZ!])
    }
    
    func endOfCalib() {
    
    }
    
    func finishRecording() {
        
    
        
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