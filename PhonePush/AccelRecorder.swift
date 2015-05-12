//
//  AccelRecorder.swift
//  AccelTest2
//
//  Created by Nicholas Harrigan on 19/01/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

//Class that records data from accelerometer

//TODO:

//ACCELERATION READINGS DON'T START AT ZERO.

//NEED TO MAKE SURE THAT DOESN'T DETECT TOUCH AT END WHEN TURNING OFF.


import Foundation

import UIKit

import CoreMotion

//Protocol for delegate that will receive information from calibration
protocol accelRecorderDelegate: class {
    func getCalibration(accC: CGPoint, aCount: Double)
    var calibcheck:Int {get set}
    func endOfCalib()
}


class accelRecorder: NSObject {
    
    //Class variables
    var motionManager = CMMotionManager()
    var integrate:integrator = integrator()
    var accelsRaw: [Double] = []
    var firstTime = 0.0
    var posdir = CGPoint(x: 0,y: 0)
    var countav = 0
    var textField: UITextField = UITextField(frame: CGRectMake(0,0,0,0))
    //Delegate for sending calilbration data to (need to make a weak reference to avoid
    //a strong reference cycle)
    weak var delegate: accelRecorderDelegate?
    //Calibration counting variables
    var accelCalib: CGPoint = CGPoint(x:0,y:0)
    var accelCalibTotal:Double = 0.0
    var countCalib: Double = 0
    var bgAccel: CGPoint = CGPoint(x:0,y:0)
    var accelsDbl:[Double] = []
    var timesDbl:[Double] = []
    var velDbl: [Double] = []
    var posDbl: [Double] = []
    
    var startvar = 0
    var countzeros = 0
    var lastval = 0.0
    var firstnegaccel = 0
    var startConstAccel = 0.0

