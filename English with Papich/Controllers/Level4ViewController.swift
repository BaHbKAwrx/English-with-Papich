//
//  Level4ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 10.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit

class Level4ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue4", sender: self)
    }
    

}
