//
//  ViewController.swift
//  PactSafeSnippetDemo
//
//  Created by PactSafe on 10/20/17.
//  Copyright © 2017 PactSafe. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    @IBOutlet weak var signerIdField: UITextField!
    
    var webConfig:WKWebViewConfiguration {
        get {
            
            // Create WKWebViewConfiguration instance
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            
            // Setup WKUserContentController instance for injecting user script
            let userController:WKUserContentController = WKUserContentController()
            userController.add(self, name: "callbackHandler")
            
            webCfg.userContentController = userController;
            return webCfg;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pactsafeOverlayFrame = CGRect(x: 40, y: 40, width: (view.frame.width - 80), height: (view.frame.height - 80))
        webView = WKWebView(frame: pactsafeOverlayFrame, configuration: webConfig)
        
        view.addSubview(webView)
        webView.isHidden = true
    }

    @IBAction func loadPactSafeView(_ sender: UIButton) {
        
        let signerId = (signerIdField.text != "") ? signerIdField.text! : "ios-test-id"
        
        let myURL = URL(string: "https://d4077554.ngrok.io/clickwrap-dev-ios-demo.html?sid=\(signerId)")
        let myRequest = URLRequest(url: myURL!)
        
        // Clear the cached data
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        
        webView.load(myRequest)
        webView.isHidden = false
        webView.alpha = 0;
        UIView.animate(withDuration: 0.5, animations: {
            self.webView.alpha = 1;
        })
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.body as! String == "agreed" {
            let alert = UIAlertController(title: "Alert", message: "Agreed to group!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        webView.isHidden = true
    }
}