    /*
    //Get textfield from viewcontroller for displaying accel values
    init() {
        
        textField = tb
        //integrate = integrator()
    }
*/
    //This is called when memory location for instance is deallocated
    deinit {
        //println("accelRecorder has been DEINITIALIZED")
    }
    
    
    //Method to start recording (under restrictions needed for suvat phonepush activities)
    func startRec() {
        
        //Initialise data counting variables for new record
        
        self.accelsRaw = []
        self.firstTime = 0
        posdir.x=0
        posdir.y=0
        countav=0
        accelsDbl = []
        timesDbl = []
        
        //START RECORDING
        if motionManager.accelerometerAvailable == true {
            //motionManager.accelerometerUpdateInterval = 0.00001
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                data, error in
                var vecsign = 1.0
                //Display current acceleration magnitude in x-y plane
                //self.textField.text = String(format:"%f", sqrt(pow(data.acceleration.x,2.0)+pow(data.acceleration.y,2.0)))
                
                //println(vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0)))
                
                //Only start recording data when have a significant change (>0.01g)
                var acc = self.accelsRaw.count
                if (acc > 1) && (abs(self.accelsRaw[acc-1]-self.accelsRaw[acc-2])>0.01) {
                    
                    self.startvar = 1
                    //Now recording, set 'time' to zero at first time we record
                    if self.firstTime == 0 {
                        self.firstTime = data.timestamp
                    }
                    //Take average of first five acceleration measurements in x-y plane
                    //to find a definition for 'positive direction' whilst still recording
                    if self.countav<=5 {
                        self.posdir.x += CGFloat(data.acceleration.x-Double(self.accelCalib.x))
                        self.posdir.y += CGFloat(data.acceleration.y-Double(self.accelCalib.y))
                        ++self.countav
                    } else if self.countav == 5 {
                        self.posdir.x = self.posdir.x/5
                        self.posdir.y = self.posdir.y/5
                        vecsign = Double(self.dotProdSign(CGPoint(x:data.acceleration.x-Double(self.accelCalib.x),y: data.acceleration.y-Double(self.accelCalib.y)),vec2: self.posdir))
                        ++self.countav
                    } else {
                        //Determine sign of acceleration relative to initial push using inner product with average of first five acceleration vectors
                        vecsign = Double(self.dotProdSign(CGPoint(x:data.acceleration.x-Double(self.accelCalib.x),y: data.acceleration.y-Double(self.accelCalib.y)),vec2: self.posdir))
                    }
                    //Record time and acceleration data straight in CVS ready strings
                    //self.accels += [",".join([String(format:"%f",data.timestamp - self.firstTime),String(format:"%f",vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0)))])]
                    
                    self.accelsDbl += [vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))]
                    self.timesDbl += [data.timestamp - self.firstTime]
                    
                    
                    //Check whether acceleration has gone negative yet:
                    
                    if self.accelsDbl[self.accelsDbl.count-1] < 0 && self.firstnegaccel == 0 {
                        
                        self.firstnegaccel = 1
                        
                        self.startConstAccel = self.timesDbl[self.timesDbl.count-1]
                        
                        //println("THE ACCEL IS CONST FROM TIME \(self.timesDbl[self.timesDbl.count-1])")
                    }
                    
                    
                    //!!!
                    
                    
                    //PROBLEM: WILL NOT COUNT UP AS THE LOOP THIS IS IN ONLY RUNS WHEN THERE IS A SIGNIFICANT CHANGE BETWEEN CURRENT AND PREIVOUS VALUES
                    //ALSO - ANOTHER PROBLEM IS THAT WHERE THE IPAD ENDS UP MIGHT BE SLIGHTLY MORE INCLINED, AND SO THE BASE-READING MAY NOT REFLECT THE INITIAL CALIBRATION (SO HARD TO CHOOSE A GOOD EPSILON). RECALIBRATE? HOW TO DISTINGUISH BETWEEN CASES OF CONSTANT NONZERO ACCELERATION AND WHEN STILL?
                    
                    //HERE PUT A CONDITIONAL STATEMENT THAT CHECKS WHETHER ACCEL DATA IS WITHIN
                    //SOME EPSILON OF ORIGINAL STATIONARY VALUE FOR MORE THAN A CERTAIN NUMBER OF
                    //TIMESTEPS AND IF SO THEN STOP RECORDING AND DELETE THOSE LAST XX RECORDED VALUES.
                    
                    
                    
                    //!!!!
                    
                    
   
                    
                    
                    
                    //update lastval for next run
                    self.lastval = vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))
                    
                }
                //This seperate recording of raw accelerations (as Double) used to determine when to start recording to get correct vecsign (when have significant change)
                self.accelsRaw += [sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))]
                
                
                //Start checking whether to stop or not when get more than 5 'zero' readings
                //Note that only start this check once above loop has been initiated and startvar
                //is not zero
                //conditional to check whether the last current value is close enough to zero
                //if so then increment countervar.
                //if not then reset countervar to zero.
                if (self.startvar != 0 && abs(vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))) < 0.05) {
                    
                    ++self.countzeros
                    //println("Increment: val = \(self.countzeros)")
                    
                    
                } else {
                    self.countzeros == 0
                    //println("Reset countzeros")
                    
                }
                
                //conitional for checking countervar to see whether have accumulated enough near to zero
                if self.countzeros == 5 {
                    //DELETE LAST 4 ENTRIES HERE!!!!
                    self.stopRec()
                    //println("Value is \(self.countzeros), STOPPED RECORDING")
                }
                
                
            })
        }
        //END OF RECORDING
    }
    
    
    //TODO:
    //1. SUBTRACT Z COMPONENT INTO X AND Y PLANE BASED ON CALLIBRATION
    //2. ENSURE THAT GET EXACT CANCELLING OUT OF VELOCITIES WHEN START AND STOP (SEE 
    //PAPER)
    //3. SMOOTH OUT READINGS WITH ROLLING AVERAGE
    
    //Method to start recording indiscriminately
    func startRecAll() {
        
        //Initialise data counting variables for new record
        
        self.accelsRaw = []
        self.firstTime = 0
        posdir.x=0
        posdir.y=0
        countav=0
        accelsDbl = []
        timesDbl = []
        
        //START RECORDING
        if motionManager.accelerometerAvailable == true {
            //motionManager.accelerometerUpdateInterval = 0.00001
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                data, error in
                var vecsign = 1.0
                //Display current acceleration magnitude in x-y plane
                //self.textField.text = String(format:"%f", sqrt(pow(data.acceleration.x,2.0)+pow(data.acceleration.y,2.0)))
               
                //Current accel value to compare: 
                var currentAccel = abs(9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0)))
                var lastAccel:Double
                
                if self.accelsDbl.count != 0 {
                    lastAccel = Double(self.accelsDbl[self.accelsDbl.count-1])
                } else {
                    lastAccel = 0.0
                }
                
                //Now recording, set 'time' to zero at first time we record
                if self.firstTime == 0 {
                    self.firstTime = data.timestamp
                }
                
                //Only consider a value if the change from last value is bigger than twice the calibration average ('background') value
                if ((currentAccel - abs(lastAccel)) >= self.accelCalibTotal) {
                
                    self.startvar = 1
                   
                    
                    //Take average of first five acceleration measurements in x-y plane
                    //to find a definition for 'positive direction' whilst still recording
                    if self.countav<=5 {
                        self.posdir.x += CGFloat(data.acceleration.x-Double(self.accelCalib.x))
                        self.posdir.y += CGFloat(data.acceleration.y-Double(self.accelCalib.y))
                        ++self.countav
                    } else if self.countav == 5 {
                        self.posdir.x = self.posdir.x/5
                        self.posdir.y = self.posdir.y/5
                        vecsign = Double(self.dotProdSign(CGPoint(x:data.acceleration.x-Double(self.accelCalib.x),y: data.acceleration.y-Double(self.accelCalib.y)),vec2: self.posdir))
                        ++self.countav
                    } else {
                        //Determine sign of acceleration relative to initial push using inner product with average of first five acceleration vectors
                        vecsign = Double(self.dotProdSign(CGPoint(x:data.acceleration.x-Double(self.accelCalib.x),y: data.acceleration.y-Double(self.accelCalib.y)),vec2: self.posdir))
                    }

  
                    self.accelsDbl += [vecsign * 9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))]

