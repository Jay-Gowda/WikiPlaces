//
//  LocationItemTableViewCell.swift
//  WikiPlaces
//
//  Created by Jayanth Gowda on 21/04/24.
//

import UIKit

class LocationItemTableViewCell: UITableViewCell, CellIdentifier {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
