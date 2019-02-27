//
//  AftergameViewController.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 09.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit
import AVFoundation

class AftergameViewController: UIViewController {
    
    // MARK: - Const and vars declaration
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var motivationLabel: UILabel!
    @IBOutlet weak var aftergameImageView: UIImageView!
    
    var player: AVAudioPlayer!
    
    var correctAnswers = 0
    var soundName = ""
    
    let textArray = ["Try better!", "Good job!", "О, Вы из Англии!", "Олды на месте!"]
    let imagesArray = [UIImage(named: "zachto"), UIImage(named: "roflan"), UIImage(named: "dovolen"), UIImage(named: "old")]
    let soundNamesArray = ["добрый почонтек", "изи катка", "Чемпион зверей и людей", "опыт 10+ лет"]

    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aftergameImageView.transform = CGAffineTransform(scaleX: 0, y: 0)

        switch correctAnswers {
        case 0,5,6,7,8,9,10:
            scoreLabel.text = "\(correctAnswers) вопросов из 10"
        case 1:
            scoreLabel.text = "\(correctAnswers) вопрос из 10"
        case 2,3,4:
            scoreLabel.text = "\(correctAnswers) вопроса из 10"
        default:
            scoreLabel.text = "10 вопросов из 10"
        }
        
        switch correctAnswers {
        case 0...4:
            configureResult(withText: textArray[0], withImage: imagesArray[0] ?? UIImage(), withSound: soundNamesArray[0])
        case 5...6:
            configureResult(withText: textArray[1], withImage: imagesArray[1] ?? UIImage(), withSound: soundNamesArray[1])
        case 7...8:
            configureResult(withText: textArray[2], withImage: imagesArray[2] ?? UIImage(), withSound: soundNamesArray[2])
        case 9...10:
            configureResult(withText: textArray[3], withImage: imagesArray[3] ?? UIImage(), withSound: soundNamesArray[3])
        default:
            configureResult(withText: textArray[3], withImage: imagesArray[3] ?? UIImage(), withSound: soundNamesArray[3])
        }

        // Sound
        let fileUrl = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        guard let file_Url = fileUrl else { return }
        do {
            player = try AVAudioPlayer.init(contentsOf: file_Url)
        } catch {
            print(error.localizedDescription)
        }
        player.play()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        animateImage()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func configureResult(withText text: String, withImage image: UIImage, withSound sound: String) {
        
        motivationLabel.text = text
        aftergameImageView.image = image
        soundName = sound
        
    }
    
    func animateImage() {
        
        UIView.animate(withDuration: 0.4) {[weak self] in
            self?.aftergameImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
    }

}
