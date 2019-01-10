//
//  Level3ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 10.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit

class Level3ViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue3", sender: self)
    }
    
    

}
