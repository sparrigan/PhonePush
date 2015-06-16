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