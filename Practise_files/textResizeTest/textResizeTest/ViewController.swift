//
//  ViewController.swift
//  textResizeTest
//
//  Created by Nicholas Harrigan on 24/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var titleText:UITextView = UITextView(frame: CGRectMake(0,0,300,100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Textfield
        titleText.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleText.text = "Ready, steady, teddy beddy ready breaky "
        titleText.font = UIFont(name: "Arial", size: 200)
        UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleText.editable = false
        titleText.backgroundColor = UIColor.redColor()

        self.view.addSubview(titleText)
        
        //Auto resize text
        
        autoResize()
        
    }

    
    func autoResize() {
        
        
        
        //Max size for tallerSize (just needs to be very large)
        let kMaxFieldHeight = 9999
        //String that we want to try and get to fit
        var fitString:NSString = titleText.text
        //Maximum font size you would consider
        var maxFontSize = 500.0
        //Minumum font size you would consider
        var minFontSize = 5.0
        //Fudge factor due to padding in UIView
        var fudgeFactor = 16.0
        //Font size we start with
        
        //Start font off at largest size that we would allow
        var fontSize = maxFontSize
        titleText.font = UIFont(name: titleText.font.fontName, size: CGFloat(fontSize))
     
        //Make holder size that is width of the view but very tall - so we can see what height
        //text has when we try and force it into it
        var tallerSize = CGSizeMake(titleText.frame.size.width - CGFloat(fudgeFactor), CGFloat(kMaxFieldHeight))
        //Dictionary with font attributes in that we use to get size of text (of this font type/size) when pushed into tallerSize
        var attrs = [NSFontAttributeName: UIFont(name: titleText.font.fontName,size: CGFloat(fontSize)) as! AnyObject]
        //Get first run of stringSize for current fontSize when try to push into tallerSize
        var stringSize = fitString.boundingRectWithSize(tallerSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attrs,
            context: nil).size
        
        //Loop reducing font until will fit
        while (stringSize.height >= titleText.frame.size.height) {
        
            if (fontSize <= minFontSize) {
                println("too small!!")
                return
            } else {
                fontSize -= 1.0
                
                titleText.font = UIFont(name: titleText.font.fontName,size: CGFloat(fontSize))
                
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

