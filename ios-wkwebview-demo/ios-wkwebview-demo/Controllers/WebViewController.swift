//
//  WebViewController.swift
//  ios-wkwebview-demo
//
//  Created by OkuderaYuki on 2017/11/29.
//  Copyright © 2017年 OkuderaYuki. All rights reserved.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    private var webView: WKWebView!

    // MARK: - View life cycle

    override func loadView() {

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self

        // スワイプで戻るまたは進むを許可
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Private

    private func setup() {

//        load(urlString: "https://www.apple.com")

        // ローカルのdemo.htmlをロードする
        if let path = Bundle.main.path(forResource: "demo", ofType: "html") {
            load(filePath: path)
        }
    }

    /// URLを指定してWKWebViewでロードする
    ///
    /// - Parameter urlString: URL
    private func load(urlString: String) {

        guard let url = URL(string: urlString) else {
            return
        }
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
    }

    /// FilePathを指定してローカルファイルをWKWebViewでロードする
    ///
    /// - Parameter filePath: FilePath
    private func load(filePath: String) {

        let fileUrl = URL(fileURLWithPath: filePath)
        webView.loadFileURL(fileUrl, allowingReadAccessTo: fileUrl)
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {

    /// 新しいウィンドウ、フレームを指定してコンテンツを開く時
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webViewDidClose(_ webView: WKWebView) {
        
    }

    /// JSのalert実行時
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Swift.Void) {

        print("runJavaScriptAlertPanelWithMessage")
        // JSのalertから渡されたメッセージをUIAlertControllerで表示
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: completionHandler)
    }

    /// JSのconfirm実行時
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Swift.Void) {

    }

    /// JSのprompt実行時
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Swift.Void) {

    }

    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {

        return true
    }

    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {

        return self
    }

    func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {

    }
}

// MARK: - WKNavigationDelegate (ロード処理)
extension WebViewController: WKNavigationDelegate {

    /// ページ遷移前
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // 読み込む
        decisionHandler(.allow)
//        // キャンセル
//        decisionHandler(.cancel)
    }

    /// 読み込み開始時
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("読み込み開始")

    }

    /// 読み込み完了時
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("読み込み完了")
    }

    /// 読み込み失敗
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("読み込み失敗")
    }
}
