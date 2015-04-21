//
//  nextQstn.swift
//  
//
//  Created by Nicholas Harrigan on 17/04/2015.
//
//

import UIKit

//This class gets called when a questions VC is done, and rewrites the navigation
//stack to present the next question - including call to new push if necessary.

public class nextQstn {

    //Stores ordered list of qstns to ask (updated by method below)
    public var qstnString:[String] = []
    //This index increments with each new question, determining which qstn from 
    //qstnString to add to VC stack next
    var qstnIndex = 0
    
    //This is called by initial http teacher call to update qstnString
    public func updateQstns(newStrings:[String]) {
        qstnString = newStrings
    }
    
    //This is the method that is called from a VC to move onto the next qstn
    public func goToNext(navi: UINavigationController) {
        
        //Here we increment qstnIndex, then go through conditionals to determine which VC to assign to nextVC var (with clauses for adding phonepush calib screen if needed but not done already.
        
        qstnIndex++
        
        var nextVC:UIViewController?
        
        //NEED TO DO A CHECK HERE FOR WHETER OR NOT WE HAVE DATA VALUES FROM A PUSH.
        
        if qstnString[qstnIndex] == "" {
            
        } else if qstnString[qstnIndex] == "" {
            
        } else {
            
        }
        
        //Then remove top of stack and reorder etc... with chosen nextVC
        
    }
    
    //PUBLIC FUNC NEEDS TO GO HERE FOR UPDATING THE DATA VALUES FROM A PUSH
    
    
}