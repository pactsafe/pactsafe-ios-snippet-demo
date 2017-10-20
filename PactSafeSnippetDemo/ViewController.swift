//
//  ViewController.swift
//  PactSafeSnippetDemo
//
//  Created by PactSafe on 10/20/17.
//  Copyright © 2017 PactSafe. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var signerIdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loadPactSafeView(_ sender: UIButton) {
        
        signerIdField.endEditing(true)
        let signerId = (signerIdField.text != "") ? signerIdField.text! : "ios-test-id"
        
        var webConfig:WKWebViewConfiguration {
            get {
                let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
                
                // Setup WKUserContentController instance for injecting user script
                let userController:WKUserContentController = WKUserContentController()
                userController.add(self, name: "callbackHandler")
                
                // Execute script on the webview to set the signer_id
                let source = "_ps('set', 'signer_id', '\(signerId)');"
                let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                userController.addUserScript(script);
                
                webCfg.userContentController = userController;
                return webCfg;
            }
        }
        
        let pactsafeOverlayFrame = CGRect(x: 40, y: 40, width: (view.frame.width - 80), height: (view.frame.height - 80))
        webView = WKWebView(frame: pactsafeOverlayFrame, configuration: webConfig)
        webView.navigationDelegate = self
        webView.layer.cornerRadius = 8;
        webView.layer.masksToBounds = true;
        view.addSubview(webView)
        
        // Set this to the URL of your group
        let myURL = URL(string: "https://d4077554.ngrok.io/clickwrap-dev-ios-demo.html")
        let myRequest = URLRequest(url: myURL!)
        
        // Clear the cached data
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        
        webView.load(myRequest)
        webView.alpha = 0;
        UIView.animate(withDuration: 0.5, animations: {
            self.webView.alpha = 1;
        })
    }
    
    // WKScriptMessageHandler Delegate
    // This gets called from the webkit.messageHandlers.callbackHandler.postMessage("agreed"); javascript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body as! String == "agreed" {
            let alert = UIAlertController(title: "Alert", message: "Agreed to group!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.webView.alpha = 0;
        }, completion: { (finished: Bool) in
            self.webView.removeFromSuperview()
        })
    }
    
    // WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Follow links we click on inside of the overlay
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return decisionHandler(.cancel)
            }
        }
        return decisionHandler(.allow)
    }
}

