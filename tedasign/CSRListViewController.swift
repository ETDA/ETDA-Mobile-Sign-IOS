//
//  CSRListViewController.swift
//  tedasign
//
//  Created by Pawan Pankhao on 31/1/2565 BE.
//

import UIKit

class CSRListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let userdefaults = UserDefaults.standard
    var csrList: [CSRInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "รายการ CSR"
        self.navigationItem.backButtonDisplayMode = .minimal
        self.tableView.delegate = self
        self.tableView.dataSource = self
        csrList = getAllCSRInfo()
    }
    
    @IBAction func createCSRBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateCSRViewController") as! CreateCSRViewController;
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getAllCSRInfo() -> [CSRInfo]{
        if self.userdefaults.data(forKey:"allCSR") != nil {
            let encodedArray = self.userdefaults.data(forKey:"allCSR")
            var decodedArray = NSKeyedUnarchiver.unarchiveObject(with: encodedArray!) as! [CSRInfo]
            print("found allCSR = \(decodedArray)")
            return decodedArray
        }else{
            print("not found allCSR in userdefaults")
        }
        return []
    }
    
    // *begin* for .cer
    
    private func documentFromURL(pickedURL: URL) {
        let data : NSData = NSData(contentsOf: pickedURL)!
        var dataString = String(data: data as Data, encoding: .utf8)
        print(dataString)
        getIdentityCer(certStr: dataString!)
    }

    public func getIdentityCer(certStr: String) {
        let offset = ("-----BEGIN CERTIFICATE-----").count
        let index = certStr.index(certStr.startIndex, offsetBy: offset+1)
        var cerStr = certStr.substring(from: index)
        let tailWord = "-----END CERTIFICATE-----"
        if let lowerBound = cerStr.range(of: tailWord)?.lowerBound {
            cerStr = cerStr.substring(to: lowerBound)
            print(cerStr)
            let data = NSData(base64Encoded: cerStr,
                              options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
            let cert = SecCertificateCreateWithData(kCFAllocatorDefault, data)
            print(cert)
            let publicKey = SecCertificateCopyKey(cert!)!
            print(publicKey)
        }
    }
    
    // *end* for .cer
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return csrList!.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "csrCell", for: indexPath) as? CSRCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = csrList![indexPath.row].name
        cell.certLabel.text = csrList![indexPath.row].certStatusString()
        cell.chainLabel.text = csrList![indexPath.row].chainStatusString()
        cell.dateLabel.text = csrList![indexPath.row].mediumDateString()
        cell.fileNameLabel.text = csrList![indexPath.row].fileName
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let url  = URL(string: instagramBNK[indexPath.row]) else {
//            return
//        }
//
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.openURL(url)
//        }
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
