//
//  Integrator.swift
//  AccelTest2
//
//  Created by Nicholas Harrigan on 21/01/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.

//Class that integrates accelerometer data to get velocity and position data

import Foundation


class integrator {
    
    var outVals: [Double] = []
    
    var pStrings: [String] = []
    
    func getInt(inputVals: [Double], timeVals: [Double])->[Double] {
        
        outVals = [0]
        
        var timeStep: Double = 0
        
        for i in 1...inputVals.count-1 {
            
            //Find timebase between this and last reading
            timeStep = timeVals[i]-timeVals[i-1]
            
            //Define output (integrated value) at ith time value as integral between t=0 and ti on input graph (add latest trapezium onto previous integral value).
            
            outVals += [outVals[i-1]+trapArea(timeStep, a1: inputVals[i],a2: inputVals[i-1])]
            
            
            
            //pStrings += [",".join([String(format:"%f",timeVals[i]),String(format:"%f",outVals[outVals.count-1])])]
            
        }
        
        
        return outVals
        //return pStrings
        
        
    }
    
    //Function for getting sign of number
    func getSign(num1: Double)->Double {
        
        //If passed 0, return it as having sign of 1
        if num1 == 0.0 {
            return 1
        } else {
            return num1 / abs(num1)
        }
    }
    
    //Fucntion for calculating the area of trapezium between two points. Note is symmetric with
    //respect to trapezium side inputs.
    func trapArea(T: Double, a1: Double, a2: Double)->Double {
        //Equation takes into account negative sign of areas under curve
        //and allows for trapeziums that cross x-axis (reduced to a + and - triangle)
        return 0.5*T*(a1+a2)*(1.0/(pow(sqrt(2.0),(1.0-getSign(a1*a2)))))
        
    }
    
}