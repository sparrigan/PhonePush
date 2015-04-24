//
//  ViewController.swift
//  textResizeTest
//
//  Created by Nicholas Harrigan on 24/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tText:UITextView = UITextView(frame: CGRectMake(0,0,400,600))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Textfield
        tText.setTranslatesAutoresizingMaskIntoConstraints(false)
        tText.text = "Ready, steady, teddy beddy ready breaky"
        tText.font = UIFont(name: "Arial", size: 200)
        UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        tText.editable = false
        tText.backgroundColor = UIColor.redColor()

        self.view.addSubview(tText)
        
        //Auto resize text
        
        sizeFontToView(tText,maxFontSize:500,minFontSize:5)
        
    }

    
    func sizeFontToView(tView:UITextView,maxFontSize:Double = 500,minFontSize:Double = 5) {
        
        //maxFontSize is the Maximum font size you would consider allowable (defaults to 500)
        //minFontSize is the Minumum font size you would consider allowable (defaults to 5)
        
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
        
        //Loop reducing font until will fit
        while (stringSize.height >= tView.frame.size.height) {
        
            if (fontSize <= minFontSize) {
                println("too small!!")
                return
            } else {
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

        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

