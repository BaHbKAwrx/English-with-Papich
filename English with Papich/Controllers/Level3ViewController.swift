//
//  Level3ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 10.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class Level3ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Const and vars declaration
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
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //CoreData vars
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var levels = [MenuLevel]()
    
    var player: AVAudioPlayer!
    var questionNumber = 0
    var score = 0
    var questionNumbersArr = [Int]()
    var questionsArray = [ThirdLevelQuestion]()
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        answerTextField.delegate = self

        questionsArray = initAllQuestions()
        
        questionNumbersArr = makeNumbersArray()
        
        correctLabel.alpha = 0
        incorrectLabel.alpha = 0
        
        loadCoreData()
        
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
        
        stackView.center = view.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let afterGameVC = segue.destination as? AftergameViewController {
            afterGameVC.correctAnswers = score
        }
        
    }
    
    // MARK: - textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        stackUpAnimation()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        stackDownAnimation()
    }
    
    // MARK: - Methods
    
    func stackUpAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.stackView.center.y = 30 + self.stackView.frame.height / 2
        }
    }
    func stackDownAnimation() {
        UIView.animate(withDuration: 0.8) {
            self.stackView.center.y = self.view.center.y
        }
    }
    
    func loadCoreData() {
        
        //Loading data from CoreData
        let fetchRequest: NSFetchRequest<MenuLevel> = MenuLevel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "levelNumber", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            levels = results
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
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
            questionNumber += 1
            
            answerTextField.text = ""
            answerTextField.placeholder = "Type in English"
            
            // Progress bar add
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = CGFloat(questionNumber)/10
            animation.duration = 0.5
            
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fillMode = kCAFillModeBoth
            animation.isRemovedOnCompletion = false
            
            overShapeLayer.add(animation, forKey: nil)
            
            
        } else {
            performSegue(withIdentifier: "afterGameSegue3", sender: self)
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Button actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue3", sender: self)
    }
    
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        
        let soundName = questionsArray[questionNumbersArr[questionNumber]].sound
        
        let fileUrl = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        guard let file_Url = fileUrl else { return }
        do {
            player = try AVAudioPlayer.init(contentsOf: file_Url)
        } catch {
            print(error.localizedDescription)
        }
        player.play()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        guard !(answerTextField.text?.isEmpty)! else { return }
        
        if answerTextField.text?.uppercased() == questionsArray[questionNumbersArr[questionNumber]].correctAnswer.uppercased() {
            score += 1
            //Saving to CoreData
            levels[2].correctAnswers += 1
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
            //Saving to CoreData
            levels[2].incorrectAnswers += 1
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

// MARK: - Extension for initializing all questions
extension Level3ViewController {
    
    func initAllQuestions() -> [ThirdLevelQuestion] {
        
        var resultArray = [ThirdLevelQuestion]()
        
        resultArray.append(ThirdLevelQuestion(sound: "after", correctAnswer: "After"))
        resultArray.append(ThirdLevelQuestion(sound: "ascertain", correctAnswer: "Ascertain"))
        resultArray.append(ThirdLevelQuestion(sound: "back", correctAnswer: "Back"))
        resultArray.append(ThirdLevelQuestion(sound: "beautiful", correctAnswer: "Beautiful"))
        resultArray.append(ThirdLevelQuestion(sound: "black", correctAnswer: "Black"))
        resultArray.append(ThirdLevelQuestion(sound: "blink", correctAnswer: "Blink"))
        resultArray.append(ThirdLevelQuestion(sound: "bring it all", correctAnswer: "Bring it all"))
        resultArray.append(ThirdLevelQuestion(sound: "burn", correctAnswer: "Burn"))
        resultArray.append(ThirdLevelQuestion(sound: "check", correctAnswer: "Check"))
        resultArray.append(ThirdLevelQuestion(sound: "clay", correctAnswer: "Clay"))
        resultArray.append(ThirdLevelQuestion(sound: "contempt", correctAnswer: "Contempt"))
        resultArray.append(ThirdLevelQuestion(sound: "continue", correctAnswer: "Continue"))
        resultArray.append(ThirdLevelQuestion(sound: "country", correctAnswer: "Country"))
        resultArray.append(ThirdLevelQuestion(sound: "cozy", correctAnswer: "Cozy"))
        resultArray.append(ThirdLevelQuestion(sound: "cradle", correctAnswer: "Cradle"))
        resultArray.append(ThirdLevelQuestion(sound: "english learning", correctAnswer: "English learning"))
        resultArray.append(ThirdLevelQuestion(sound: "finish", correctAnswer: "Finish"))
        resultArray.append(ThirdLevelQuestion(sound: "firefly", correctAnswer: "Firefly"))
        resultArray.append(ThirdLevelQuestion(sound: "forward", correctAnswer: "Forward"))
        resultArray.append(ThirdLevelQuestion(sound: "from me", correctAnswer: "From me"))
        resultArray.append(ThirdLevelQuestion(sound: "glide", correctAnswer: "Glide"))
        resultArray.append(ThirdLevelQuestion(sound: "grain", correctAnswer: "Grain"))
        resultArray.append(ThirdLevelQuestion(sound: "harsh man", correctAnswer: "Harsh man"))
        resultArray.append(ThirdLevelQuestion(sound: "hate", correctAnswer: "Hate"))
        resultArray.append(ThirdLevelQuestion(sound: "help", correctAnswer: "Help"))
        resultArray.append(ThirdLevelQuestion(sound: "I dropped", correctAnswer: "I dropped"))
        resultArray.append(ThirdLevelQuestion(sound: "i thanks", correctAnswer: "I thanks"))
        resultArray.append(ThirdLevelQuestion(sound: "invoice", correctAnswer: "Invoice"))
        resultArray.append(ThirdLevelQuestion(sound: "is not avaliable", correctAnswer: "Is not avaliable"))
        resultArray.append(ThirdLevelQuestion(sound: "it begins", correctAnswer: "It begins"))
        resultArray.append(ThirdLevelQuestion(sound: "joy", correctAnswer: "Joy"))
        resultArray.append(ThirdLevelQuestion(sound: "mayhem", correctAnswer: "Mayhem"))
        resultArray.append(ThirdLevelQuestion(sound: "meadow", correctAnswer: "Meadow"))
        resultArray.append(ThirdLevelQuestion(sound: "my mom", correctAnswer: "My mom"))
        resultArray.append(ThirdLevelQuestion(sound: "non-native", correctAnswer: "Non-native"))
        resultArray.append(ThirdLevelQuestion(sound: "old man", correctAnswer: "Old man"))
        resultArray.append(ThirdLevelQuestion(sound: "outright", correctAnswer: "Outright"))
        resultArray.append(ThirdLevelQuestion(sound: "portray", correctAnswer: "Portray"))
        resultArray.append(ThirdLevelQuestion(sound: "pounce", correctAnswer: "Pounce"))
        resultArray.append(ThirdLevelQuestion(sound: "respite", correctAnswer: "Respite"))
        resultArray.append(ThirdLevelQuestion(sound: "retribution", correctAnswer: "Retribution"))
        resultArray.append(ThirdLevelQuestion(sound: "rise", correctAnswer: "Rise"))
        resultArray.append(ThirdLevelQuestion(sound: "second", correctAnswer: "Second"))
        resultArray.append(ThirdLevelQuestion(sound: "seven", correctAnswer: "Seven"))
        resultArray.append(ThirdLevelQuestion(sound: "spaceship", correctAnswer: "Spaceship"))
        resultArray.append(ThirdLevelQuestion(sound: "stand", correctAnswer: "Stand"))
        resultArray.append(ThirdLevelQuestion(sound: "stealth", correctAnswer: "Stealth"))
        resultArray.append(ThirdLevelQuestion(sound: "stove", correctAnswer: "Stove"))
        resultArray.append(ThirdLevelQuestion(sound: "take gem", correctAnswer: "Take gem"))
        resultArray.append(ThirdLevelQuestion(sound: "take my land", correctAnswer: "Take my land"))
        resultArray.append(ThirdLevelQuestion(sound: "take my love", correctAnswer: "Take my love"))
        resultArray.append(ThirdLevelQuestion(sound: "the sea", correctAnswer: "The sea"))
        resultArray.append(ThirdLevelQuestion(sound: "thick", correctAnswer: "Thick"))
        resultArray.append(ThirdLevelQuestion(sound: "think", correctAnswer: "Think"))
        resultArray.append(ThirdLevelQuestion(sound: "throat", correctAnswer: "Throat"))
        resultArray.append(ThirdLevelQuestion(sound: "thrust", correctAnswer: "Thrust"))
        resultArray.append(ThirdLevelQuestion(sound: "tinker", correctAnswer: "Tinker"))
        resultArray.append(ThirdLevelQuestion(sound: "tool", correctAnswer: "Tool"))
        resultArray.append(ThirdLevelQuestion(sound: "trash", correctAnswer: "Trash"))
        resultArray.append(ThirdLevelQuestion(sound: "very small", correctAnswer: "Very small"))
        resultArray.append(ThirdLevelQuestion(sound: "weasel", correctAnswer: "Weasel"))
        resultArray.append(ThirdLevelQuestion(sound: "wildfire", correctAnswer: "Wildfire"))
        
        
        return resultArray
        
    }
    
}
