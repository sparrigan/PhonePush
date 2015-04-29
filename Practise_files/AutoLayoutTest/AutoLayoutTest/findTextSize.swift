//
//  findTextSize.swift
//  AutoLayoutTest
//
//  Created by Nicholas Harrigan on 26/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class findTextSize {
    
   
    
    var fontSizeDic = [UIView: [Double]]()
    
    var testView:UIView
    

    init(ttView:UIView) {
        //
        testView = ttView
        //add views to dictionary with no values for font sizes yet
        //fontSizeDic[testView]
        //fontSizeDic[testView] = [0,0]
        fontSizeDic[testView] = [0.0,0.0]
    }
    
    func checkViewType() {
        if let checkType = testView as? UITextView {
            println("It was a textview!")
        } else if let checkType = testView as? UIButton {
            println("It was a button")
        } else {
            println("It was something else")
        }
    }
    
    func updateViewFont(currentOrientation: String) -> Double {
        //Set subscript index according to whether we are working with portrait or landscape
        var ii = 0
        
        if currentOrientation == "Portrait" {
             ii = 0
        } else if currentOrientation == "Landscape" {
             ii = 1
        }
        
        //Go through dictionary and check whether already have a calculated value or not for
        //each view for current orientation
        // PUT THE LOOP HERE
        
        //First double check that the UIView actually has an element in the dictionary!
        if var ttt = fontSizeDic[testView] {
            
            println("Checking what's there, and it's: \(ttt[ii])")
            
            //Check whether there is already a value in the dictionary for this view in
            //this orientation (specified by ii)
            if ttt[ii] != 0 {
            
                println("Already had a value there - AWESOME!")
                
                //Return the font size that we already have
                return ttt[ii]
            } else {
                //No font size already calculated, so need to calculate it, set the dictionary
                //for next time, and return the newly calculated value
                

                //Note that dictionary elements always return optional, so need to unwrap
                fontSizeDic[testView]![0] = Double(sizeFontToViewBinary(testView as! UITextView, maxFontSize:500.0, minFontSize: 5.0))
                
                println("JUST ASSIGNED A VALUE TO \(ii) ELEMENT OF DIC")
                
                return fontSizeDic[testView]![0]
                
                //return ttt[ii]
            }
        } else {
            //Nothing defined for that UIView! Something has gone wrong!
            //Define an element for it and work on that.
           
            return 0
        }
        
    }
    
    
    //Sizing font for text but with BINARY SEARCH
    func sizeFontToViewBinary(tView:UITextView,maxFontSize:Double = 500,minFontSize:Double = 5) -> CGFloat {
        
        println("Called the intesive function")
        
        
        //Max size for tallerSize (just needs to be very large)
        let kMaxFieldHeight = 9999
        //String that we want to try and get to fit
        var fitString:NSString = tView.text
        //Fudge factor due to padding in UIView
        var fudgeFactor = 16.0
        //Font size we start with
        
        //Start font off at largest size that we would allow
        var fontSize = maxFontSize
        
        
        
        tView.font = UIFont(name: tView.font.fontName, size: CGFloat(fontSize))
        
        
        
        //Make holder size that is width of the view but very tall - so we can see what height
        //text has when we try and force it into it
        var tallerSize = CGSizeMake(tView.frame.size.width - CGFloat(fudgeFactor), CGFloat(kMaxFieldHeight))
        //Dictionary with font attributes in that we use to get size of text (of this font type/size) when pushed into tallerSize
        var attrs = [NSFontAttributeName: UIFont(name: tView.font.fontName,size: CGFloat(fontSize)) as! AnyObject]
        //Get first run of stringSize for current fontSize when try to push into tallerSize
        var stringSize = fitString.boundingRectWithSize(tallerSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attrs,
            context: nil).size
        
        //Loop reducing font until will fit by removing or adding a half of it's current
        //value until either get within 20 pixels of desired height, or more than 15 iterations
        //are used
        var ii = 0
        while (abs(stringSize.height - tView.frame.size.height)>20 && ii<=15) {
            ii++
            //If current fontsize gives a stringsize that is too large then halve
            //else add a half (i.e. multiply by 1.5)
            if (stringSize.height >= tView.frame.size.height) {
                fontSize = ceil(fontSize/2)
            } else {
                fontSize = ceil(1.5*fontSize)
            }
            //Update view with new altered font size, and update corresponding stringSize
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            //Update the attributes dictionary with the new font size
            var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
            //Generate a new stringSize trying to fit this new sized font into tallerSize
            stringSize = fitString.boundingRectWithSize(tallerSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attrs,
                context: nil).size
        }
        
       
        
        //Now have gotten pretty close with above binary search, linearly increase or decrease
        //font size from this point as necessary until we get as close as possible.
        if stringSize.height >= tView.frame.size.height {
            
            
            //If end up with string too big for view try decreasing font size one point at
            //a time
            

            while (stringSize.height > tView.frame.size.height) {
                fontSize -= 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
            }
            
        
            
            return tView.font.pointSize
        } else {
            
            //If end up with string too small for view try increasing font size one point at
            //a time
            while (stringSize.height <= tView.frame.size.height) {
                fontSize += 1.0
                tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
                //Update the attributes dictionary with the new font size
                var attrs = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(fontSize))]
                //Generate a new stringSize trying to fit this new sized font into tallerSize
                stringSize = fitString.boundingRectWithSize(tallerSize,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attrs,
                    context: nil).size
            }
            //Above loop will have stopped when we arrive just *above* what fits, so go back
            //down one point in font size
            fontSize -= 1.0
            tView.font = UIFont(name: tView.font.fontName,size: CGFloat(fontSize))
            
            
            return tView.font.pointSize
        }
    }
    
    
}
