//
//  GuessIsotope.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 13/05/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit

class guessIsotope: UIViewController {
    
    var questionText = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var submitButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var checkViewAppearedForFirstTime = 0
    var textResizer:findTextSize?
    
    var aas:atomArrayScene = atomArrayScene()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    
        
        
        
        //scene = AtomScene(sizeinput: CGSize(width: atomWidth, height: atomHeight), atomField: atomNums)
        
        
        
        //let skView = SKView(frame: CGRect(x: (view.bounds.size.width-atomWidth)/2,y: (view.bounds.size.height-atomHeight)/2, width: atomWidth, height: atomHeight))
        
        //println(atomWidth)
        
        // println("skView width: \(skView.frame.width). skview x: \((view.bounds.size.width-atomWidth)/2). Whole view width: \(view.bounds.size.width)")
        
        
        //let skView = SKView(frame: view.bounds)
        
        //self.view.addSubview(skView)
        
        //skView.presentScene(scene)

        
        aas.backgroundColor = UIColor.greenColor()
        aas.setTranslatesAutoresizingMaskIntoConstraints(false)
        //var vDic = ["aas":aas]
        view.addSubview(aas)
        
        var vsAas = NSLayoutConstraint(item: aas, attribute: .Height, relatedBy: .Equal, toItem: aas.superview, attribute: .Height, multiplier: 0.5, constant: 0)
        var hsAas = NSLayoutConstraint(item: aas, attribute: .Width, relatedBy: .Equal, toItem: aas.superview, attribute: .Width, multiplier: 0.5, constant: 0)
        var vAas = NSLayoutConstraint(item: aas, attribute: .CenterY, relatedBy: .Equal, toItem: aas.superview, attribute: .CenterY, multiplier: 1, constant: 0)
        var hAas = NSLayoutConstraint(item: aas, attribute: .CenterX, relatedBy: .Equal, toItem: aas.superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        
        
        self.view.addConstraints([hAas,vAas,vsAas,hsAas])
        
        //aas.layoutSubviews()
        
        setupViews()
    
        
        
    }
    /*
    override func viewDidLayoutSubviews() {
        
    aas = atomArrayScene()
    
    }
*/
    
    
    override func viewDidAppear(animated: Bool) {
        textResizer!.updateViewFont("")
        
        checkViewAppearedForFirstTime = 1
        
    }
    
