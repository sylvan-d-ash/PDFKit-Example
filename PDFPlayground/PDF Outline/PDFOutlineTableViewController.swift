//
//  PDFOutlineTableViewController.swift
//  PDFPlayground
//
//  Created by Sylvan Ash on 22/08/2019.
//  Copyright © 2019 Sylvan Ash. All rights reserved.
//

import UIKit
import PDFKit


// MARK: - PDFOutlineTableViewControllerDelegate


protocol PDFOutlineTableViewControllerDelegate {
    func outlineTableViewControllerDidSelect(pdfOutline: PDFOutline)
}


// MARK: - PDFOutlineTableViewController


class PDFOutlineTableViewController: UITableViewController {

    // MARK: - Init


    static func initFromStoryboard() -> PDFOutlineTableViewController {
        let storyboard = UIStoryboard(name: "main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(PDFOutlineTableViewController.self)") as! PDFOutlineTableViewController

        return viewController
    }


    // MARK: - Properties


    var pdfOutlineRoot: PDFOutline!
    var delegate: PDFOutlineTableViewControllerDelegate?
    private var outlineArray: [PDFOutline] = []
    private let reuseIdentifier = PDFOutlineCell.reuseIdentifier


    // MARK: - View Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()

        // generate array of index objects
        for index in 0..<self.pdfOutlineRoot.numberOfChildren {
            guard let pdfOutline = self.pdfOutlineRoot.child(at: index) else { return }

            pdfOutline.isOpen = false
            self.outlineArray.append(pdfOutline)
        }

        // register nib
        self.tableView.register(UINib(nibName: "\(PDFOutlineCell.self)", bundle: nil), forCellReuseIdentifier: self.reuseIdentifier)
        // reload table
        self.tableView.reloadData()
    }


    // MARK: - IBActions


    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


    // MARK: - UITableViewDataSource


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.outlineArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let pdfOutline = self.outlineArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! PDFOutlineCell

        // label
        cell.outlineLabel.text = pdfOutline.label
        // page number
        cell.pageNumberLabel.text = pdfOutline.destination?.page?.label

        // image for open button
        if pdfOutline.numberOfChildren > 0 {
            let image = pdfOutline.isOpen ? UIImage(named: "arrow_down") : UIImage(named: "arrow_right")
            cell.openButton.setImage(image, for: .normal)
            cell.openButton.isEnabled = true
        }
        else {
            cell.openButton.setImage(nil, for: .normal)
            cell.openButton.isEnabled = false
        }

        // action for open button
        cell.openButton.tag = indexPath.row
        cell.openButton.addTarget(self, action: #selector(openButtonAction), for: .touchUpInside)

        return cell
    }

    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let pdfOutline = self.outlineArray[indexPath.row]
        return self.findDepth(of: pdfOutline)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }


    // MARK: - UITableViewDelegate


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pdfOutline = self.outlineArray[indexPath.row]
        self.delegate?.outlineTableViewControllerDidSelect(pdfOutline: pdfOutline)
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Private Extension


private extension PDFOutlineTableViewController {
    @objc
    func openButtonAction(_ sender: UIButton) {

        let button = sender
        button.isSelected = !button.isSelected

        let index = sender.tag
        let pdfOutline = self.outlineArray[index]

        guard pdfOutline.numberOfChildren > 0 else { return }

        if button.isSelected {
            pdfOutline.isOpen = true
            self.insertChild(from: pdfOutline)
        }
        else {
            pdfOutline.isOpen = false
            self.removeChild(from: pdfOutline)
        }

        self.outlineArray[index] = pdfOutline
        self.tableView.reloadData()
    }

    func insertChild(from parentOutline: PDFOutline) {

        guard let baseIndex = self.outlineArray.firstIndex(of: parentOutline) else { return }

        var childOutlineArray: [PDFOutline] = []
        for index in 0..<parentOutline.numberOfChildren {
            guard let pdfOutline = parentOutline.child(at: index) else { return }
            pdfOutline.isOpen = false
            childOutlineArray.append(pdfOutline)
        }

        let indexes = NSIndexSet(indexesIn: NSRange(location: baseIndex + 1, length: childOutlineArray.count))
        for (childIndex, insertionIndex) in indexes.enumerated() {
            let child = childOutlineArray[childIndex]
            self.outlineArray.insert(child, at: insertionIndex)
        }
    }

    func removeChild(from parentOutline: PDFOutline) {

        guard parentOutline.numberOfChildren > 0 else { return }

        for index in 0..<parentOutline.numberOfChildren {
            guard let node = parentOutline.child(at: index) else { continue }
            if node.numberOfChildren > 0 {
                self.removeChild(from: node)

                guard self.outlineArray.contains(node), let nodeIndex = self.outlineArray.firstIndex(of: node) else { return }
                self.outlineArray.remove(at: nodeIndex)
            }
            else {
                guard self.outlineArray.contains(node), let nodeIndex = self.outlineArray.firstIndex(of: node) else { return }
                self.outlineArray.remove(at: nodeIndex)
            }
        }
    }

    func findDepth(of pdfOutline: PDFOutline) -> Int {

        var depth = -1
        var tempOutline: PDFOutline? = pdfOutline

        while tempOutline?.parent != nil {
            depth += 1
            tempOutline = tempOutline?.parent
        }

        return depth
    }
}
