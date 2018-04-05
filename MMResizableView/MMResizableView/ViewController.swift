//
//  ViewController.swift
//  MMResizableView
//
//  Created by Marc Matta on 4/5/18.
//  Copyright © 2018 Marc Matta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resizableView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var rotated : Bool = false
    @IBAction func rotate() {
        if rotated {
            self.resizableView.transform = .identity
        }else {
            self.resizableView.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi / 2)
        }
        
        rotated = !rotated
        
    }
}

