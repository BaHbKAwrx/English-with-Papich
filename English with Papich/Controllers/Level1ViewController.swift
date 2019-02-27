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
        
        setStartUI()
        
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let afterGameVC = segue.destination as? AftergameViewController {
            afterGameVC.correctAnswers = score
        }
        
    }
    
    // MARK: - Methods
    func setStartUI() {
        
        firstButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[0], for: .normal)
        secondButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[1], for: .normal)
        thirdButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[2], for: .normal)
        forthButton.setTitle(questionsArray[questionNumbersArr[questionNumber]].allAnswers[3], for: .normal)
        
        correctLabel.alpha = 0
        incorrectLabel.alpha = 0
        
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
            
            //making buttons active
            changeButtonsState(isEnabled: true)
            
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
    
    func changeButtonsState(isEnabled: Bool) {
        
        firstButton.isEnabled = isEnabled
        secondButton.isEnabled = isEnabled
        thirdButton.isEnabled = isEnabled
        forthButton.isEnabled = isEnabled
        
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
        
        //making buttons unactive
        changeButtonsState(isEnabled: false)
        
        
        if sender.titleLabel?.text == questionsArray[questionNumbersArr[questionNumber]].correctAnswer {
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
        resultArray.append(FirstLevelQuestion(sound: "burn", correctAnswer: "Жечь", allAnswers: ["Напиток", "Урна", "Выпить", "Жечь"]))
        resultArray.append(FirstLevelQuestion(sound: "check", correctAnswer: "Проверять", allAnswers: ["Проверять", "Чек", "Краснеть", "Заметить"]))
        resultArray.append(FirstLevelQuestion(sound: "clay", correctAnswer: "Глина", allAnswers: ["Мазь", "Глина", "Жидкость", "Напиток"]))
        resultArray.append(FirstLevelQuestion(sound: "contempt", correctAnswer: "Презрение", allAnswers: ["Временный", "Увлечение", "Противостоять", "Презрение"]))
        resultArray.append(FirstLevelQuestion(sound: "continue", correctAnswer: "Продолжать", allAnswers: ["Продолжать", "Контактировать", "Каноничный", "Завершать"]))
        resultArray.append(FirstLevelQuestion(sound: "country", correctAnswer: "Страна", allAnswers: ["Считать", "Страна", "Город", "Республика"]))
        resultArray.append(FirstLevelQuestion(sound: "cozy", correctAnswer: "Уютный", allAnswers: ["Прикольный", "Занятой", "Уютный", "Ленивый"]))
        resultArray.append(FirstLevelQuestion(sound: "cradle", correctAnswer: "Колыбель", allAnswers: ["Молния", "Крокодил", "Вор", "Колыбель"]))
        resultArray.append(FirstLevelQuestion(sound: "finish", correctAnswer: "Закончить", allAnswers: ["Начать", "Продолжать", "Закончить", "Рыба"]))
        resultArray.append(FirstLevelQuestion(sound: "firefly", correctAnswer: "Светлячок", allAnswers: ["Бабочка", "Самолет", "Коровка", "Светлячок"]))
        resultArray.append(FirstLevelQuestion(sound: "forward", correctAnswer: "Вперед", allAnswers: ["Вперед", "Сожалеть", "Вратарь", "Метель"]))
        resultArray.append(FirstLevelQuestion(sound: "from me", correctAnswer: "От меня", allAnswers: ["Для меня", "От меня", "Для тебя", "Без меня"]))
        resultArray.append(FirstLevelQuestion(sound: "glide", correctAnswer: "Скользить", allAnswers: ["Невеста", "Гордость", "Скользить", "Летать"]))
        resultArray.append(FirstLevelQuestion(sound: "grain", correctAnswer: "Зерно", allAnswers: ["Дождь", "Мозг", "Опять", "Зерно"]))
        resultArray.append(FirstLevelQuestion(sound: "harsh man", correctAnswer: "Суровый мужик", allAnswers: ["Суровый мужик", "Гордый мужик", "Злой мужик", "Бедный мужик"]))
        resultArray.append(FirstLevelQuestion(sound: "hate", correctAnswer: "Ненависть", allAnswers: ["Шляпа", "Ненависть", "Ворота", "Нагревать"]))
        resultArray.append(FirstLevelQuestion(sound: "help", correctAnswer: "Помощь", allAnswers: ["Ад", "Вражда", "Помощь", "Дружба"]))
        resultArray.append(FirstLevelQuestion(sound: "I dropped", correctAnswer: "Я бросил", allAnswers: ["Я бросил", "Я закончил", "Я попал", "Я украл"]))
        resultArray.append(FirstLevelQuestion(sound: "i thanks", correctAnswer: "Я благодарю", allAnswers: ["Я думаю", "Я благодарю", "Я тону", "Я считаю"]))
        resultArray.append(FirstLevelQuestion(sound: "invoice", correctAnswer: "Счет", allAnswers: ["В голос", "Влиять", "Счет", "Выбор"]))
        resultArray.append(FirstLevelQuestion(sound: "is not avaliable", correctAnswer: "Недоступен", allAnswers: ["Невозможен", "Невидимый", "Неприемлемый", "Недоступен"]))
        resultArray.append(FirstLevelQuestion(sound: "it begins", correctAnswer: "Начинается", allAnswers: ["Начинается", "Заканчивается", "Продолжается", "Умоляет"]))
        resultArray.append(FirstLevelQuestion(sound: "joy", correctAnswer: "Радость", allAnswers: ["Шутка", "Радость", "Палец", "Мальчик"]))
        resultArray.append(FirstLevelQuestion(sound: "mayhem", correctAnswer: "Хаос", allAnswers: ["Жадность", "Возможность", "Красота", "Хаос"]))
        resultArray.append(FirstLevelQuestion(sound: "meadow", correctAnswer: "Поляна", allAnswers: ["Поляна", "Окно", "Тень", "Вдова"]))
        resultArray.append(FirstLevelQuestion(sound: "my mom", correctAnswer: "Моя мать", allAnswers: ["Моя жена", "Моя мать", "Моя бабушка", "Моя теща"]))
        resultArray.append(FirstLevelQuestion(sound: "non-native", correctAnswer: "Неродной", allAnswers: ["Ненастоящий", "Неопытный", "Непростой", "Неродной"]))
        resultArray.append(FirstLevelQuestion(sound: "old man", correctAnswer: "Старик", allAnswers: ["Старик", "Работник", "Студент", "Динозавр"]))
        resultArray.append(FirstLevelQuestion(sound: "outright", correctAnswer: "Открытый", allAnswers: ["Закрытый", "Открытый", "Честный", "Обманутый"]))
        resultArray.append(FirstLevelQuestion(sound: "portray", correctAnswer: "Изображать", allAnswers: ["Хвалить", "Ругать", "Изображать", "Сворачивать"]))
        resultArray.append(FirstLevelQuestion(sound: "pounce", correctAnswer: "Прыжок", allAnswers: ["Удар", "Однажды", "Тишина", "Прыжок"]))
        resultArray.append(FirstLevelQuestion(sound: "respite", correctAnswer: "Передышка", allAnswers: ["Передышка", "Злость", "Тишина", "Курорт"]))
        resultArray.append(FirstLevelQuestion(sound: "retribution", correctAnswer: "Возмездие", allAnswers: ["Пересдача", "Возмездие", "Племя", "Улучшение"]))
        resultArray.append(FirstLevelQuestion(sound: "rise", correctAnswer: "Подъем", allAnswers: ["Мудрость", "Кости", "Подъем", "Совет"]))
        resultArray.append(FirstLevelQuestion(sound: "second", correctAnswer: "Второй", allAnswers: ["Первый", "Магазин", "Использованный", "Второй"]))
        resultArray.append(FirstLevelQuestion(sound: "seven", correctAnswer: "Семь", allAnswers: ["Семь", "Шесть", "Сто", "Пять"]))
        resultArray.append(FirstLevelQuestion(sound: "spaceship", correctAnswer: "Космолет", allAnswers: ["Спутник", "Космолет", "Планета", "Ракета"]))
        resultArray.append(FirstLevelQuestion(sound: "stand", correctAnswer: "Стоять", allAnswers: ["Стоять", "Земля", "Группа", "Песок"]))
        resultArray.append(FirstLevelQuestion(sound: "stealth", correctAnswer: "Хитрость", allAnswers: ["Счастье", "Здоровье", "Хитрость", "Простота"]))
        resultArray.append(FirstLevelQuestion(sound: "stove", correctAnswer: "Плита", allAnswers: ["Озеро", "Перчатка", "Голубь", "Плита"]))
        resultArray.append(FirstLevelQuestion(sound: "the sea", correctAnswer: "Море", allAnswers: ["Море", "Океан", "Река", "Залив"]))
        resultArray.append(FirstLevelQuestion(sound: "thick", correctAnswer: "Толстый", allAnswers: ["Худой", "Толстый", "Умный", "Нажимать"]))
        resultArray.append(FirstLevelQuestion(sound: "think", correctAnswer: "Думать", allAnswers: ["Пить", "Говорить", "Думать", "Писать"]))
        resultArray.append(FirstLevelQuestion(sound: "throat", correctAnswer: "Горло", allAnswers: ["Лодка", "Печень", "Яд", "Горло"]))
        resultArray.append(FirstLevelQuestion(sound: "thrust", correctAnswer: "Толчок", allAnswers: ["Толчок", "Пыль", "Смех", "Хруст"]))
        resultArray.append(FirstLevelQuestion(sound: "tinker", correctAnswer: "Паять", allAnswers: ["Воровать", "Паять", "Взрывать", "Ломать"]))
        resultArray.append(FirstLevelQuestion(sound: "tool", correctAnswer: "Инструмент", allAnswers: ["Программа", "Молоток", "Туловище", "Инструмент"]))
        resultArray.append(FirstLevelQuestion(sound: "trash", correctAnswer: "Мусор", allAnswers: ["Мусор", "Вещи", "Союзник", "Авария"]))
        resultArray.append(FirstLevelQuestion(sound: "weasel", correctAnswer: "Ласка", allAnswers: ["Хомяк", "Бобер", "Ласка", "Лиса"]))
        resultArray.append(FirstLevelQuestion(sound: "wildfire", correctAnswer: "Лесной пожар", allAnswers: ["Костер", "Маяк", "Факел", "Лесной пожар"]))

        
        return resultArray
        
    }
    
}
