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
        resultArray.append(ForthLevelQuestion(question: "Вперед", correctAnswer: "Forward", allAnswers: ["Forward", "Regret", "Tomorrow", "Back"]))
        resultArray.append(ForthLevelQuestion(question: "От меня", correctAnswer: "From me", allAnswers: ["For me", "From me", "For you", "Without me"]))
        resultArray.append(ForthLevelQuestion(question: "Скользить", correctAnswer: "Glide", allAnswers: ["Bride", "Pride", "Glide", "Fly"]))
        resultArray.append(ForthLevelQuestion(question: "Зерно", correctAnswer: "Grain", allAnswers: ["Rain", "Brain", "Again", "Grain"]))
        resultArray.append(ForthLevelQuestion(question: "Суровый человек", correctAnswer: "Harsh man", allAnswers: ["Harsh man", "Noble man", "Evil man", "Poor man"]))
        resultArray.append(ForthLevelQuestion(question: "Ненависть", correctAnswer: "Hate", allAnswers: ["Hat", "Hate", "Gate", "Heat"]))
        resultArray.append(ForthLevelQuestion(question: "Помощь", correctAnswer: "Help", allAnswers: ["Hell", "Enemy", "Help", "Unity"]))
        resultArray.append(ForthLevelQuestion(question: "Скрытый", correctAnswer: "Hidden", allAnswers: ["Broken", "Inner", "Wide", "Hidden"]))
        resultArray.append(ForthLevelQuestion(question: "Я бросил", correctAnswer: "I dropped", allAnswers: ["I dropped", "I finished", "I found", "I stole"]))
        resultArray.append(ForthLevelQuestion(question: "Я благодарю", correctAnswer: "I thanks", allAnswers: ["I think", "I thanks", "I sink", "I feel"]))
        resultArray.append(ForthLevelQuestion(question: "Счет", correctAnswer: "Invoice", allAnswers: ["In voice", "Influence", "Invoice", "Choice"]))
        resultArray.append(ForthLevelQuestion(question: "Недоступен", correctAnswer: "Is not avaliable", allAnswers: ["Impossible", "Invisible", "Unacceptable", "Is not avaliable"]))
        resultArray.append(ForthLevelQuestion(question: "Начинается", correctAnswer: "It begins", allAnswers: ["It begins", "It ends", "It continues", "It begging"]))
        resultArray.append(ForthLevelQuestion(question: "Радость", correctAnswer: "Joy", allAnswers: ["Joke", "Joy", "Finger", "Boy"]))
        resultArray.append(ForthLevelQuestion(question: "Убить", correctAnswer: "Kill", allAnswers: ["Ill", "Skill", "Kill", "Bill"]))
        resultArray.append(ForthLevelQuestion(question: "Хаос", correctAnswer: "Mayhem", allAnswers: ["Greed", "Ability", "Beauty", "Mayhem"]))
        resultArray.append(ForthLevelQuestion(question: "Поляна", correctAnswer: "Meadow", allAnswers: ["Meadow", "Window", "Shadow", "Widow"]))
        resultArray.append(ForthLevelQuestion(question: "Моя мать", correctAnswer: "My mom", allAnswers: ["My wife", "My mom", "My granny", "My niece"]))
        resultArray.append(ForthLevelQuestion(question: "Следующий", correctAnswer: "Next", allAnswers: ["Last", "First", "Next", "Previous"]))
        resultArray.append(ForthLevelQuestion(question: "Неродной", correctAnswer: "Non-native", allAnswers: ["Fake", "Inexpert", "Unique", "Non-native"]))
        resultArray.append(ForthLevelQuestion(question: "Старик", correctAnswer: "Old man", allAnswers: ["Old man", "Retirement", "Experience", "Dinosaur"]))
        resultArray.append(ForthLevelQuestion(question: "Открытый", correctAnswer: "Outright", allAnswers: ["Closed", "Outright", "Honest", "Cheated"]))
        resultArray.append(ForthLevelQuestion(question: "Изображать", correctAnswer: "Portray", allAnswers: ["Praise", "Swear", "Portray", "Wrap"]))
        resultArray.append(ForthLevelQuestion(question: "Прыжок", correctAnswer: "Pounce", allAnswers: ["Strike", "Once", "Silence", "Pounce"]))
        resultArray.append(ForthLevelQuestion(question: "Передышка", correctAnswer: "Respite", allAnswers: ["Respite", "Spite", "Silence", "Resort"]))
        resultArray.append(ForthLevelQuestion(question: "Возмездие", correctAnswer: "Retribution", allAnswers: ["Retake", "Retribution", "Tribe", "Upgrade"]))
        resultArray.append(ForthLevelQuestion(question: "Подъем", correctAnswer: "Rise", allAnswers: ["Wisdom", "Dice", "Rise", "Advice"]))
        resultArray.append(ForthLevelQuestion(question: "Второй", correctAnswer: "Second", allAnswers: ["First", "Third", "Last", "Second"]))
        resultArray.append(ForthLevelQuestion(question: "Семь", correctAnswer: "Seven", allAnswers: ["Seven", "Six", "Hundred", "Family"]))
        resultArray.append(ForthLevelQuestion(question: "Космический корабль", correctAnswer: "Spaceship", allAnswers: ["Satellite", "Spaceship", "Earth", "Missile"]))
        resultArray.append(ForthLevelQuestion(question: "Захватывающий", correctAnswer: "Spectacular", allAnswers: ["Spectacle", "Spectrum", "Spectacular", "Abstract"]))
        resultArray.append(ForthLevelQuestion(question: "Пятно", correctAnswer: "Stain", allAnswers: ["Pain", "Rain", "Dot", "Stain"]))
        resultArray.append(ForthLevelQuestion(question: "Стоять", correctAnswer: "Stand", allAnswers: ["Stand", "Land", "Band", "Sand"]))
        resultArray.append(ForthLevelQuestion(question: "Звезда", correctAnswer: "Star", allAnswers: ["Satellite", "Star", "Comet", "Moon"]))
        resultArray.append(ForthLevelQuestion(question: "Хитрость", correctAnswer: "Stealth", allAnswers: ["Luck", "Envy", "Stealth", "Innocence"]))
        resultArray.append(ForthLevelQuestion(question: "Плита", correctAnswer: "Stove", allAnswers: ["Lake", "Glove", "Dove", "Stove"]))
        resultArray.append(ForthLevelQuestion(question: "Море", correctAnswer: "Sea", allAnswers: ["Sea", "Creek", "River", "Bay"]))
        resultArray.append(ForthLevelQuestion(question: "Толстый", correctAnswer: "Thick", allAnswers: ["Thin", "Thick", "Clever", "Push"]))
        resultArray.append(ForthLevelQuestion(question: "Думать", correctAnswer: "Think", allAnswers: ["Drink", "Speak", "Think", "Write"]))
        resultArray.append(ForthLevelQuestion(question: "Горло", correctAnswer: "Throat", allAnswers: ["Boat", "Liver", "Poison", "Throat"]))
        resultArray.append(ForthLevelQuestion(question: "Толчок", correctAnswer: "Thrust", allAnswers: ["Thrust", "Dust", "Laugh", "Crunch"]))
        resultArray.append(ForthLevelQuestion(question: "Паять", correctAnswer: "Tinker", allAnswers: ["Steal", "Tinker", "Explode", "Break"]))
        resultArray.append(ForthLevelQuestion(question: "Разрушать", correctAnswer: "Destroy", allAnswers: ["Come", "Deceive", "Destroy", "Pretend"]))
        resultArray.append(ForthLevelQuestion(question: "Инструмент", correctAnswer: "Tool", allAnswers: ["Instruction", "Hammer", "Body", "Tool"]))
        resultArray.append(ForthLevelQuestion(question: "Мусор", correctAnswer: "Trash", allAnswers: ["Trash", "Crash", "Slash", "Smash"]))
        resultArray.append(ForthLevelQuestion(question: "Украина", correctAnswer: "Ukraine", allAnswers: ["Hungary", "Ukraine", "Uganda", "Freetown"]))
        resultArray.append(ForthLevelQuestion(question: "Ласка", correctAnswer: "Weasel", allAnswers: ["Hamster", "Beaver", "Weasel", "Fox"]))
        resultArray.append(ForthLevelQuestion(question: "Лесной пожар", correctAnswer: "Wildfire", allAnswers: ["Bonfire", "Pharos", "Torch", "Wildfire"]))
        resultArray.append(ForthLevelQuestion(question: "Перед", correctAnswer: "Before", allAnswers: ["Before", "After", "While", "Now"]))
        resultArray.append(ForthLevelQuestion(question: "Жадный", correctAnswer: "Greedy", allAnswers: ["Cozy", "Greedy", "Beautiful", "Naughty"]))
        resultArray.append(ForthLevelQuestion(question: "Серый", correctAnswer: "Gray", allAnswers: ["White", "Green", "Gray", "Black"]))
        resultArray.append(ForthLevelQuestion(question: "Повернуть", correctAnswer: "Rotate", allAnswers: ["Swipe", "Light", "Blink", "Rotate"]))
        resultArray.append(ForthLevelQuestion(question: "Получить", correctAnswer: "Earn", allAnswers: ["Earn", "Burn", "Return", "Freeze"]))
        resultArray.append(ForthLevelQuestion(question: "Конкурс", correctAnswer: "Contest", allAnswers: ["Contempt", "Contest", "Contact", "Vision"]))
        resultArray.append(ForthLevelQuestion(question: "Ответственный", correctAnswer: "Responsible", allAnswers: ["Interesting", "Handsome", "Responsible", "Extraordinary"]))
        resultArray.append(ForthLevelQuestion(question: "Бабочка", correctAnswer: "Butterfly", allAnswers: ["Bee", "Firefly", "Worm", "Butterfly"]))
        resultArray.append(ForthLevelQuestion(question: "Невеста", correctAnswer: "Bride", allAnswers: ["Bride", "Glide", "Pride", "Fly"]))
        resultArray.append(ForthLevelQuestion(question: "Внутренний", correctAnswer: "Inner", allAnswers: ["Broken", "Inner", "Hidden", "Wide"]))
        resultArray.append(ForthLevelQuestion(question: "Влияние", correctAnswer: "Influence", allAnswers: ["In voice", "Invoice", "Influence", "Choice"]))
        resultArray.append(ForthLevelQuestion(question: "Жадность", correctAnswer: "Greed", allAnswers: ["Mayhem", "Ability", "Beauty", "Greed"]))
        resultArray.append(ForthLevelQuestion(question: "Вдова", correctAnswer: "Widow", allAnswers: ["Widow", "Window", "Shadow", "Meadow"]))
        resultArray.append(ForthLevelQuestion(question: "Уникальный", correctAnswer: "Unique", allAnswers: ["Fake", "Unique", "Inexpert", "Non-native"]))
        resultArray.append(ForthLevelQuestion(question: "Хвалить", correctAnswer: "Praise", allAnswers: ["Portray", "Swear", "Praise", "Wrap"]))
        resultArray.append(ForthLevelQuestion(question: "Боль", correctAnswer: "Pain", allAnswers: ["Stain", "Rain", "Dot", "Pain"]))
        resultArray.append(ForthLevelQuestion(question: "Спутник", correctAnswer: "Satellite", allAnswers: ["Satellite", "Star", "Comet", "Moon"]))
        resultArray.append(ForthLevelQuestion(question: "Зависть", correctAnswer: "Envy", allAnswers: ["Luck", "Envy", "Stealth", "Innocence"]))
        resultArray.append(ForthLevelQuestion(question: "Печень", correctAnswer: "Liver", allAnswers: ["Boat", "Throat", "Liver", "Poison"]))
        resultArray.append(ForthLevelQuestion(question: "Взрывать", correctAnswer: "Explode", allAnswers: ["Steal", "Tinker", "Break", "Explode"]))
        resultArray.append(ForthLevelQuestion(question: "Авария", correctAnswer: "Crash", allAnswers: ["Crash", "Trash", "Slash", "Smash"]))
        resultArray.append(ForthLevelQuestion(question: "Хомяк", correctAnswer: "Hamster", allAnswers: ["Weasel", "Hamster", "Beaver", "Fox"]))
        resultArray.append(ForthLevelQuestion(question: "Факел", correctAnswer: "Torch", allAnswers: ["Bonfire", "Pharos", "Torch", "Wildfire"]))
        
        
        
        return resultArray
        
    }
    
}
