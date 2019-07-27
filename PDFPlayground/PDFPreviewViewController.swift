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
    private let documentName: String = "sample.pdf"


    // MARK: - View LifeCycle


    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.preparePDFView(withPageMode: .singlePageContinuous)
    }


    // MARK: - Setup

    private func setupUI() {
        // set title
        self.title = self.documentName
    }

    private var url: URL!
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
        self.pdfView.usePageViewController(true, withViewOptions: nil)
    }
}
