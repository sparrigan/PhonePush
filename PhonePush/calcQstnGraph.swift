//
//  calcQstnGraph.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 04/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class calcQstnGraph {
    //Define class variables
    var segmentList:[(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String)->([Double],[Double],String)] = []
    var yLimit:Double = 0
    //Array for storing x/y values to be plotted
    var yVals:[Double] = [0.0]
    var timeVals:[Double] = [0.0]
    var tTime = 1.0
    
    //Get *distance*-time question graph
    //totalTime: total time the graph lasts (whole x-axis)
    //yLimit: the maximum y-value to consider
    //timeRes: what time resolution to use when calculating points
    //tTime: Length of time 'smooth' accel transitions between segments is given
    //RETURNS x and y data in arrays
    func getXGraph(totalTime:Double,yLimit:Double,timeRes:Double,transTime:Double = 1.0) -> ([Double],[Double]) {
        println("")
        println("")
        println("===========NEW RUN============")
        //Clear arrays
        segmentList = []
        yVals = [0.0]
        self.yLimit = yLimit
        self.tTime = transTime
        //Make transition time divisable by tRes
        self.tTime = ceil(self.tTime/timeRes) * timeRes
        //If requested transition time is larger than the size of segments, reset it to 1.0
        if self.tTime >= totalTime/3 {
            self.tTime = 1.0
        }
        //Split the timebase of the graph up into three equal segments
        var segTimes:[Int] = [0,0,0,0]
        segTimes[0] = 0
        segTimes[1] = Int(ceil(totalTime/3))
        segTimes[2] = Int(ceil(totalTime*2/3))
        segTimes[3] = Int(floor(totalTime))
        println(segTimes)
        //Array of functions to use in determining segment shapes (chosen from randomly)
        segmentList = [constVals,posLinear,accelVals]
        //Set start parameters that determines where first line starts and with
        //what velocity
        var yStart = 0.0
        var vStart = 0.0
        var lastCall:String = ""
        //Loop that calculates each segments plot data (randomly chooses segment types)
        for ii in 0...2 {
            //Get random element of array shape functions
            var currentSegment = randomR(0...UInt32(segmentList.count-1))
            var currentFunction = segmentList[currentSegment]
            println("Trying for element \(ii) with function \(currentSegment)")
            //Remove the element that we used so does not get used again in this graph
            //Note: need to 'assign' to prevent error in calling function without args
            var temptemp = segmentList.removeAtIndex(currentSegment)
            //Add to the array of y values, the result of calling the current randomly 
            //chosen segment
            var segResult = currentFunction(tRes: timeRes, timeRange: [segTimes[ii],segTimes[ii+1]], yInit: yStart, vInit: vStart, data: yVals,lastfn: lastCall)
            yVals = yVals + segResult.0
            //Update the starting y-value and velocity for next segment calculation
            yStart = segResult.1[0]
            vStart = segResult.1[1]
            println("new yStart: \(yStart), new vStart: \(vStart)")
            //Update variable storing namne of previously called function
            lastCall = segResult.2
            
        }
        
        //Scale the set of yVals to fit within the yLimit specified
        
        //Return time values and data points for all three segments combined
        return (timeVals,scaleYValsDT(yVals,yLimit: yLimit))
    }
    
    
    //Function calculates constant (i.e. 'flat line') segment between two times
    func constVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        //Local variables
        var yInitLocal = yInit
        var startTime:Double = 0.0
        var tArray:[Double] = []
        //Check whether need transition and call transition function if so
        if (lastfn == "posLinear" || (lastfn == "accelVals" && vInit > 0)) && tTime > 0 {
            //Call transition function with relevant data
            tArray = transition(vInit, vFinal: 0.0, startTime: Double(timeRange[0]), transitTime: tTime, tRes: tRes, yInit: yInit)
            //Set starting time of current run to be tTime seconds later
            startTime = Double(timeRange[0])+tTime
            //Update new yInit position at end of transition
            yInitLocal = tArray[tArray.count-1]
        } else {
            startTime = Double(timeRange[0])
        }
        
        println("RUNNING CONSTVALS")
        //Array with constant y-values for this segment (determined by yInit)
        var constArray:[Double] = Array(count: Int(ceil((Double(timeRange[1])-startTime)/tRes)), repeatedValue: yInitLocal)
        //Fill up time array with corresponding times (note: timeVals is class variable)
        for var timeIndex = startTime+tRes; timeIndex < Double(timeRange[1]);timeIndex+=tRes {
            timeVals.append(timeVals[timeVals.count-1]+tRes)
        }
        //Add on transition to data (if it was undertaken)
        if tArray.count != 0 {
            constArray = tArray + constArray
        }
        
        println("")
        //Return array of yValues and initial y and v data for next segment
        return (constArray,[yInitLocal,0.0],"constVals")
    }
    
    //Function calculates const positive vel (i.e. 'linear') segment between two times
    func posLinear(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        //Local variables
        var yInitLocal = yInit
        var startTime:Double = 0.0
        var tArray:[Double] = []
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

        //Check whether need transition and call transition function if so
        if (lastfn == "constVals" || lastfn == "") && tTime > 0 {
            println("CALLING TRANSITION FUNCTION")
            //Call transition function with relevant data
            tArray = transition(vInit, vFinal: Double(m), startTime: Double(timeRange[0]), transitTime: tTime, tRes: tRes, yInit: yInit)
            //Set starting time of current run to be tTime seconds later
            startTime = Double(timeRange[0])+tTime
            //Update new yInit position at end of transition
            yInitLocal = tArray[tArray.count-1]
        } else {
            startTime = Double(timeRange[0])
        }
        
        println("m is: \(m)")
        println("timeIndex start: \(startTime), timeIndex stop: \(Double(timeRange[1])), timeStep: \(tRes)")
        //Calculate y values between time range with given time resolution using y=mx+c
        for var timeIndex = startTime+tRes; timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            //Get the time spent *in this segment* (need this for y=mx+c calc)
            var velTime = timeIndex-startTime
            //Use y=mx+c equation to add new distance on to yInit and append to array
            posLinArray.append(yInitLocal+Double(m)*velTime)
            //Fill up time array with corresponding times (note: is class variable)
            timeVals.append(timeVals[timeVals.count-1]+tRes)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in posLinear function")
                break
            }
        }
        //Add on transition if it was undertaken
        if tArray.count != 0 {
            posLinArray = tArray + posLinArray
        }
        
        println("")
        //Return array of yValues and initial y and v data for next segment
        return (posLinArray,[posLinArray[posLinArray.count-1],Double(m)],"posLinear")
    }

    /*
    
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
    
    */
    
    //Function calculates acceleration (i.e. 'curved') segment between two times
    func accelVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double],lastfn:String) -> ([Double],[Double],String){
        //Local variables
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
    
    
    //Function called to insert small acceleration 'smooth transitions' when needed
    func transition(vInit: Double, vFinal:Double, startTime: Double, transitTime: Double, tRes: Double, yInit: Double) -> [Double] {
        //Determine what acceleration we need to get desired transition
        var a = (vFinal-vInit)/Double(transitTime)
        var transitArray:[Double] = []
        //Build transition data
        for var timeIndex = startTime+tRes; timeIndex < startTime+transitTime; timeIndex+=tRes {
            var accelTime = timeIndex-startTime
            var currentPos = yInit + vInit*accelTime+(0.5*a*pow(accelTime,2.0))
            transitArray.append(currentPos)
            //Update time values used by transition
            timeVals.append(timeVals[timeVals.count-1]+tRes)
        }
        //Return transition data
        return transitArray
    }
    
    //Function for scaling graph as desired if Distance-Time plot (easier to find max val)
    func scaleYValsDT(yVals: [Double], yLimit: Double) -> [Double] {
        //Find scaling factor (max value of graph is last datapoint since 
        //*distance*-time graph)
        var scaleFactor = yLimit/yVals[yVals.count - 1]
        
        var yValsScaled:[Double] = []
        
        for ii in 0...yVals.count-1 {
            yValsScaled.append(yVals[ii]*scaleFactor)
        }
        
        return yValsScaled
        
    }
    
    
    //Generates random integer in given range
    func randomR(range: Range<UInt32>) -> Int {
        return Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex))
    }
    
}
