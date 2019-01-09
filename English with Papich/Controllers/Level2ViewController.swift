//
//  Level2ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 09.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit

class Level2ViewController: UIViewController {
    
    @IBOutlet weak var progressImageView: UIImageView!
    @IBOutlet weak var correctLabel: UIImageView!
    @IBOutlet weak var incorrectLabel: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var forthButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue2", sender: self)
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
    }
    
    
}
