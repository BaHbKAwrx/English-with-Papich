//
//  ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 07.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    //CoreData vars
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var levels = [MenuLevel]()
    
    @IBOutlet weak var menuTableView: UITableView!
    
    //consts for level cells
    let levelsArray = ["Level 1", "Level 2", "Level 3", "Level 4"]
    let descriptionArray = ["Listen and choose!", "Translate to Russian!", "Listen and type!", "Translate to English!"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStartData()
        
        //Loading data from CoreData
        let fetchRequest: NSFetchRequest<MenuLevel> = MenuLevel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "levelNumber", ascending: true)]
        print(fetchRequest)
        
        do {
            let results = try context.fetch(fetchRequest)
            levels = results
            print(levels)
        } catch {
            print(error.localizedDescription)
        }
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
    }
    
    //function for init start values for level progress
    func getStartData() {
        
        let fetchRequest: NSFetchRequest<MenuLevel> = MenuLevel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "levelNumber != nil")
        
        var records = 0
        
//        print(context)
//        print(fetchRequest)
        
        do {
            let count = try context.count(for: fetchRequest)
            records = count
            print("Data is there already?")
        } catch {
            print(error.localizedDescription)
        }
        
        guard records == 0 else { return }
        
        for i in 0..<4 {
            let entity = NSEntityDescription.entity(forEntityName: "MenuLevel", in: context)
            let level = NSManagedObject(entity: entity!, insertInto: context) as! MenuLevel
            
            level.levelNumber = Int16(i + 1)
            level.correctAnswers = 0
            level.incorrectAnswers = 0
        }
        
    }
    
    //Making white status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        
        let ac = UIAlertController(title: nil, message: "It will reset all your progress!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) {[weak self] (action) in
            for level in (self?.levels)! {
                level.correctAnswers = 0
                level.incorrectAnswers = 0
            }
            
            do {
                try self?.context.save()
                self?.menuTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true, completion: nil)
        
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
        cell?.levelLabel.text = "\(levels[indexPath.row].levelNumber) Level"
        cell?.descriptionLabel.text = descriptionArray[indexPath.row]
        cell?.correctLabel.text = "\(levels[indexPath.row].correctAnswers) correct"
        cell?.incorrectLabel.text = "\(levels[indexPath.row].incorrectAnswers) incorrect"
        
        return cell ?? UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0: performSegue(withIdentifier: "firstLevelSegue", sender: self)
        case 1: performSegue(withIdentifier: "secondLevelSegue", sender: self)
        case 2: performSegue(withIdentifier: "thirdLevelSegue", sender: self)
        case 3: performSegue(withIdentifier: "forthLevelSegue", sender: self)
        default: break
        }
        
    }
    
}

