//
//  PDFToolbarActionController.swift
//  PDFPlayground
//
//  Created by Sylvan Ash on 22/08/2019.
//  Copyright © 2019 Sylvan Ash. All rights reserved.
//

import Foundation
import PDFKit


// MARK: - PDFToolBarActionControllerProtocol


protocol PDFToolBarActionControllerProtocol: class {
    func showOutlineTable(for pdfDocument: PDFDocument, from sender: Any)
    func showSearchTable(for pdfDocument: PDFDocument, from sender: Any)
}


// MARK: - PDFToolBarActionController


class PDFToolBarActionController: PDFToolBarActionControllerProtocol {

    // MARK: - Init


    private weak var pdfPreviewViewController: PDFPreviewViewController!

    init(pdfPreviewViewController: PDFPreviewViewController) {
        self.pdfPreviewViewController = pdfPreviewViewController
    }


    // MARK: - PDFToolBarActionControllerProtocol


    func showOutlineTable(for pdfDocument: PDFDocument, from sender: Any) {

        guard let pdfOutlineRoot = pdfDocument.outlineRoot else { return }

        let outlineTableViewController = PDFOutlineTableViewController.initFromStoryboard()
        outlineTableViewController.delegate = self
        outlineTableViewController.pdfOutlineRoot = pdfOutlineRoot

        self.present(viewController: outlineTableViewController, from: sender)
    }

    func showSearchTable(for pdfDocument: PDFDocument, from sender: Any) {

        let searchTableViewController = PDFSearchTableViewController.initFromStoryboard()
        searchTableViewController.delegate = self
        searchTableViewController.pdfDocument = pdfDocument

        self.present(viewController: searchTableViewController, from: sender)
    }


    // MARK: - Private


    private func present(viewController: UITableViewController, from sender: Any) {

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem

        self.pdfPreviewViewController.present(navigationController, animated: true, completion: nil)

        navigationController.popoverPresentationController?.permittedArrowDirections = .any
    }

}


// MARK: - PDFOutlineTableViewControllerDelegate


extension PDFToolBarActionController: PDFOutlineTableViewControllerDelegate {
    func outlineTableViewControllerDidSelect(pdfOutline: PDFOutline) {
        self.pdfPreviewViewController.didSelect(pdfOutline: pdfOutline)
    }

}


// MARK: - PDFSearchTableViewControllerDelegate


extension PDFToolBarActionController: PDFSearchTableViewControllerDelegate {
    func searchTableViewControllerDidSelect(pdfSelection: PDFSelection) {
        self.pdfPreviewViewController.didSelect(pdfSelection: pdfSelection)
    }
}