//                    self.accelsDbl += [vecsign*9.81*sqrt(pow(data.acceleration.x-Double(self.accelCalib.x),2.0)+pow(data.acceleration.y-Double(self.accelCalib.y),2.0))]
                
                } else {
                    self.accelsDbl += [0.0]
                }
                //Update time value regardless of whether we deemed change large enough to
                //record (i.e. outside above conditional).
                self.timesDbl += [data.timestamp - self.firstTime]
                //println(self.timesDbl)
                
            })
        }
        //END OF RECORDING
    }
    
    
    
    //This function is passed a coreplot plot and updates the plot with accelerometer data
    //gP: the graphPlotter instance that are using to manage our plot
    //plot: Array of three plots (within *SAME* gP) that we wish to send data to for 
    //x,y,z accelerometer values
    func updatePlot(gP:graphPlotter, plot: [CPTScatterPlot]) {
        
        //get accel data
        //START RECORDING
        if motionManager.accelerometerAvailable == true {
            
            
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                data, error in
                
                if self.firstTime == 0 {
                    self.firstTime = data.timestamp
                }
                
                //USE THE ACELLEROMETERUPDATEINTERVAL INSTEAD OF AN NSTIMER (AS 
                //SETUP NSTIMERS EVERY ACCELUPDATEINTERVAL ANYWAY!!!
                //run timer that updates function on call
                
                var time = data.timestamp - self.firstTime
                
                gP.plotDic[plot[0]]!.0.append(time)
                gP.plotDic[plot[0]]!.1.append(data.acceleration.x)
                
                gP.plotDic[plot[1]]!.0.append(time)
                gP.plotDic[plot[1]]!.1.append(data.acceleration.y)
               
                gP.plotDic[plot[2]]!.0.append(time)
                gP.plotDic[plot[2]]!.1.append(data.acceleration.z)
                
                plot[0].insertDataAtIndex(UInt(gP.plotDic[plot[0]]!.0.count - 1), numberOfRecords: 1)
                plot[1].insertDataAtIndex(UInt(gP.plotDic[plot[1]]!.0.count - 1), numberOfRecords: 1)
                plot[2].insertDataAtIndex(UInt(gP.plotDic[plot[2]]!.0.count - 1), numberOfRecords: 1)
                
                if time > 30.0 {
                    self.motionManager.stopAccelerometerUpdates()
                }
                
            })
        }
        
    }
    
    
    //How to use NSTimer with userInfo to pass parameters :)
    /*
    NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateCall:", userInfo: [gP,(data.timestamp-self.firstTime),data.acceleration.x,plot], repeats: false)
    
    func updateCall(timer:NSTimer) {
        
        println("updated")
        var arr = timer.userInfo as! [AnyObject]
        
        var gP = arr[0] as! graphPlotter
        var time = arr[1] as! Double
        var accel = arr[2] as! Double
        var plot = arr[3] as! CPTScatterPlot

        gP.plotDic[plot]!.0.append(time)
        gP.plotDic[plot]!.1.append(accel)
        
        //gP.xArray.append(time)
        //gP.yArray.append(accel)
        
        plot.insertDataAtIndex(UInt(gP.plotDic[plot]!.0.count - 1), numberOfRecords: 1)
        
        //dispatch_async(dispatch_get_main_queue()) {
        
        ////plot.reloadData()
            
        //}
            
            
        //Remove timer if we go beyond 30 seconds
        if time > 30.0 {
            timer.invalidate()
        }
        
        //println("Updated with \(time) and \(accel)")
        //println("Size of x arrays in graph is \(gP.xArray.count)")
        //println("Size of y arrays in graph is \(gP.yArray.count)")

    }
*/
    
    //Method that stops recording, finds vel and pos and returns the array of strings for CSV
    func stopRec() -> (aDbl: [Double], tDbl: [Double],startConstAccel: Double, vDbl: [Double], pDbl: [Double])? {
        motionManager.stopAccelerometerUpdates()
        //Integrate accel data to get velocity
        if accelsDbl.count > 10 {
            velDbl = []
            //First integrate acceleration data
            velDbl = integrate.getInt(accelsDbl, timeVals: timesDbl)
            //Now concatenate into string
       
        //Integrate velocity data to get position data
        if velDbl.count > 0 {
            posDbl = []
            //First integrate velocity data
            posDbl = integrate.getInt(velDbl, timeVals: timesDbl)
        } else {
            //println("No vel to send for pos")
        }
        
        return (self.accelsDbl, self.timesDbl, self.startConstAccel, self.velDbl, self.posDbl)
    
        } else {
            return nil
        }
    
    }
    
    //Method for calibrating accelerometer (timer calls finishcalibrate, that returns to delegate)
    func calibrate() {
        //println("Yay")
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "finishcalibrate", userInfo: nil, repeats: false)
        self.accelCalib = CGPoint(x:0,y:0)
        self.countCalib = 0
        if motionManager.accelerometerAvailable == true {
            motionManager.accelerometerUpdateInterval = 0.00001
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:{
                data, error in
                self.accelCalib.x += CGFloat(data.acceleration.x)
                self.accelCalib.y += CGFloat(data.acceleration.y)
                ++self.countCalib
            })
        }
    }
    
    func finishcalibrate() {
        println("finish calibration")
        motionManager.stopAccelerometerUpdates()
        delegate?.getCalibration(accelCalib,aCount: countCalib)
        delegate?.calibcheck = 0
        accelCalib.x = accelCalib.x/CGFloat(countCalib)
        accelCalib.y = accelCalib.y/CGFloat(countCalib)
        accelCalibTotal = 9.81*sqrt(pow(Double(accelCalib.x),2.0)+pow(Double(accelCalib.y),2.0))
        //Call function in vc that removes calibrate button and replaces with start button etc
        delegate?.endOfCalib()
    }
    
    
    
    //Dot product between two CGPoint vectors
    func dotProd(vec1: CGPoint, vec2: CGPoint) -> CGFloat {
        return vec1.x * vec2.x + vec1.y * vec2.y
    }
    
    //Get sign of a dot product of two CGPoint vectors (dependent on dotProd)
    func dotProdSign(vec1: CGPoint, vec2: CGPoint) -> CGFloat {
        var tempv = dotProd(vec1, vec2: vec2)
        return tempv/abs(tempv)
    }
    
    //Return Norm of a CGPoint vector
    func normVal(vec: CGPoint) -> CGFloat {
        return sqrt(pow(vec.x,2.0)+pow(vec.y,2.0))
    }
    
    //Normalise a CGPoint vector
    
    func normVec(vec: CGPoint) -> CGPoint {
        
        var norm = sqrt(pow(vec.x,2.0) + pow(vec.y,2.0))
        
        return CGPoint(x: vec.x/norm, y: vec.y/norm)
        
    }
    
}
