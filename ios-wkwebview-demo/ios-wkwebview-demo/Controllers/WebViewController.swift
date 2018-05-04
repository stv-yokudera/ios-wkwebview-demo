//
//  WebViewController.swift
//  ios-wkwebview-demo
//
//  Created by OkuderaYuki on 2017/11/29.
//  Copyright © 2017年 OkuderaYuki. All rights reserved.
//

import UIKit

final class WebViewController: UIViewController {

    @IBOutlet weak var customView: CustomView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwordButton: UIBarButtonItem!
    @IBOutlet weak var indicetor: UIActivityIndicatorView!

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - IBActions

    @IBAction func didTapBack(_ sender: UIBarButtonItem) {
        customView.webView?.goBack()
    }

    @IBAction func didTapForword(_ sender: UIBarButtonItem) {
        customView.webView?.goForward()
    }

    @IBAction func didTapReload(_ sender: UIBarButtonItem) {
        customView.webView?.reload()
    }

    // MARK: - Private

    private func setup() {

        customView.delegate = self
        load(urlString: "https://github.com/stv-yokudera")

//        // ローカルのdemo.htmlをロードする
//        if let path = Bundle.main.path(forResource: "demo", ofType: "html") {
//            load(filePath: path)
//        }
    }

    /// URLを指定してWKWebViewでロードする
    ///
    /// - Parameter urlString: URL
    private func load(urlString: String) {

        guard let url = URL(string: urlString) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        customView.webView?.load(urlRequest)
    }

    /// FilePathを指定してローカルファイルをWKWebViewでロードする
    ///
    /// - Parameter filePath: FilePath
    private func load(filePath: String) {

        let fileUrl = URL(fileURLWithPath: filePath)
        customView.webView?.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl)
    }

    private func toolbarStatus() {
        backButton.isEnabled = customView.isEnabledBack()
        forwordButton.isEnabled = customView.isEnabledForword()
    }

    private func startIndicetor() {
        indicetor.isHidden = false
        indicetor.startAnimating()
    }

    private func stopIndicetor() {
        indicetor.stopAnimating()
        indicetor.isHidden = true
    }
}

// MARK: - CustomViewDelegate
extension WebViewController: CustomViewDelegate {

    /// WKWebViewのロード処理の状態変更を受け取る
    func didChangeLoadingStatus(status: LoadingStatus) {
        switch status {
        case .started:
            startIndicetor()

        case .finished:
            toolbarStatus()
            stopIndicetor()

        case .occurredError(let error):
            stopIndicetor()
            print("Error: \(error.localizedDescription)")
        }
    }

    /// JavaScriptからalertを実行された時の処理
    func jsAlert(alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }

    /// JavaScriptからconfirmを実行された時の処理
    func jsConfirm(alertController: UIAlertController) {
        present(alertController, animated: true, completion: nil)
    }
}
