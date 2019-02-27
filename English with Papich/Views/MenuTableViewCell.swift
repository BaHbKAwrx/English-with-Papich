//
//  MenuTableViewCell.swift
//  English with Papich
//
//  Created by Shmygovskii Ivan on 07.01.19.
//  Copyright © 2019 Shmygovskii Ivan. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var incorrectLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWith(bgImage: UIImage, level: String, description: String, corrAnswers: String, incorrAnswers: String) {
        
        self.bgImage.image = bgImage
        self.levelLabel.text = level
        self.descriptionLabel.text = description
        self.correctLabel.text = corrAnswers
        self.incorrectLabel.text = incorrAnswers
        
    }

}
