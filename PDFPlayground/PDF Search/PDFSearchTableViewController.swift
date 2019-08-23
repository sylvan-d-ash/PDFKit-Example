//
//  PDFSearchTableViewController.swift
//  PDFPlayground
//
//  Created by Sylvan Ash on 23/08/2019.
//  Copyright © 2019 Sylvan Ash. All rights reserved.
//

import UIKit
import PDFKit


// MARK: - PDFSearchTableViewControllerDelegate


protocol PDFSearchTableViewControllerDelegate {
    func searchTableViewControllerDidSelect(pdfSelection: PDFSelection)
}


// MARK: - PDFSearchTableViewController


class PDFSearchTableViewController: UITableViewController {

    // MARK: - Init


    static func initFromStoryboard() -> PDFSearchTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(PDFSearchTableViewController.self)") as! PDFSearchTableViewController

        return viewController
    }


    // MARK: - Properties


    var pdfDocument: PDFDocument!
    var delegate: PDFSearchTableViewControllerDelegate?
    private var searchBar: UISearchBar!
    private var searchResultArray: [PDFSelection] = []
    private let reuseIdentifier = PDFOutlineCell.reuseIdentifier


    // MARK: - View Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()

        // tableview
        self.tableView.register(UINib(nibName: "\(PDFSearchCell.self)", bundle: nil), forCellReuseIdentifier: self.reuseIdentifier)

        // search bar
        self.searchBar = UISearchBar(frame: CGRect.zero)
        self.searchBar.delegate = self
        self.searchBar.sizeToFit()
        self.searchBar.searchBarStyle = .minimal
        self.navigationItem.titleView = self.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBar.becomeFirstResponder()
    }


    // MARK: - UITableViewDataSource


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let pdfSelection = self.searchResultArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! PDFSearchCell

        // page number
        let pdfPage = pdfSelection.pages.first
        cell.pageNumberLabel.text = "Page: \(pdfPage?.label ?? "--")"

        // get search results
        let extendSelection = pdfSelection.copy() as! PDFSelection
        extendSelection.extend(atStart: 10)
        extendSelection.extend(atEnd: 90)
        extendSelection.extendForLineBoundaries()
        // highlight searched term
        let range = NSString(string: extendSelection.string ?? "").range(of: pdfSelection.string ?? "", options: .caseInsensitive)
        let attributedString = NSMutableAttributedString(string: extendSelection.string ?? "")
        attributedString.addAttribute(.backgroundColor, value: UIColor.yellow, range: range)
        // display search results
        cell.searchResultLabel.attributedText = attributedString

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }


    // MARK: - UITableViewDelegate


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pdfSelection = self.searchResultArray[indexPath.row]
        self.delegate?.searchTableViewControllerDidSelect(pdfSelection: pdfSelection)
        self.dismiss(animated: true, completion: nil)
    }

}


// MARK: - ScrollView


extension PDFSearchTableViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }

}


// MARK: - PDFDocumentDelegate


extension PDFSearchTableViewController: PDFDocumentDelegate {
    func didMatchString(_ instance: PDFSelection) {
        self.searchResultArray.append(instance)
        self.tableView.reloadData()
    }

}


// MARK: - UISearchBarDelegate


extension PDFSearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.pdfDocument.cancelFindString()
        self.navigationItem.setRightBarButton(nil, animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        guard searchText.count >= 2 else { return }

        self.searchResultArray.removeAll()
        self.tableView.reloadData()
        self.pdfDocument.cancelFindString()
        self.pdfDocument.delegate = self
        self.pdfDocument.beginFindString(searchText, withOptions: .caseInsensitive)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonItemClicked))
        self.navigationItem.setRightBarButton(cancelBarButtonItem, animated: true)
        return true
    }

    @objc
    func cancelBarButtonItemClicked() {
        self.searchBarCancelButtonClicked(self.searchBar)
    }

}
