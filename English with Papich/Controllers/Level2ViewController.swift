//
//  Level2ViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 09.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import CoreData

class Level2ViewController: UIViewController {
    
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
    var questionsArray = [SecondLevelQuestion]()

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
        
        questionTextLabel.text = questionsArray[questionNumbersArr[questionNumber]].question
        
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
            performSegue(withIdentifier: "afterGameSegue2", sender: self)
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
        performSegue(withIdentifier: "toMenuSegue2", sender: self)
    }
    
    @IBAction func answerButtonTapped(_ sender: UIButton) {
        
        //making buttons unactive
        changeButtonsState(isEnabled: false)
        
        
        if sender.titleLabel?.text == questionsArray[questionNumbersArr[questionNumber]].correctAnswer {
            score += 1
            //Saving to CoreData
            levels[1].correctAnswers += 1
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
            levels[1].incorrectAnswers += 1
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
extension Level2ViewController {
    
    func initAllQuestions() -> [SecondLevelQuestion] {
        
        var resultArray = [SecondLevelQuestion]()
        
        resultArray.append(SecondLevelQuestion(question: "After", correctAnswer: "После", allAnswers: ["После", "До", "Вовремя", "Иногда"]))
        resultArray.append(SecondLevelQuestion(question: "Ascertain", correctAnswer: "Определять", allAnswers: ["Аскорбинка", "Определять", "Занавеска", "Аскет"]))
        resultArray.append(SecondLevelQuestion(question: "Back", correctAnswer: "Назад", allAnswers: ["Черный", "Атаковать", "Назад", "Отсутствие"]))
        resultArray.append(SecondLevelQuestion(question: "Beautiful", correctAnswer: "Красивый", allAnswers: ["Странный", "Красочный", "Невзрачный", "Красивый"]))
        resultArray.append(SecondLevelQuestion(question: "Black", correctAnswer: "Черный", allAnswers: ["Черный", "Белый", "Синий", "Зеленый"]))
        resultArray.append(SecondLevelQuestion(question: "Blink", correctAnswer: "Моргать", allAnswers: ["Клинок", "Моргать", "Соединять", "Упасть"]))
        resultArray.append(SecondLevelQuestion(question: "Burn", correctAnswer: "Жечь", allAnswers: ["Напиток", "Урна", "Выпить", "Жечь"]))
        resultArray.append(SecondLevelQuestion(question: "Check", correctAnswer: "Проверять", allAnswers: ["Проверять", "Чек", "Краснеть", "Заметить"]))
        resultArray.append(SecondLevelQuestion(question: "Clay", correctAnswer: "Глина", allAnswers: ["Мазь", "Глина", "Жидкость", "Напиток"]))
        resultArray.append(SecondLevelQuestion(question: "Consume", correctAnswer: "Потреблять", allAnswers: ["Покупать", "Дарить", "Потреблять", "Примерять"]))
        resultArray.append(SecondLevelQuestion(question: "Contempt", correctAnswer: "Презрение", allAnswers: ["Временный", "Увлечение", "Противостоять", "Презрение"]))
        resultArray.append(SecondLevelQuestion(question: "Continue", correctAnswer: "Продолжать", allAnswers: ["Продолжать", "Контактировать", "Каноничный", "Завершать"]))
        resultArray.append(SecondLevelQuestion(question: "Country", correctAnswer: "Страна", allAnswers: ["Считать", "Страна", "Город", "Республика"]))
        resultArray.append(SecondLevelQuestion(question: "Cozy", correctAnswer: "Уютный", allAnswers: ["Прикольный", "Занятой", "Уютный", "Ленивый"]))
        resultArray.append(SecondLevelQuestion(question: "Cradle", correctAnswer: "Колыбель", allAnswers: ["Молния", "Крокодил", "Вор", "Колыбель"]))
        resultArray.append(SecondLevelQuestion(question: "Extraordinary", correctAnswer: "Необычайный", allAnswers: ["Дополнительный", "Необычайный", "Временный", "Эстрадный"]))
        resultArray.append(SecondLevelQuestion(question: "Finish", correctAnswer: "Закончить", allAnswers: ["Начать", "Продолжать", "Закончить", "Рыба"]))
        resultArray.append(SecondLevelQuestion(question: "Firefly", correctAnswer: "Светлячок", allAnswers: ["Бабочка", "Самолет", "Коровка", "Светлячок"]))
        resultArray.append(SecondLevelQuestion(question: "Forward", correctAnswer: "Вперед", allAnswers: ["Вперед", "Сожалеть", "Вратарь", "Метель"]))
        resultArray.append(SecondLevelQuestion(question: "From me", correctAnswer: "От меня", allAnswers: ["Для меня", "От меня", "Для тебя", "Без меня"]))
        resultArray.append(SecondLevelQuestion(question: "Glide", correctAnswer: "Скользить", allAnswers: ["Невеста", "Гордость", "Скользить", "Летать"]))
        resultArray.append(SecondLevelQuestion(question: "Grain", correctAnswer: "Зерно", allAnswers: ["Дождь", "Мозг", "Опять", "Зерно"]))
        resultArray.append(SecondLevelQuestion(question: "Harsh man", correctAnswer: "Суровый мужик", allAnswers: ["Суровый мужик", "Гордый мужик", "Злой мужик", "Бедный мужик"]))
        resultArray.append(SecondLevelQuestion(question: "Hate", correctAnswer: "Ненависть", allAnswers: ["Шляпа", "Ненависть", "Ворота", "Нагревать"]))
        resultArray.append(SecondLevelQuestion(question: "Help", correctAnswer: "Помощь", allAnswers: ["Ад", "Вражда", "Помощь", "Дружба"]))
        resultArray.append(SecondLevelQuestion(question: "Hidden", correctAnswer: "Скрытый", allAnswers: ["Разбитый", "Внутренний", "Широкий", "Скрытый"]))
        resultArray.append(SecondLevelQuestion(question: "I dropped", correctAnswer: "Я бросил", allAnswers: ["Я бросил", "Я закончил", "Я попал", "Я украл"]))
        resultArray.append(SecondLevelQuestion(question: "I thanks", correctAnswer: "Я благодарю", allAnswers: ["Я думаю", "Я благодарю", "Я тону", "Я считаю"]))
        resultArray.append(SecondLevelQuestion(question: "Invoice", correctAnswer: "Счет", allAnswers: ["В голос", "Влиять", "Счет", "Выбор"]))
        resultArray.append(SecondLevelQuestion(question: "It begins", correctAnswer: "Начинается", allAnswers: ["Начинается", "Заканчивается", "Продолжается", "Умоляет"]))
        resultArray.append(SecondLevelQuestion(question: "Joy", correctAnswer: "Радость", allAnswers: ["Шутка", "Радость", "Палец", "Мальчик"]))
        resultArray.append(SecondLevelQuestion(question: "Kill", correctAnswer: "Убить", allAnswers: ["Болеть", "Умение", "Убить", "Чек"]))
        resultArray.append(SecondLevelQuestion(question: "Mayhem", correctAnswer: "Хаос", allAnswers: ["Жадность", "Возможность", "Красота", "Хаос"]))
        resultArray.append(SecondLevelQuestion(question: "Meadow", correctAnswer: "Поляна", allAnswers: ["Поляна", "Окно", "Тень", "Вдова"]))
        resultArray.append(SecondLevelQuestion(question: "My mom", correctAnswer: "Моя мать", allAnswers: ["Моя жена", "Моя мать", "Моя бабушка", "Моя теща"]))
        resultArray.append(SecondLevelQuestion(question: "Next", correctAnswer: "Следующий", allAnswers: ["Последний", "Первый", "Следующий", "Предыдущий"]))
        resultArray.append(SecondLevelQuestion(question: "Non-native", correctAnswer: "Неродной", allAnswers: ["Ненастоящий", "Неопытный", "Непростой", "Неродной"]))
        resultArray.append(SecondLevelQuestion(question: "Old man", correctAnswer: "Старик", allAnswers: ["Старик", "Работник", "Студент", "Динозавр"]))
        resultArray.append(SecondLevelQuestion(question: "Outright", correctAnswer: "Открытый", allAnswers: ["Закрытый", "Открытый", "Честный", "Обманутый"]))
        resultArray.append(SecondLevelQuestion(question: "Portray", correctAnswer: "Изображать", allAnswers: ["Хвалить", "Ругать", "Изображать", "Сворачивать"]))
        resultArray.append(SecondLevelQuestion(question: "Pounce", correctAnswer: "Прыжок", allAnswers: ["Удар", "Однажды", "Тишина", "Прыжок"]))
        resultArray.append(SecondLevelQuestion(question: "Respite", correctAnswer: "Передышка", allAnswers: ["Передышка", "Злость", "Тишина", "Курорт"]))
        resultArray.append(SecondLevelQuestion(question: "Retribution", correctAnswer: "Возмездие", allAnswers: ["Пересдача", "Возмездие", "Племя", "Улучшение"]))
        resultArray.append(SecondLevelQuestion(question: "Rise", correctAnswer: "Подъем", allAnswers: ["Мудрость", "Кости", "Подъем", "Совет"]))
        resultArray.append(SecondLevelQuestion(question: "Second", correctAnswer: "Второй", allAnswers: ["Первый", "Магазин", "Использованный", "Второй"]))
        resultArray.append(SecondLevelQuestion(question: "Seven", correctAnswer: "Семь", allAnswers: ["Семь", "Шесть", "Сто", "Пять"]))
        resultArray.append(SecondLevelQuestion(question: "Spaceship", correctAnswer: "Космолет", allAnswers: ["Спутник", "Космолет", "Планета", "Ракета"]))
        resultArray.append(SecondLevelQuestion(question: "Spectacular", correctAnswer: "Захватывающий", allAnswers: ["Спектакль", "Спектр", "Захватывающий", "Конспект"]))
        resultArray.append(SecondLevelQuestion(question: "Stain", correctAnswer: "Пятно", allAnswers: ["Боль", "Дождь", "Сухость", "Пятно"]))
        resultArray.append(SecondLevelQuestion(question: "Stand", correctAnswer: "Стоять", allAnswers: ["Стоять", "Земля", "Группа", "Песок"]))
        resultArray.append(SecondLevelQuestion(question: "Star", correctAnswer: "Звезда", allAnswers: ["Старик", "Звезда", "Комета", "Карлик"]))
        resultArray.append(SecondLevelQuestion(question: "Stealth", correctAnswer: "Хитрость", allAnswers: ["Счастье", "Здоровье", "Хитрость", "Простота"]))
        resultArray.append(SecondLevelQuestion(question: "Stove", correctAnswer: "Плита", allAnswers: ["Озеро", "Перчатка", "Голубь", "Плита"]))
        resultArray.append(SecondLevelQuestion(question: "The sea", correctAnswer: "Море", allAnswers: ["Море", "Океан", "Река", "Залив"]))
        resultArray.append(SecondLevelQuestion(question: "Thick", correctAnswer: "Толстый", allAnswers: ["Худой", "Толстый", "Умный", "Нажимать"]))
        resultArray.append(SecondLevelQuestion(question: "Think", correctAnswer: "Думать", allAnswers: ["Пить", "Говорить", "Думать", "Писать"]))
        resultArray.append(SecondLevelQuestion(question: "Throat", correctAnswer: "Горло", allAnswers: ["Лодка", "Печень", "Яд", "Горло"]))
        resultArray.append(SecondLevelQuestion(question: "Thrust", correctAnswer: "Толчок", allAnswers: ["Толчок", "Пыль", "Смех", "Хруст"]))
        resultArray.append(SecondLevelQuestion(question: "Tinker", correctAnswer: "Паять", allAnswers: ["Воровать", "Паять", "Взрывать", "Ломать"]))
        resultArray.append(SecondLevelQuestion(question: "To destroy", correctAnswer: "Разрушать", allAnswers: ["Приезжать", "Обманывать", "Разрушать", "Притворяться"]))
        resultArray.append(SecondLevelQuestion(question: "Tool", correctAnswer: "Инструмент", allAnswers: ["Программа", "Молоток", "Туловище", "Инструмент"]))
        resultArray.append(SecondLevelQuestion(question: "Trash", correctAnswer: "Мусор", allAnswers: ["Мусор", "Вещи", "Союзник", "Авария"]))
        resultArray.append(SecondLevelQuestion(question: "Ukraine", correctAnswer: "Украина", allAnswers: ["Страна", "Украина", "Город", "Украинец"]))
        resultArray.append(SecondLevelQuestion(question: "Weasel", correctAnswer: "Ласка", allAnswers: ["Хомяк", "Бобер", "Ласка", "Лиса"]))
        resultArray.append(SecondLevelQuestion(question: "Wildfire", correctAnswer: "Лесной пожар", allAnswers: ["Костер", "Маяк", "Факел", "Лесной пожар"]))
        resultArray.append(SecondLevelQuestion(question: "Before", correctAnswer: "До", allAnswers: ["До", "После", "Во время", "Иногда"]))
        resultArray.append(SecondLevelQuestion(question: "Strange", correctAnswer: "Странный", allAnswers: ["Красивый", "Странный", "Красочный", "Невзрачный"]))
        resultArray.append(SecondLevelQuestion(question: "Blush", correctAnswer: "Краснеть", allAnswers: ["Чек", "Проверять", "Краснеть", "Заметить"]))
        resultArray.append(SecondLevelQuestion(question: "Liquid", correctAnswer: "Жидкость", allAnswers: ["Мазь", "Глина", "Напиток", "Жидкость"]))
        resultArray.append(SecondLevelQuestion(question: "Temporary", correctAnswer: "Временный", allAnswers: ["Временный", "Презрение", "Увлечение", "Противостоять"]))
        resultArray.append(SecondLevelQuestion(question: "Count", correctAnswer: "Считать", allAnswers: ["Страна", "Считать", "Город", "Республика"]))
        resultArray.append(SecondLevelQuestion(question: "Lazy", correctAnswer: "Ленивый", allAnswers: ["Прикольный", "Занятой", "Ленивый", "Уютный"]))
        resultArray.append(SecondLevelQuestion(question: "Additional", correctAnswer: "Дополнительный", allAnswers: ["Необычайный", "Временный", "Эстрадный", "Дополнительный"]))
        resultArray.append(SecondLevelQuestion(question: "Butterfly", correctAnswer: "Бабочка", allAnswers: ["Бабочка", "Светлячок", "Самолет", "Коровка"]))
        resultArray.append(SecondLevelQuestion(question: "Pride", correctAnswer: "Гордость", allAnswers: ["Невеста", "Гордость", "Скользить", "Летать"]))
        resultArray.append(SecondLevelQuestion(question: "Brain", correctAnswer: "Мозг", allAnswers: ["Дождь", "Зерно", "Мозг", "Опять"]))
        resultArray.append(SecondLevelQuestion(question: "Heat", correctAnswer: "Нагревать", allAnswers: ["Шляпа", "Ворота", "Ненависть", "Нагревать"]))
        resultArray.append(SecondLevelQuestion(question: "Inner", correctAnswer: "Внутренний", allAnswers: ["Внутренний", "Разбитый", "Скрытый", "Широкий"]))
        resultArray.append(SecondLevelQuestion(question: "Joke", correctAnswer: "Шутка", allAnswers: ["Радость", "Шутка", "Палец", "Мальчик"]))
        resultArray.append(SecondLevelQuestion(question: "Greed", correctAnswer: "Жадность", allAnswers: ["Хаос", "Возможность", "Жадность", "Красота"]))
        resultArray.append(SecondLevelQuestion(question: "Widow", correctAnswer: "Вдова", allAnswers: ["Окно", "Тень", "Поляна", "Вдова"]))
        resultArray.append(SecondLevelQuestion(question: "Swear", correctAnswer: "Ругать", allAnswers: ["Ругать", "Хвалить", "Изображать", "Сворачивать"]))
        resultArray.append(SecondLevelQuestion(question: "Resort", correctAnswer: "Курорт", allAnswers: ["Злость", "Курорт", "Тишина", "Передышка"]))
        resultArray.append(SecondLevelQuestion(question: "Wisdom", correctAnswer: "Мудрость", allAnswers: ["Подъем", "Кости", "Мудрость", "Совет"]))
        resultArray.append(SecondLevelQuestion(question: "Satellite", correctAnswer: "Спутник", allAnswers: ["Корабль", "Планета", "Ракета", "Спутник"]))
        resultArray.append(SecondLevelQuestion(question: "Health", correctAnswer: "Здоровье", allAnswers: ["Здоровье", "Счастье", "Хитрость", "Простота"]))
        resultArray.append(SecondLevelQuestion(question: "Poison", correctAnswer: "Яд", allAnswers: ["Лодка", "Яд", "Печень", "Горло"]))
        resultArray.append(SecondLevelQuestion(question: "Dust", correctAnswer: "Пыль", allAnswers: ["Толчок", "Смех", "Пыль", "Хруст"]))
        resultArray.append(SecondLevelQuestion(question: "Crash", correctAnswer: "Авария", allAnswers: ["Вещи", "Союзник", "Мусор", "Авария"]))
        resultArray.append(SecondLevelQuestion(question: "Hamster", correctAnswer: "Хомяк", allAnswers: ["Хомяк", "Ласка", "Бобер", "Лиса"]))
        resultArray.append(SecondLevelQuestion(question: "Bonfire", correctAnswer: "Костер", allAnswers: ["Пожар", "Костер", "Маяк", "Факел"]))
        
        
        return resultArray
        
    }
    
}
