//
//  ZedHistoryViewController.swift
//  Life
//
//  Created by mac on 2021/6/18.
//  Copyright © 2021 Zed. All rights reserved.
//

import UIKit
import CryptoSwift
import RealmSwift
import FittedSheets

class ZedHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var person:Person?
    private var tokenTransactions: NotificationToken? = nil
    private var transactions = realm.objects(ZEDPay.self).filter(falsepredicate)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelBalance: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        labelBalance.text = person?.getBalance().moneyString()
        TransactionCell.Register(withTableView: self.tableView)
        self.tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        Persons.update(isBalanceRead: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTransactions()
    }
    
    // MARK: - load transactions
    
    func loadTransactions(){
        let predicate1 = NSPredicate(format: "fromUserId == %@ OR toUserId == %@", AuthUser.userId(), AuthUser.userId())
        //let predicate2 = NSPredicate(format: "NOT status IN %@", [TRANSACTION_STATUS.PENDING] )
        /// fix replace this
        let predicate2 = NSPredicate(format: "status IN %@", [TRANSACTION_STATUS.SUCCESS] )
        
        transactions = realm.objects(ZEDPay.self).filter(predicate1).filter(predicate2).sorted(byKeyPath: "updatedAt", ascending: false)
        //transactions = realm.objects(ZEDPay.self).filter(predicate1).sorted(byKeyPath: "updatedAt", ascending: false)
        tokenTransactions?.invalidate()
        transactions.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenTransactions = token
        })
        
    }
    
    func refreshTableView(){
        self.tableView.reloadData()
    }
    // MARK: - table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count > 0 ? transactions.count : 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(transactions.count > 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.GetCellReuseIdentifier(), for: indexPath) as! TransactionCell
            cell.selectionStyle = .none
            cell.bindData(transaction: transactions[indexPath.row], tableView: tableView, indexPath: indexPath)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "noRecord", for: indexPath) as! NoRecordCell
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(transactions.count == 0){
            return
        }
        
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "detailVC") as! TransactionDetailViewController
        vc.transaction = transactions[indexPath.row]
        self.present(vc, animated: true, completion: nil)

    }

    // MARK: - Cacel Tap
    @IBAction func actionTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Add money tap
    @IBAction func actionTapAddMoney(_ sender: Any) {
        /// just for test
        let predicate = NSPredicate(format: "userId == %@ AND isDeleted == NO", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
        let paymentMethods = realm.objects(PaymentMethod.self).filter(predicate)
        
        if let paymentMethod = paymentMethods.first {
            weak var pvc = self.presentingViewController
            let mainstoryboard = UIStoryboard.init(name: "ZedPay", bundle: nil)
            let vc = mainstoryboard.instantiateViewController(withIdentifier: "addMoneyVC") as! AddMoneyViewController
            vc.paymentMethod = paymentMethod
            vc.updatedelegate = self
            let sheetController = SheetViewController(controller: vc, sizes: [.fixed(400), .fixed(400)])
            sheetController.dismissOnPull = false
            sheetController.dismissOnOverlayTap = false
            self.present(sheetController, animated: true, completion: nil)
        }else{
            weak var pvc = self.presentingViewController
            let alert = UIAlertController(title: "ZEDの支払い設定を完了してください", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                pvc?.dismiss(animated: true){
                    let mainstoryboard = UIStoryboard.init(name: "Setting", bundle: nil)
                    let vc = mainstoryboard.instantiateViewController(withIdentifier: "settingVC") as! SettingViewController
                    
                    vc.modalPresentationStyle = .fullScreen
                    pvc?.present(vc, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func actionTapSendMoney(_ sender: Any) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: false){
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "payQrcodeVC") as! PayQRCodeViewController
            vc.modalPresentationStyle = .fullScreen
            pvc?.present(vc, animated: true, completion: nil)
        }
    }
}

extension ZedHistoryViewController: UpdateBalance {
    func updateVal() {
        DispatchQueue.main.async {
            self.labelBalance.text = self.person?.getBalance().moneyString()
        }
    }
}

protocol UpdateBalance: class {
    func updateVal()
}
