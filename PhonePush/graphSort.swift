//
//  graphSort.swift
//  PhonePush
//
//  Created by Nicholas Harrigan on 09/04/2015.
//  Copyright (c) 2015 Nicholas Harrigan. All rights reserved.
//

import UIKit


class graphSort: UIViewController, UIDocumentInteractionControllerDelegate, UITextFieldDelegate {

    var resultsText = UITextView(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var aDbl: [Double] = []
    var vDbl: [Double] = []
    var pDbl: [Double] = []
    var tDbl: [Double] = []
    
    override init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(aDbl: [Double], vDbl: [Double], pDbl: [Double], tDbl: [Double]) {
        
        self.init()
        
        self.aDbl = aDbl
        self.vDbl = vDbl
        self.pDbl = pDbl
        self.tDbl = tDbl
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsText = UITextView(frame: CGRect(x: 50, y: 50, width: screenSize.width-100, height: 500.00));
        resultsText.font = UIFont(name: "Arial", size: 60)
        resultsText.backgroundColor = UIColor.clearColor()
        resultsText.editable = false
        
        resultsText.text = "Choose what each of these graphs is a plot of as the phone was slid..."
        self.view.addSubview(resultsText)
        
        
    }
    
    func textFieldShouldReturn(txtField: UITextField!) -> Bool {
        txtField.resignFirstResponder()
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
