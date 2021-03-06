//
//  PDFPreviewViewController.swift
//  PDFPlayground
//
//  Created by Sylvan Ash on 23/11/2018.
//  Copyright © 2018 Sylvan Ash. All rights reserved.
//

import PDFKit
import QuickLook
import UIKit


class PDFPreviewViewController: UIViewController {


    // MARK: - IBOutlets


    @IBOutlet private weak var pdfContainerView: UIView!


    // MARK: - Properties


    private var pdfView: PDFView!
    private var pdfDocument: PDFDocument!
    private var toolBarActionController: PDFToolBarActionControllerProtocol!


    // MARK: - View LifeCycle


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupToolbar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.preparePDFView(withPageMode: .singlePageContinuous)
    }


    // MARK: - IBActions


    @IBAction private func didTapOutlineButton(_ sender: Any) {
        self.toolBarActionController.showOutlineTable(for: self.pdfDocument, from: sender)
    }

    @IBAction func searchAction(_ sender: Any) {
        self.toolBarActionController.showSearchTable(for: self.pdfDocument, from: sender)
    }


    // MARK: - Setup

    private func setupUI() {
        // set title
        self.title = "Sample.pdf"
    }

    private func preparePDFView(withPageMode displayMode: PDFDisplayMode) {

        // set frame
        self.pdfContainerView.frame = self.view.bounds

        // configure PDFView
        self.pdfView = PDFView(frame: self.pdfContainerView.bounds)
        self.pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin]
        self.pdfView.autoScales = true
        self.pdfView.displayMode = displayMode
        self.pdfView.displayDirection = .vertical
        self.pdfView.maxScaleFactor = 4
        self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
        self.pdfView.zoomIn(self.view)

        // add pdf view to container
        self.pdfContainerView.addSubview(self.pdfView)

        // get pdf url
        guard let url = Bundle.main.url(forResource: "sample", withExtension: "pdf") else {
            return
        }

        // get pdf document and add it to pdf view
        self.pdfDocument = PDFDocument(url: url)
        self.pdfView.document = self.pdfDocument
        self.pdfView.usePageViewController((displayMode == .singlePage ? true : false), withViewOptions: nil)
    }

    private func setupToolbar() {
        self.toolBarActionController = PDFToolBarActionController(pdfPreviewViewController: self)
    }

}


// MARK:- Selection functions


extension PDFPreviewViewController {
    /// Jump to selected table of contents index
    func didSelect(pdfOutline: PDFOutline) {
        guard let destination = pdfOutline.destination, let page = destination.page else { return }
        self.pdfView.go(to: page)
    }

    /// Jump to selected search text
    func didSelect(pdfSelection: PDFSelection) {
        pdfSelection.color = .yellow
        self.pdfView.currentSelection = pdfSelection
        self.pdfView.go(to: pdfSelection)
    }

}
