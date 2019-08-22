//
//  PDFOutlineCell.swift
//  PDFPlayground
//
//  Created by Sylvan Ash on 22/08/2019.
//  Copyright © 2019 Sylvan Ash. All rights reserved.
//

import UIKit


class PDFOutlineCell: UITableViewCell {

    static let reuseIdentifier = "PDFOutlineCell"

    // MARK: - IBOutlets


    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var outlineLabel: UILabel!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var openButtonLeadingConstraint: NSLayoutConstraint!


    // MARK: - View Lifecycle


    override func layoutSubviews() {
        super.layoutSubviews()

        if self.indentationLevel == 0 {
            self.outlineLabel.font = UIFont.systemFont(ofSize: 15)
        }
        else {
            self.outlineLabel.font = UIFont.systemFont(ofSize: 14)
        }

        self.openButtonLeadingConstraint.constant = self.indentationWidth * CGFloat(self.indentationLevel)
    }

}
