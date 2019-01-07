//
//  ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 07.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    //consts for level cells
    let levelsArray = ["Level 1", "Level 2", "Level 3", "Level 4"]
    let descriptionArray = ["Listen and choose!", "Translate to Russian!", "Listen and type!", "Translate to English!"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
    }
    
    //Making white status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
    }
    

}


// MARK: - TableView Data source and delegate
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as? MenuTableViewCell
        
        cell?.bgImage.image = UIImage(named: "menuCellRect")
        cell?.levelLabel.text = levelsArray[indexPath.row]
        cell?.descriptionLabel.text = descriptionArray[indexPath.row]
        cell?.correctLabel.text = "27 correct"
        cell?.incorrectLabel.text = "12 incorrect"
        
        return cell ?? UITableViewCell()
        
    }
    
}

