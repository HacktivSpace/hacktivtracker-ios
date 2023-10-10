//
//  HomeTableViewCell.swift
//  TimeTrack
//
//  Created by Jigmet stanzin Dadul on 14/08/23.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerNotes: UILabel!
    @IBOutlet weak var timerImage: UILabel!
    @IBOutlet weak var timerCategoryButton: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
