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
    var segmentList:[(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double])->([Double],[Double])] = []
    //Array for storing plotting values
    var yVals:[Double] = [0.0]
    
    var yLimit:Double = 0
    
    //Call this if you want a position-time question graph
    //totalTime: total time the graph lasts (whole x-axis)
    //yLimits: the maximum y-value to consider
    //timeRes: what time resolution to use when calculating points
    func getXGraph(totalTime:Double,yLimit:Double,timeRes:Double) -> [Double] {
        //Clear arrays
        segmentList = []
        //Array for storing plotting values
        yVals = [0.0]

        self.yLimit = yLimit
        
        //Split the timebase of the graph up into three segments
        var segTimes:[Int] = [0,0,0,0]
        segTimes[0] = 0
        segTimes[1] = randomR(0...UInt32(ceil(totalTime/3)))
        segTimes[2] = segTimes[0] + randomR(0...UInt32(ceil(3/4*(totalTime-Double(segTimes[0])))))
        segTimes[3] = Int(floor(totalTime))
        println(segTimes)
        
        //Array of functions to use in determining segments of graph
        //var segmentList = Array
        segmentList = [constVals,posLinear,negLinear,accelVals]

        //Randomly set start parameter that determines where first line starts
        var yStart = 4.0
        var vStart = 0.0

        //Loop that exhaustively calls functions for calculating three line segments in random
        //order.
        for ii in 0...2 {
            

            //Get random element of array
            var currentSegment = randomR(0...UInt32(segmentList.count-1))
            var currentFunction = segmentList[currentSegment]
            println("Trying for element \(ii) with function \(currentSegment)")
            //Remove the element that we used
            //Note: need to assign to variable because removeAtIndex also returns the element
            //and throw an error if we try and get a function without passing arguments to it
            var temptemp = segmentList.removeAtIndex(currentSegment)
            
            
            //Add to the array of y values, the result of calling the current randomly 
            //chosen segment
            
            var segResult = currentFunction(tRes: timeRes, timeRange: [segTimes[ii],segTimes[ii+1]], yInit: yStart, vInit: vStart, data: yVals)
            
            yVals = yVals + segResult.0
            
            //Update the starting y-value for the next segment calculation
            yStart = segResult.1[0]
            vStart = segResult.1[1]
            println("new yStart: \(yStart), new vStart: \(vStart)")
            //yStart = yVals[yVals.count-1]
            
            println("This go worked")
            
        }
    
        //Return all data points
        return yVals
    }
    
    
    //Calculate region of graph with constant value (i.e. 'flat line') between two times
    func constVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double]) -> ([Double],[Double]){
        
        //Create an array that contains the same constant value (determined by start parameter)
        //with a number of elements that corresponds to desired time resolution and given
        //segment range
        var constArray:[Double] = Array(count: Int(ceil(Double(timeRange[1]-timeRange[0])/tRes)), repeatedValue: yInit)
        
        return (constArray,[yInit,0.0])
    }
    
    //Calculate region of graph with positive velocity
    func posLinear(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double]) -> ([Double],[Double]){
        //Array for storing values
        var posLinArray:[Double] = []
        //Choose random velocity for gradient of line will create (nb: may need to constrain
        //this to ensure y-axes are usable)
        var m = randomR(1...2)
        //Calculate intercept from this gradient and starting time/yparam
        var c = yInit-Double(m*timeRange[0])
        //Calculate y values between time range with given time resolution using y=mx+c
        for var timeIndex = Double(timeRange[0]); timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            posLinArray.append(Double(m)*timeIndex+c)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in posLinear function")
                break
            }
        }
        return (posLinArray,[posLinArray[posLinArray.count-1],Double(m)])
    }
    
    //Calculate region of graph with negative velocity
    func negLinear(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double]) -> ([Double],[Double]){
        //Array for storing values
        var negLinArray:[Double] = []
        //Choose random velocity for gradient of line will create (nb: may need to constrain
        //this to ensure y-axes are usable)
        var m = -randomR(1...2)
        //Calculate intercept from this gradient and starting time/yparam
        var c = yInit-Double(m*timeRange[0])
        //Calculate y values between time range with given time resolution using y=mx+c
        println("c is: \(c) and m is: \(m)")
        println("timeIndex start: \(Double(timeRange[0])), timeIndex stop: \(Double(timeRange[1])), timeStep: \(tRes)")
        for var timeIndex = Double(timeRange[0]); timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            negLinArray.append(Double(m)*timeIndex+c)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in posLinear function")
                break
            }
        }
        return (negLinArray,[negLinArray[negLinArray.count-1],Double(m)])
    }
    
    
    //Calculate region of graph with acceleration (pos or neg depending on yvalue it
    //starts at)
    func accelVals(tRes: Double, timeRange: [Int], yInit: Double, vInit: Double, data: [Double]) -> ([Double],[Double]){
        
        var a:Double = 0
        var vFinal:Double = 0
        var yFinal:Double = 0
        
        var accelValsArray:[Double] = []
        
        //if initial velocity is 1, 2 then decellerate to a final velocity of either 0, -1,-2
        if vInit >= 1{
           vFinal = -Double(randomR(0...2))
        //if initial velocity is -1, -2 then accelerate to final velocity of either 0,1,2
        } else if vInit <= -1 {
            vFinal = Double(randomR(0...2))
        //if vInit near 0 either acc/decellerate to final velocity of 0, +1 or -1
        } else {
            vFinal = Double(randomR(0...2)-1)
        }
        
        //Look at which tri-section of y-axis starting position is for this segment to decide where to end up.
        var triSecHeight = self.yLimit/3
        
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
        
        
        //Now calculate the acceleration we need in order to get to finalY from yInit
        //and from vInit to vFinal using suvat equation
        
        a = (pow(vFinal,2.0)-pow(vInit,2.0))/(2*yFinal)
        
        //Calculate y values between time range with given time resolution using suvat
        //equation with vFinal, vInit and acceleration
        for var timeIndex = Double(timeRange[0]); timeIndex < Double(timeRange[1]); timeIndex+=tRes {
            var currentPos = (pow(vFinal,2.0)-pow(vInit,2.0))/(2.0*a)
            accelValsArray.append(currentPos)
            //Break out if we've been going for too long as a precaution
            if timeIndex > 1000 {
                println("Something went wrong, looping forever (>1000) in accelVals function")
                break
            }
        }
        
        return (accelValsArray,[accelValsArray[accelValsArray.count-1],vFinal])
    }
    
    //Generates random integer in given range
    func randomR(range: Range<UInt32>) -> Int {
        return Int(range.startIndex + arc4random_uniform(range.endIndex - range.startIndex))
    }
    
}
