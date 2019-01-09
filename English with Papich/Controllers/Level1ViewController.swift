//
//  Level1ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 07.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class Level1ViewController: UIViewController {
    
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
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var forthButton: UIButton!
    
    //CoreData vars
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var levels = [MenuLevel]()
    
    var player: AVAudioPlayer!
    var questionNumber = 0
    var score = 0
    var questionNumbersArr = [Int]()
    var questionsArray = [FirstLevelQuestion]()
    
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
            questionNumber += 1
            firstButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[0], for: .normal)
            secondButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[1], for: .normal)
            thirdButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[2], for: .normal)
            forthButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[3], for: .normal)
            
            // Progress bar add
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = CGFloat(questionNumber)/10
            animation.duration = 0.5
            
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.fillMode = kCAFillModeBoth
            animation.isRemovedOnCompletion = false
            
            overShapeLayer.add(animation, forKey: nil)
            
            
        } else {
            performSegue(withIdentifier: "afterGameSegue", sender: self)
        }
        
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Button actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toMenuSegue", sender: self)
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
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
        if sender.titleLabel?.text == questionsArray[questionNumbersArr[questionNumber]].correctAnswer {
            print("Correct")
            score += 1
            //Saving to CoreData
            levels[0].correctAnswers += 1
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
            levels[0].incorrectAnswers += 1
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
extension Level1ViewController {
    
    func initAllQuestions() -> [FirstLevelQuestion] {
        
        var resultArray = [FirstLevelQuestion]()
        
        resultArray.append(FirstLevelQuestion(sound: "after", correctAnswer: "После", allAnswers: ["После", "До", "Вовремя", "Иногда"]))
        resultArray.append(FirstLevelQuestion(sound: "ascertain", correctAnswer: "Определять", allAnswers: ["Аскорбинка", "Определять", "Занавеска", "Аскет"]))
        resultArray.append(FirstLevelQuestion(sound: "back", correctAnswer: "Назад", allAnswers: ["Черный", "Атаковать", "Назад", "Отсутствие"]))
        resultArray.append(FirstLevelQuestion(sound: "beautiful", correctAnswer: "Красивый", allAnswers: ["Странный", "Красочный", "Невзрачный", "Красивый"]))
        resultArray.append(FirstLevelQuestion(sound: "black", correctAnswer: "Черный", allAnswers: ["Черный", "Белый", "Синий", "Зеленый"]))
        resultArray.append(FirstLevelQuestion(sound: "blink", correctAnswer: "Моргать", allAnswers: ["Клинок", "Моргать", "Соединять", "Упасть"]))
        resultArray.append(FirstLevelQuestion(sound: "bring it all", correctAnswer: "Принеси все", allAnswers: ["Заморозь все", "Окружи все", "Принеси все", "Посмотри на все"]))
        resultArray.append(FirstLevelQuestion(sound: "burn", correctAnswer: "Жечь", allAnswers: ["Напиток", "Урна", "Выпить", "Жечь"]))
        resultArray.append(FirstLevelQuestion(sound: "check", correctAnswer: "Проверять", allAnswers: ["Проверять", "Чек", "Краснеть", "Заметить"]))
        resultArray.append(FirstLevelQuestion(sound: "clay", correctAnswer: "Глина", allAnswers: ["Мазь", "Глина", "Жидкость", "Напиток"]))
        resultArray.append(FirstLevelQuestion(sound: "consume", correctAnswer: "Потреблять", allAnswers: ["Покупать", "Дарить", "Потреблять", "Конспектировать"]))
        resultArray.append(FirstLevelQuestion(sound: "contempt", correctAnswer: "Презрение", allAnswers: ["Временный", "Увлечение", "Противостоять", "Презрение"]))
        resultArray.append(FirstLevelQuestion(sound: "continue", correctAnswer: "Продолжать", allAnswers: ["Продолжать", "Контактировать", "Каноничный", "Завершать"]))
        resultArray.append(FirstLevelQuestion(sound: "country", correctAnswer: "Страна", allAnswers: ["Считать", "Страна", "Город", "Республика"]))
        resultArray.append(FirstLevelQuestion(sound: "cozy", correctAnswer: "Уютный", allAnswers: ["Прикольный", "Занятой", "Уютный", "Ленивый"]))
        resultArray.append(FirstLevelQuestion(sound: "cradle", correctAnswer: "Колыбель", allAnswers: ["Молния", "Крокодил", "Вор", "Колыбель"]))
        resultArray.append(FirstLevelQuestion(sound: "english learning", correctAnswer: "Изучение Английского", allAnswers: ["Изучение Английского", "Чтение на Английском", "Практика Английского", "Английская школа"]))
        resultArray.append(FirstLevelQuestion(sound: "extraordinary", correctAnswer: "Необычайный", allAnswers: ["Дополнительный", "Необычайный", "Временный", "Эстрадный"]))
        resultArray.append(FirstLevelQuestion(sound: "finish", correctAnswer: "Закончить", allAnswers: ["Начать", "Продолжать", "Закончить", "Рыба"]))
        resultArray.append(FirstLevelQuestion(sound: "firefly", correctAnswer: "Светлячок", allAnswers: ["Бабочка", "Самолет", "Коровка", "Светлячок"]))
        
        return resultArray
        
    }
    
}
