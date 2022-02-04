//
//  CSRCell.swift
//  tedasign
//
//  Created by Pawan Pankhao on 31/1/2565 BE.
//

import UIKit

class CSRCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var certLabel: UILabel!
    @IBOutlet weak var chainLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func updateCerTapped(_ sender: Any) {
        print("update cert for \(String(describing: nameLabel.text))")
    }
    
    @IBAction func updateChainsTapped(_ sender: Any) {
        print("update chains for \(String(describing: nameLabel.text))")
        
    }
}
