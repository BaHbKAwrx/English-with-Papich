//
//  Level4ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 10.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import CoreData

class Level4ViewController: UIViewController {
    
    //Progress ShapeLayer
    var shapeLayer: CAShapeLayer! {
        didSet {
            shapeLayer.lineWidth = 25
            shapeLayer.lineCap = "round"
            shapeLayer.fillColor = nil
            shapeLayer.strokeEnd = 1
            let color = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1).cgColor
            shapeLayer.strokeColor = color
        }
    }
    
    var overShapeLayer: CAShapeLayer! {
        didSet {
            overShapeLayer.lineWidth = 17
            overShapeLayer.lineCap = "round"
            overShapeLayer.fillColor = nil
            overShapeLayer.strokeEnd = 0
            let color = #colorLiteral(red: 0.7882352941, green: 0.3215686275, blue: 0.3215686275, alpha: 1).cgColor
            overShapeLayer.strokeColor = color
        }
    }
    
    @IBOutlet weak var progressImageView: UIImageView!
    @IBOutlet weak var correctLabel: UIImageView!
    @IBOutlet weak var incorrectLabel: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var forthButton: UIButton!
    
    //CoreData vars
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var levels = [MenuLevel]()
    
    var questionNumber = 0
    var score = 0
    var questionNumbersArr = [Int]()
    var questionsArray = [ForthLevelQuestion]()
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        questionsArray = initAllQuestions()
        
        questionNumbersArr = makeNumbersArray()
        print(questionNumbersArr)
        
        firstButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[0], for: .normal)
        secondButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[1], for: .normal)
        thirdButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[2], for: .normal)
        forthButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[3], for: .normal)
        
        questionTextLabel.text = questionsArray[questionNumbersArr[questionNumber]].question
        
        correctLabel.alpha = 0
        incorrectLabel.alpha = 0
        
        //Loading data from CoreData
        let fetchRequest: NSFetchRequest<MenuLevel> = MenuLevel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "levelNumber", ascending: true)]
        //print(fetchRequest)
        
        do {
            let results = try context.fetch(fetchRequest)
            levels = results
            //print(levels)
        } catch {
            print(error.localizedDescription)
        }
        
        // Custom progress bar
        shapeLayer = CAShapeLayer()
        view.layer.addSublayer(shapeLayer)
        
        overShapeLayer = CAShapeLayer()
        view.layer.addSublayer(overShapeLayer)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configShapeLayer(shapeLayer)
        configShapeLayer(overShapeLayer)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let afterGameVC = segue.destination as? AftergameViewController {
            afterGameVC.correctAnswers = score
        }
        
    }
    
    // MARK: - Methods
    func configShapeLayer(_ shapeLayer: CAShapeLayer) {
        shapeLayer.frame = view.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.progressImageView.frame.origin.x, y: self.progressImageView.frame.origin.y + self.progressImageView.frame.height / 2))
        path.addLine(to: CGPoint(x: self.progressImageView.frame.origin.x + self.progressImageView.frame.width, y: self.progressImageView.frame.origin.y + self.progressImageView.frame.height / 2))
        shapeLayer.path = path.cgPath
    }
    
    func makeNumbersArray() -> [Int] {
        // Делает массив из 10 рандомных неповторяющихся чисел
        var numbersArray = [Int]()
        var i = 0
        var numberToAdd: Int
        while i < 10 {
            numberToAdd = Int((arc4random()%UInt32(questionsArray.count)))
            if !numbersArray.contains(numberToAdd) {
                numbersArray.append(numberToAdd)
                i += 1
            }
        }
        return numbersArray
    }
    
    func goToNextQuestion() {
        
        if questionNumber < 9 {
            
            //making buttons active
            firstButton.isEnabled = true
            secondButton.isEnabled = true
            thirdButton.isEnabled = true
            forthButton.isEnabled = true
            
            questionNumber += 1
            firstButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[0], for: .normal)
            secondButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[1], for: .normal)
            thirdButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[2], for: .normal)
            forthButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[3], for: .normal)
            
            questionTextLabel.text = questionsArray[questionNumbersArr[questionNumber]].question
            
            // Progress bar add
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = CGFloat(questionNumber)/10
            animation.duration = 0.5
            
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fillMode = kCAFillModeBoth
            animation.isRemovedOnCompletion = false
            
            overShapeLayer.add(animation, forKey: nil)
            
            
        } else {
            performSegue(withIdentifier: "afterGameSegue4", sender: self)
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Button actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue4", sender: self)
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
        //making buttons unactive
        firstButton.isEnabled = false
        secondButton.isEnabled = false
        thirdButton.isEnabled = false
        forthButton.isEnabled = false
        
        
        if sender.titleLabel?.text == questionsArray[questionNumbersArr[questionNumber]].correctAnswer {
            print("Correct")
            score += 1
            //Saving to CoreData
            levels[3].correctAnswers += 1
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            //animate
            UIView.animate(withDuration: 0.6, animations: {[weak self] in
                self?.correctLabel.alpha = 1
            }) {[weak self] (true) in
                UIView.animate(withDuration: 0.4, animations: {[weak self] in
                    self?.correctLabel.alpha = 0
                    }, completion: {[weak self] (true) in
                        self?.goToNextQuestion()
                })
            }
        }
        else {
            print("Incorrect")
            //Saving to CoreData
            levels[3].incorrectAnswers += 1
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            //animate
            UIView.animate(withDuration: 0.6, animations: {[weak self] in
                self?.incorrectLabel.alpha = 1
            }) {[weak self] (true) in
                UIView.animate(withDuration: 0.4, animations: {[weak self] in
                    self?.incorrectLabel.alpha = 0
                    }, completion: {[weak self] (true) in
                        self?.goToNextQuestion()
                })
            }
        }
        
    }

}

