//
//  CustomView.swift
//  ios-wkwebview-demo
//
//  Created by OkuderaYuki on 2018/05/04.
//  Copyright © 2018年 OkuderaYuki. All rights reserved.
//

import UIKit
import WebKit

enum LoadingStatus {
    case started
    case finished
    case occurredError(Error)
}

protocol CustomViewDelegate: class {
    func didChangeLoadingStatus(status: LoadingStatus)
    func jsAlert(alertController: UIAlertController)
    func jsConfirm(alertController: UIAlertController)
}

final class CustomView: UIView {

    private let headerViewHight: CGFloat = 50.0
    private var scrollingToTop = false
    private var updatingContentOffsetY = false

    weak var delegate: CustomViewDelegate?
    var webView: WKWebView?
    var headerView: UIView?

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView()
    }

    private func setupWebView() {

        webView = WKWebView(frame: .zero, configuration: setupConfiguration())
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        webView?.allowsBackForwardNavigationGestures = true
        addSubview(webView ?? WKWebView())
        setupConstain(webView: self.webView)

        // ヘッダービューをスクロール内に追加
        setHeaderView()
        webView?.scrollView.delegate = self
        webView?.scrollView.bounces = false
    }

    /// Configに設定を加える場合はここで行う
    private func setupConfiguration() -> WKWebViewConfiguration {
        return WKWebViewConfiguration()
    }

    /// Autolayoutを設定（4辺共に0）
    private func setupConstain(webView: WKWebView?) {

        webView?.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[v0]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": webView ?? WKWebView()])
        )
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[v0]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views: ["v0": webView ?? WKWebView()])
        )
    }

    func setHeaderView() {

        headerView?.removeFromSuperview()

        // 画面外に作成
        headerView = UIView(frame: CGRect(x: 0,
                                          y: -headerViewHight,
                                          width: frame.width,
                                          height: headerViewHight))
        headerView?.backgroundColor = UIColor.red
        // スクロール領域の拡張
        webView?.scrollView.contentInset = UIEdgeInsetsMake(headerViewHight, 0, 0, 0)
        webView?.scrollView.addSubview(headerView ?? UIView())
        // スクロール開始位置を変更
        webView?.scrollView.setContentOffset(CGPoint(x: 0, y: -headerViewHight), animated: false)
    }

    func isEnabledBack() -> Bool {
        return webView?.canGoBack ?? false
    }

    func isEnabledForword() -> Bool {
        return webView?.canGoForward ?? false
    }

    /// キャッシュを削除する
    func removeCache() {
        WKWebsiteDataStore
            .default()
            .removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                        modifiedSince: Date(timeIntervalSince1970: 0)) {
                            print("remove all cache.")
        }
    }
}

// MARK: - WKNavigationDelegate (ロード処理)

extension CustomView: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("読み込み開始")
        delegate?.didChangeLoadingStatus(status: .started)
    }

    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        print("読み込み完了")
        print("scrollView: (\(webView.scrollView.contentOffset.x), \(webView.scrollView.contentOffset.y))")
        delegate?.didChangeLoadingStatus(status: .finished)
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print("読み込み中エラー")
        delegate?.didChangeLoadingStatus(status: .occurredError(error))
    }

    func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("通信中のエラー")
        delegate?.didChangeLoadingStatus(status: .occurredError(error))
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 読み込みを許可
        decisionHandler(.allow)
        //        // 読み込みをキャンセル
        //        decisionHandler(.cancel)
    }
}

// MARK: - WKUIDelegate

extension CustomView: WKUIDelegate {

    /// _blank挙動対応
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        guard
            let targetFrame = navigationAction.targetFrame,
            targetFrame.isMainFrame else {
                webView.load(navigationAction.request)
                return nil
        }
        return nil
    }

    /// プレビュー表示の許可
    func webView(_ webView: WKWebView,
                 shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }

    /// display alert dialog
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Swift.Void) {

        print(#function)
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(okAction)

        delegate?.jsAlert(alertController: alertController)
    }

    /// display confirm dialog
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Swift.Void) {

        print(#function)
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        delegate?.jsConfirm(alertController: alertController)
    }
}

// MARK: - UIScrollViewDelegate

extension CustomView: UIScrollViewDelegate {

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollingToTop = true
        return true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollingToTop = false
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        print(#function)

        print("1. scrollView: (\(scrollView.contentOffset.x), \(scrollView.contentOffset.y))")

        // 以下の全てを満たす場合、webView.scrollViewのContentOffsetYを更新する
        // - scrollView内部のドラッグをしていない
        // - ステータスバータップによる一番上へのスクロールをしていない
        // - webView.scrollViewのContentOffsetY更新中でない
        if !scrollView.isDragging && !scrollingToTop && !updatingContentOffsetY {

            updatingContentOffsetY = true

            var newContentOffsetY: CGFloat
            if scrollView.contentOffset.y < 0 {
                newContentOffsetY = -headerViewHight
            } else {
                newContentOffsetY = scrollView.contentOffset.y - headerViewHight
            }

            webView?.scrollView.setContentOffset(CGPoint(x: 0, y: newContentOffsetY), animated: false)
            print("2. scrollView: (\(scrollView.contentOffset.x), \(scrollView.contentOffset.y))")
            
            updatingContentOffsetY = false
        }
    }
}
