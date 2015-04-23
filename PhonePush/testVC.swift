import UIKit



class testVC: UIViewController {
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(cQstn: Int) {
        self.init()
        
        //println("Value of cQstn was \(cQstn)")
        
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
}


}