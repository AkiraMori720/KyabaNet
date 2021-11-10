//
//  SettingViewController.swift
//  Life
//
//  Created by Yun Li on 2020/6/26.
//  Copyright © 2020 Yun Li. All rights reserved.
//

import UIKit
import RealmSwift
import FittedSheets
class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    let sections = ["一般設定"]
    
    let items = [
        "アカウント",
        "Zed Pay",
        "プライバシーポリシー",
        "利用規約"
    ]
    
    let icons = [
        UIImage(named: "setting_account"),
        UIImage(named: "ic_zed_pay"),
        UIImage(named: "setting_privacy"),
        UIImage(named: "setting_about")
    ]
    
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SettingCellHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: SettingCellHeader.reuseIdentifier)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func onSignoutTapped(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "サインアウトする", message: "本当にサインアウトしますか？", preferredStyle: .alert)

        refreshAlert.addAction(UIAlertAction(title: "はい", style: .default, handler: { (action: UIAlertAction!) in
            
            DispatchQueue.main.async {
                Persons.update(lastTerminate: Date().timestamp())
                Persons.update(oneSignalId: "")
                AuthUser.signOut { (error) in
                    if error != nil {
                        return
                    }
                    PrefsManager.setEmail(val: "")
                    self.gotoWelcomeViewController()
                }
            }
        }))

        refreshAlert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func gotoWelcomeViewController() {
        let mainstoryboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "rootNavigationViewController")
        UIApplication.shared.windows.first?.rootViewController = vc
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingCell
        cell.selectionStyle = .none
        cell.title.text = items[indexPath.row]
        cell.profile.image = icons[indexPath.row]
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SettingCellHeader") as! SettingCellHeader

        headerView.headerTitle.text = sections[section]

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            if let viewController = storyboard?.instantiateViewController(identifier: "accountSettingsVC") as? AccountSettingsViewController {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        else if indexPath.row == 1 {
            let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
            stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
            let stripeCustomer = stripeCustomers.first
            if(stripeCustomer == nil){
                let vc =  self.storyboard?.instantiateViewController(identifier: "createCustomerVC") as! CreateCustomerViewController
                let sheetController = SheetViewController(controller: vc, sizes: [.fixed(360)])
                self.present(sheetController, animated: false, completion: nil)
            }
            else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "zedPaySettingsVC") as! ZEDPaySettingsViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }else if indexPath.row == 2{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyEulaVC") as! PrivacyEulaVC
            vc.privacy = true
            navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyEulaVC") as! PrivacyEulaVC
            vc.privacy = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
