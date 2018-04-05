//
//  ViewController.swift
//  MMResizableView
//
//  Created by Marc Matta on 4/5/18.
//  Copyright © 2018 Marc Matta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var resizableView : MMResizableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resizableView.delegate = self
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

extension ViewController : MMResizableViewDelegate {
    func didUpdate(resizableView: MMResizableView) {
        print(resizableView.frame)
    }
}