extension Level4ViewController {
    
    func initAllQuestions() -> [ForthLevelQuestion] {
        
        var resultArray = [ForthLevelQuestion]()
        
        resultArray.append(ForthLevelQuestion(question: "После", correctAnswer: "After", allAnswers: ["After", "Before", "While", "Now"]))
        resultArray.append(ForthLevelQuestion(question: "Определять", correctAnswer: "Ascertain", allAnswers: ["Choose", "Ascertain", "Decide", "Explain"]))
        resultArray.append(ForthLevelQuestion(question: "Назад", correctAnswer: "Back", allAnswers: ["Forward", "Then", "Back", "Reverse"]))
        resultArray.append(ForthLevelQuestion(question: "Красивый", correctAnswer: "Beautiful", allAnswers: ["Cozy", "Greedy", "Naughty", "Beautiful"]))
        resultArray.append(ForthLevelQuestion(question: "Черный", correctAnswer: "Black", allAnswers: ["Black", "White", "Green", "Gray"]))
        resultArray.append(ForthLevelQuestion(question: "Моргать", correctAnswer: "Blink", allAnswers: ["Swipe", "Blink", "Light", "Rotate"]))
        resultArray.append(ForthLevelQuestion(question: "Принеси все", correctAnswer: "Bring it all", allAnswers: ["Take it all", "Check it all", "Bring it all", "Destroy it all"]))
        resultArray.append(ForthLevelQuestion(question: "Жечь", correctAnswer: "Burn", allAnswers: ["Earn", "Return", "Freeze", "Burn"]))
        resultArray.append(ForthLevelQuestion(question: "Проверять", correctAnswer: "Check", allAnswers: ["Check", "Choose", "Suppose", "Expose"]))
        resultArray.append(ForthLevelQuestion(question: "Глина", correctAnswer: "Clay", allAnswers: ["Liquid", "Clay", "Glee", "Gleam"]))
        resultArray.append(ForthLevelQuestion(question: "Потреблять", correctAnswer: "Consume", allAnswers: ["Buy", "Resume", "Consume", "Consider"]))
        resultArray.append(ForthLevelQuestion(question: "Презрение", correctAnswer: "Contempt", allAnswers: ["Contest", "Contact", "Vision", "Contempt"]))
        resultArray.append(ForthLevelQuestion(question: "Продолжать", correctAnswer: "Continue", allAnswers: ["Continue", "Offer", "Start", "Complete"]))
        resultArray.append(ForthLevelQuestion(question: "Страна", correctAnswer: "Country", allAnswers: ["City", "Country", "Island", "Capital"]))
        resultArray.append(ForthLevelQuestion(question: "Уютный", correctAnswer: "Cozy", allAnswers: ["Dusty", "Clean", "Cozy", "Large"]))
        resultArray.append(ForthLevelQuestion(question: "Колыбель", correctAnswer: "Cradle", allAnswers: ["Bed", "Garden", "Needle", "Cradle"]))
        resultArray.append(ForthLevelQuestion(question: "Изучение Английского", correctAnswer: "English learning", allAnswers: ["English learning", "English repeating", "English listening", "English practice"]))
        resultArray.append(ForthLevelQuestion(question: "Необычайный", correctAnswer: "Extraordinary", allAnswers: ["Interesting", "Extraordinary", "Handsome", "Responsible"]))
        resultArray.append(ForthLevelQuestion(question: "Закончить", correctAnswer: "Finish", allAnswers: ["Trigger", "Start", "Finish", "Continue"]))
        resultArray.append(ForthLevelQuestion(question: "Светлячок", correctAnswer: "Firefly", allAnswers: ["Bee", "Butterfly", "Worm", "Firefly"]))
        
        return resultArray
        
    }
    
}
