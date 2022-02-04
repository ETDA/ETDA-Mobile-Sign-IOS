//
//  UploadCSRViewController.swift
//  tedasign
//
//  Created by Pawan Pankhao on 28/10/2564 BE.
//

import UIKit
import WebKit

class UploadCSRViewController: UIViewController, WKUIDelegate {

    var webView: WKWebView!
    
    override func loadView() {
            let webConfiguration = WKWebViewConfiguration()
            webView = WKWebView(frame: .zero, configuration: webConfiguration)
            webView.uiDelegate = self
            view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backButtonDisplayMode = .minimal
        self.title = "Upload CSR"
        let myURL = URL(string:"https://uat-ca.inet.co.th/inetra/login")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
