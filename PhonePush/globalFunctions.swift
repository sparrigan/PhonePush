//
//  globalFunctions.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 15/06/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

func randomNum() -> Double {
    return Double(Float(arc4random()) / 0xFFFFFFFF)
}

func randomNum(min: Double, max: Double) -> Double {
    return randomNum() * (max-min) + min
}


//Returns a number selected from Poisson distribution with mean mu
func poissonRandomNum(mu: Double) -> Int {
    let L:Double = exp(-mu)
    var k:Int = 0
    var p:Double = 1.0
    do {
        k += 1
        p = p*randomNum()
    } while p > L
    
    return k - 1
    
    //For mu > 30 should use accept-reject instead of Knuth method.
}

//Pass decay probability per second and timeSpan in seconds, returns geom. dist. random number
func geomRandomNum(lambda:Double,timeSpan:Double) -> Int {
    //Get probability for decay over whole timespan
    var decayProbSec = 1 - exp(-lambda)
    var probOverWholeTimeSpan = 1 - exp(-lambda*(timeSpan))
    //Return number sampled from p(k) = pnorm(1-pnorm)^(k-1) but with each  (p(k) normalised by probOverWholeTimeSpan
    //(this is inverse cumulative distribution function from that normalised p(k) distribution).
    return Int(ceil(log(1-probOverWholeTimeSpan*randomNum())/log(1-decayProbSec)))-1
    
    //NOTE: subtract 1 above, so that in each timestep of size k can decay at 0 (starting point) up to k-1
}