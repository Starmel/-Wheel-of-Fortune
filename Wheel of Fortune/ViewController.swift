//
//  ViewController.swift
//  Wheel of Fortune
//
//  Created by admin on 9/10/19.
//  Copyright © 2019 Slava Kornienko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let point = touch.location(in: self.view)
        
        print(point)
    }
}