    func setupViews() {
        
        //Ask question based on data according to mock setting
        questionText = UITextView(frame: CGRect(x: 50, y: 25, width: screenSize.width-100, height: 200.00));
        questionText.font = UIFont(name: "Arial", size: 60)
        questionText.backgroundColor = UIColor.clearColor()
        questionText.editable = false
        questionText.text = "This Isotope is...."
        //questionText.backgroundColor = UIColor.greenColor()
        
        
        //Answer submit button
        submitButton.frame = CGRectMake(screenSize.width-275, screenSize.height-140, 250, 125)
        submitButton.backgroundColor = UIColor(red: 245.0/255.0, green: 121.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 5
        submitButton.layer.borderColor = UIColor.blackColor().CGColor
        submitButton.titleLabel!.font =  UIFont(name: "Arial", size: 60)
        submitButton.addTarget(self, action: "submitAnswer:", forControlEvents: .TouchUpInside)
        submitButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        //Stop swift from adding its own constraints for all views in use by autolayout
        questionText.setTranslatesAutoresizingMaskIntoConstraints(false)
        submitButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        //Add subviews to relevant parent views.
        self.view.addSubview(questionText)
        self.view.addSubview(submitButton)
        //add graphs as subviews to graphView UIView
        
        //MAKE A VIEW FOR STORING BUTTONS FOR GETTING GRAPH ETC... (MIGHT LATER USE NAVI-
        //CONTROLLER FRAME???
        
        //NOW SETUP THE ATOMS IN THEIR OWN VIEW, WHERE WE CALCULATE THE LAYOUT USING 
        //QUADRATIC FORMULA PREVIOUSLY DERIVED, AND THEN PLACE EACH ROW INTO A VIEW 
        //(WITH ATOMS AUTOLAYOUTED INSIDE), AND THEN AUTOLAYOUT EACH ROW-VIEW VERTICALLY
        //WITHIN VIEW CONTAINING THE ATOMS
        
        
        //Dictionary for all views to be managed by autolayout
        let viewsDictionary = ["questionText":questionText,"submitButton":submitButton]
        //Metrics used by autolayout
        let metricsDictionary = ["minGraphWidth": 20]
        
        //CONSTRAINT FOR SELF.VIEW
        
        //let constraintsV:Array = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(5)-[questionText]-(<=20)-[graphView]-[ansButtonsView]-(<=30)-[submitButton]-(>=5)-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        
        //QUESTIONTEXT specific contraints
        /*
        let wConstraint = NSLayoutConstraint(item: questionText, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let centConstraint = NSLayoutConstraint(item: questionText, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        let hConstraint = NSLayoutConstraint(item: questionText, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.25, constant: 0)

        //GRAPHVIEW specific constraints
        let wGraphConstraint = NSLayoutConstraint(item: graphView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let hGraphConstraint = NSLayoutConstraint(item: graphView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.4, constant: 0)
        //ANSBUTTONS specific constraints
        let wAnsConstraint = NSLayoutConstraint(item: ansButtonsView, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
        let hAnsConstraint = NSLayoutConstraint(item: ansButtonsView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        let hSubmitButtonConstraint = NSLayoutConstraint(item: submitButton, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: self.view, attribute: .Height, multiplier: 0.15, constant: 0)
        let sumbitCentConstraint = NSLayoutConstraint(item: submitButton, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        */
        //Add constraints to self.view
        //self.view.addConstraints(constraintsV+[wConstraint,centConstraint,hConstraint,wGraphConstraint, hGraphConstraint,wAnsConstraint,hAnsConstraint,hSubmitButtonConstraint,sumbitCentConstraint])
        
        //CONSTRAINTS FOR GRAPHVIEW
        //Heights of graphs within graphView
        /*
        let hgDConstraint = NSLayoutConstraint(item: gD, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hgD2Constraint = NSLayoutConstraint(item: gD2, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hgD3Constraint = NSLayoutConstraint(item: gD3, attribute: .Height, relatedBy: .Equal, toItem: graphView, attribute: .Height, multiplier: 1.0, constant: 0)
        //Center vertically in graphView
        let gDcentConstraint = NSLayoutConstraint(item: gD, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        let gD2centConstraint = NSLayoutConstraint(item: gD2, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        let gD3centConstraint = NSLayoutConstraint(item: gD3, attribute: .CenterY, relatedBy: .Equal, toItem: graphView, attribute: .CenterY, multiplier: 1, constant: 0)
        //layout within graphView (including widths - min as set in metric, but fill out to
        //view with equal widths)
        let gDconstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[gD(>=minGraphWidth)]-[gD2(==gD)]-[gD3(==gD)]-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //Add constraints to graphView
        graphView.addConstraints([hgDConstraint,hgD2Constraint,hgD3Constraint,gDcentConstraint,gD2centConstraint,gD3centConstraint]+gDconstraintH)
        
        //CONSTRAINTS FOR ANSBUTTONSVIEW
        //Heights of answer textfields within ansbuttonsview
        let hAns1Constraint = NSLayoutConstraint(item: ansTxt1, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hAns2Constraint = NSLayoutConstraint(item: ansTxt2, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        let hAns3Constraint = NSLayoutConstraint(item: ansTxt3, attribute: .Height, relatedBy: .Equal, toItem: ansButtonsView, attribute: .Height, multiplier: 1.0, constant: 0)
        //Center vertically in ansbuttonsview
        let ans1centConstraint = NSLayoutConstraint(item: ansTxt1, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        let ans2centConstraint = NSLayoutConstraint(item: ansTxt2, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        let ans3centConstraint = NSLayoutConstraint(item: ansTxt3, attribute: .CenterY, relatedBy: .Equal, toItem: ansButtonsView, attribute: .CenterY, multiplier: 1, constant: 0)
        //layout within ansbuttonsview (including widths - min as set in metric, but fill out
        //to view with equal widths)
        let ansTxtconstraintH:Array = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[ansTxt1(>=minGraphWidth)]-[ansTxt2(==ansTxt1)]-[ansTxt3(==ansTxt1)]-|", options: NSLayoutFormatOptions(0), metrics: metricsDictionary, views: viewsDictionary)
        //Add constraints to ansbuttonsview
        ansButtonsView.addConstraints([hAns1Constraint,hAns2Constraint,hAns3Constraint,ans1centConstraint,ans2centConstraint,ans3centConstraint]+ansTxtconstraintH)
        */
        //Font resizing function: send list of views for resizing to font resizer object
        textResizer = findTextSize(vArray: [questionText])
        
    }
    
    
    

}
