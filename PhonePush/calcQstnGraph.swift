//
//  calcQstnGraph.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 04/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class calcQstnGraph {
    //THIS IS CALLED TO GET DATA FOR A QSTN GRAPH
    var segmentList:[(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String)->([Double],[Double],String)] = []
    //Array for storing plotting values
    var yVals:[Double] = [0.0]
    var timeVals:[Double] = [0.0]
    var yLimit:Double = 0
    
    //Call this if you want a position-time question graph
    //totalTime: total time the graph lasts (whole x-axis)
    //yLimits: the maximum y-value to consider
    //timeRes: what time resolution to use when calculating points
    func getXGraph(totalTime:Double,yLimit:Double,timeRes:Double) -> ([Double],[Double]) {
        println("")
        println("")
        println("===========NEW RUN============")
        //Clear arrays
        segmentList = []
        //Array for storing plotting values
        yVals = [0.0]

        self.yLimit = yLimit
        
        //Split the timebase of the graph up into three equal segments
        var segTimes:[Int] = [0,0,0,0]
        segTimes[0] = 0
        segTimes[1] = Int(ceil(totalTime/3))
        segTimes[2] = Int(ceil(totalTime*2/3))
        segTimes[3] = Int(floor(totalTime))
        println(segTimes)
        
        //Array of functions to use in determining segments of graph
        //note: removed negLinear for distance time
        segmentList = [constVals,posLinear,accelVals]

        //Set start parameters that determines where first line starts and with
        //what velocity
        var yStart = 0.0
        var vStart = 0.0
        var lastCall:String = ""
        
        //Loop that exhaustively calls functions for calculating three 
        //line segments in random order.
        for ii in 0...2 {
            //Get random element of array
            var currentSegment = randomR(0...UInt32(segmentList.count-1))
            var currentFunction = segmentList[currentSegment]
            println("Trying for element \(ii) with function \(currentSegment)")
            //Remove the element that we used
            //Note: need to 'assign' to prevent error in calling function without args
            var temptemp = segmentList.removeAtIndex(currentSegment)
            //Add to the array of y values, the result of calling the current randomly 
            //chosen segment
            var segResult = currentFunction(tRes: timeRes, timeRange: [segTimes[ii],segTimes[ii+1]], yInit: yStart, vInit: vStart, data: yVals,lastfn: lastCall)
            yVals = yVals + segResult.0
            //Update the starting y-value for the next segment calculation
            yStart = segResult.1[0]
            vStart = segResult.1[1]
            println("new yStart: \(yStart), new vStart: \(vStart)")
            //Update the variable storing which previously called function was
            lastCall = segResult.2
            
        }

        println("")
        //Return time values and data points for all segments together
        return (timeVals,yVals)
    }
    
    
    //Calculate region of graph with constant value (i.e. 'flat line') between two times
    func constVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        
        println("RUNNING CONSTVALS")
        //Create an array that contains the same constant value (determined by start parameter)
        var constArray:[Double] = Array(count: Int(ceil(Double(timeRange[1]-timeRange[0])/tRes)), repeatedValue: yInit)
        //Fill up time array with corresponding times (note: is class variable)
        for var timeIndex = Double(timeRange[0]); timeIndex < Double(timeRange[1]);timeIndex+=tRes {
            timeVals.append(timeVals[timeVals.count-1]+tRes)
        }
        
        println("")
        //Return array of yValues and initial y and v data for next segment
        return (constArray,[yInit,0.0],"constVals")
    }
    
    //Calculate region of graph with positive velocity
    func posLinear(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        
        println("RUNNING POSLINEAR")
        //Array for storing values
        var posLinArray:[Double] = []
        //Velocity/gradient of current straight line segment
        var m:Int
        //If last had accel then match its final velocity, otherwise choose randomly
        if lastfn == "accelVals" || lastfn == "posLinearFromAccel" {
            m = Int(ceil(vInit))
        //Otherwise randomly choose a velocity/gradient of 1 or 2
        } else {
            m = randomR(1...2)
        }

        println("m is: \(m)")
        println("timeIndex start: \(Double(timeRange[0])), timeIndex stop: \(Double(timeRange[1])), timeStep: \(tRes)")
        //Calculate y values between time range with given time resolution using y=mx+c
        for var timeIndex = Double(timeRange[0])+tRes; timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            //Get the time spent *in this segment* (need this for y=mx+c calc)
            var velTime = timeIndex-Double(timeRange[0])
            //Use y=mx+c equation to add new distance on to yInit and append to array
            posLinArray.append(yInit+Double(m)*velTime)
            //Fill up time array with corresponding times (note: is class variable)
            timeVals.append(timeVals[timeVals.count-1]+tRes)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in posLinear function")
                break
            }
        }
        println("")
        //Return array of yValues and initial y and v data for next segment
        return (posLinArray,[posLinArray[posLinArray.count-1],Double(m)],"posLinear")
    }
    
    //Calculate region of graph with negative velocity
    func negLinear(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        
        println("RUNNING NEGLINEAR")
        //First do a check to see whether smallest gradient possible (-1) will take us
        //negative if so, then call posLinear instead.
        //REMOVE THIS FOR DISPLACEMENT
        if ((yInit-Double(timeRange[1]-timeRange[0])) < -0.5) {
            return posLinear(tRes,timeRange: timeRange,yInit: yInit, vInit: vInit, data: data,lastfn: "posLinearFromAccel")
        } else {
        
            //Array for storing values
            var negLinArray:[Double] = []
            //Choose random velocity for gradient of line will create (nb: may need to constrain
            //this to ensure y-axes are usable)
            var m = -randomR(1...2)
            //Double check that current choice of value of m won't take us negative
            if (yInit+Double(m*(timeRange[1]-timeRange[0])) < -0.5) {
                m = -1
            }
            
            //Calculate intercept from this gradient and starting time/yparam
            //var c = yInit-Double(m*timeRange[0])
            
            println("m is: \(m)")
            println("timeIndex start: \(Double(timeRange[0])), timeIndex stop: \(Double(timeRange[1])), timeStep: \(tRes)")
            
            //Calculate y values between time range with given time resolution using y=mx+c
            for var timeIndex = Double(timeRange[0])+tRes; timeIndex < Double(timeRange[1]); timeIndex+=tRes {
                //Get the time spent *in this segment* (need this for y=mx+c calc)
                var velTime = timeIndex-Double(timeRange[0])
                //Use y=mx+c equation to add new distance on to yInit and append to array
                negLinArray.append(yInit + Double(m)*velTime)
                //Fill up time array with corresponding times (note: is class variable)
                timeVals.append(timeVals[timeVals.count-1]+tRes)
                //Break out if we've been going for too long as a precaution
                if timeIndex > 1000 {
                    println("Something went wrong, looping forever (>1000) in posLinear function")
                    break
                }
            }
            
            println("")
            //Return array of yValues and initial y and v data for next segment
            return (negLinArray,[negLinArray[negLinArray.count-1],Double(m)],"negLinear")
                
        }
    }
    
    
    //Calculate region of graph with acceleration (pos or neg depending on yvalue it
    //starts at)
    func accelVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        
        println("RUNNING ACCELVALS")
        var a:Double = 0
        var vFinal:Double = 0
        var yFinal:Double = 0
        var flipVar = 1.0
        var accelValsArray:[Double] = []
        
        //Decide what final velocity to accelerate to based on velocity beforehand
        if vInit >= 1{
            if vInit == 1.0 {
                vFinal = 2.0
            } else {
                vFinal = 0.0
            }
        //This wouldn't be called for a distance-time graph as no negative veloicties
        } else if vInit <= -1 {
            vFinal = Double(randomR(0...2))
        //if vInit near 0 either acc/decellerate to final velocity of +1
        } else {
            vFinal = 1.0
        }
        
        //Look at which tri-section of y-axis starting position is for this segment to
        //decide where to end up.
        var triSecHeight = self.yLimit/3
        //Set final destination to be a different tri-section
        //Bottom tri-section
        if yInit <= triSecHeight {
            //Choose random position in middle tri-section
            yFinal = triSecHeight+(Double(randomR(0...100))/100.0)*(triSecHeight)
        //Middle tri-section
        } else if (yInit > triSecHeight && yInit <= 2*triSecHeight) {
            //Choose random position in either top or bottom trisection
            yFinal = (Double(randomR(0...100))/100.0)*(triSecHeight)+Double(randomR(0...1))*(2*triSecHeight)
        //Top tri-section
        } else {
            //Choose random position in middle tri-section
            yFinal = triSecHeight+(Double(randomR(0...100))/100.0)*(triSecHeight)
        }
        
        //Calc accel to get to finalY from yInit and vInit to vFinal using a=dv/dt
        a = (vFinal-vInit)/Double(timeRange[1]-timeRange[0])
        
        //Check this doesn't take us negative by testing extreme value for being positive
        //Make sure we don't divide by zero!
        if a != 0 {
            if (yInit-0.5*(pow(vInit,2.0)/a)) < 0 {
                //Flip accel segment plot if we would be going negative.
                flipVar = -1.0
                println("----------PREDICT IT WILL BE NEGATIVE---------")
            }
        }
        
        println("a is: \(a), vInit is: \(vInit), vFinal is: \(vFinal), yFinal is: \(yFinal)")
        println("timeIndex start: \(Double(timeRange[0])), timeIndex stop: \(Double(timeRange[1])), timeStep: \(tRes)")
        
        //Calculate y values between time range with given time resolution using suvat
        //equation with vFinal, vInit and accel
        for var timeIndex = Double(timeRange[0])+tRes; timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            //Get the time spent *in this segment* (need this for suvat calc)
            var accelTime = timeIndex-Double(timeRange[0])
            //Calculate new position at this time using suvat
            //(note that we add onto whatever initial y was for this segment)
            var currentPos = yInit + vInit*accelTime+(0.5*a*pow(accelTime,2.0))
            accelValsArray.append(flipVar*currentPos)
            //Fill up time array with corresponding times (nb: timeVals is class variable)
            timeVals.append(timeVals[timeVals.count-1]+tRes)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in accelVals function")
                break
            }
        }
        println("")
        //Return array of yValues and initial y and v data for next segment
        return (accelValsArray,[accelValsArray[accelValsArray.count-1],vFinal],"accelVals")
    }
    
    //Generates random integer in given range
    func randomR(range: Range<UInt32>) -> Int {
        return Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex))
    }
    
}
