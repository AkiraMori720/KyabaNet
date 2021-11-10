import UIKit
import RealmSwift
import JGProgressHUD
class CreateCustomerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var informLabel: UILabel!
    
    @IBOutlet weak var newPasswordEye: UIButton!
    
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    let hud = JGProgressHUD(style: .light)
    var newpassword_eye_off = true
    var confirmpassword_eye_off = true
    private var tokenStripeCustomer: NotificationToken? = nil
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    private var tokenPaymentmethod: NotificationToken? = nil
    private var paymentMethods = realm.objects(PaymentMethod.self).filter(falsepredicate)
    var delegate: UpdatePayDelegateProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        informLabel.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNewPasswordEyeTapped(_ sender: Any) {
        if newpassword_eye_off{
            newPasswordTextField.isSecureTextEntry = false
            newPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        newpassword_eye_off = !newpassword_eye_off
    }
    
    @IBAction func onConfirmPasswordEyeTapped(_ sender: Any) {
        if confirmpassword_eye_off{
            confirmPasswordTextField.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        confirmpassword_eye_off = !confirmpassword_eye_off
    }
    
    func showInformText(withOption option: Bool, withText value: String = "")
    {
        informLabel.isHidden = option
        //informLabel.text = value
    }
    @IBAction func onSubmitTapped(_ sender: Any) {
        let newPassword = self.newPasswordTextField.text
        if newPassword?.isEmpty == true {
            return
        }
        if newPasswordTextField.text == confirmPasswordTextField.text {
            showInformText(withOption: true)
            self.hud.show(in: self.view, animated: true)
            StripeCustomers.create(passcode: newPasswordTextField.text!)
            let predicate = NSPredicate(format: "userId == %@", AuthUser.userId())
            stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
            
            tokenStripeCustomer?.invalidate()
            stripeCustomers.safeObserve({ changes in
                self.createdStripeCustomer()
            }, completion: { token in
                self.tokenStripeCustomer = token
            })
        }
        else{
            showInformText(withOption: false)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as UIResponder?

        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func createdStripeCustomer(){
        guard let stripeCustomer = stripeCustomers.first else{
            return
        }
        
        if stripeCustomer.status == ZEDPAY_STATUS.PENDING {
            return
        }
        
        if stripeCustomer.status == ZEDPAY_STATUS.FAILED {
            weak var pvc = self.presentingViewController
            self.dismiss(animated: false, completion: {
                let alert = UIAlertController(
                    title: "".localized,
                  message: "Error!".localized,
                  preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                pvc?.present(alert, animated: true)
            })
        }
        if stripeCustomer.status == ZEDPAY_STATUS.SUCCESS {
            self.hud.show(in: self.view, animated: true)
            let predicate = NSPredicate(format: "userId == %@ AND status == %@", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
            if let customer = realm.objects(StripeCustomer.self).filter(predicate).first {
                let cardNumber = "4242424242424242"
                let cvc = "123"
                
                let cardExpMonth = "12"
                let cardExpYear = "25"
                self.hud.show(in: self.view, animated: true)
                PaymentMethods.create(userId: AuthUser.userId(), customerId: customer.customerId, cardNumber: cardNumber, expMonth: cardExpMonth, expYear:cardExpYear, cvc: cvc)
                
                let predicate = NSPredicate(format: "userId == %@ AND status == %@ AND isDeleted == NO", AuthUser.userId(), ZEDPAY_STATUS.SUCCESS)
                paymentMethods = realm.objects(PaymentMethod.self).filter(predicate)
                
                tokenPaymentmethod?.invalidate()
                self.hud.dismiss()
                paymentMethods.safeObserve({ changes in
                    self.dismiss(animated: true){
                        self.delegate?.updateCard(result: false)
                    }
                }, completion: { token in
                    self.tokenPaymentmethod = token
                })
                
                
            }else{
                self.hud.dismiss()
                self.dismiss(animated: true){
                    self.delegate?.updateCard(result: false)
                }
            }
        }
    }
}


/*import UIKit
import RealmSwift
import JGProgressHUD
class CreateCustomerViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var informLabel: UILabel!
    
    @IBOutlet weak var newPasswordEye: UIButton!
    
    @IBOutlet weak var confirmPasswordEye: UIButton!
    
    let hud = JGProgressHUD(style: .light)
    var newpassword_eye_off = true
    var confirmpassword_eye_off = true
    private var tokenStripeCustomer: NotificationToken? = nil
    private var stripeCustomers = realm.objects(StripeCustomer.self).filter(falsepredicate)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        informLabel.isHidden = true
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func onCloseTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNewPasswordEyeTapped(_ sender: Any) {
        if newpassword_eye_off{
            newPasswordTextField.isSecureTextEntry = false
            newPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        newpassword_eye_off = !newpassword_eye_off
    }
    
    @IBAction func onConfirmPasswordEyeTapped(_ sender: Any) {
        if confirmpassword_eye_off{
            confirmPasswordTextField.isSecureTextEntry = false
            confirmPasswordEye.setImage(UIImage(named: "eye_on"), for: .normal)
        }else {
            confirmPasswordTextField.isSecureTextEntry = true
            confirmPasswordEye.setImage(UIImage(named: "eye_off"), for: .normal)
        }
        confirmpassword_eye_off = !confirmpassword_eye_off
    }
    
    func showInformText(withOption option: Bool, withText value: String = "")
    {
        informLabel.isHidden = option
        //informLabel.text = value
    }
    @IBAction func onSubmitTapped(_ sender: Any) {
        let newPassword = self.newPasswordTextField.text
        if newPassword?.isEmpty == true {
            return
        }
        if newPasswordTextField.text == confirmPasswordTextField.text {
            showInformText(withOption: true)
            self.hud.show(in: self.view, animated: true)
            StripeCustomers.create(passcode: newPasswordTextField.text!)
            let predicate = NSPredicate(format: "userId == %@", AuthUser.userId())
            stripeCustomers = realm.objects(StripeCustomer.self).filter(predicate)
            
            tokenStripeCustomer?.invalidate()
            stripeCustomers.safeObserve({ changes in
                self.createdStripeCustomer()
            }, completion: { token in
                self.tokenStripeCustomer = token
            })
        }
        else{
            showInformText(withOption: false)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.viewWithTag(nextTag) as UIResponder?

        if nextResponder != nil {
            // Found next responder, so set it
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }

        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 4
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func createdStripeCustomer(){
        guard let stripeCustomer = stripeCustomers.first else{
            return
        }
        
        if stripeCustomer.status == ZEDPAY_STATUS.PENDING {
            return
        }
        
        if stripeCustomer.status == ZEDPAY_STATUS.FAILED {
            weak var pvc = self.presentingViewController
            self.dismiss(animated: false, completion: {
                let alert = UIAlertController(
                    title: "".localized,
                  message: "Error!".localized,
                  preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                pvc?.present(alert, animated: true)
            })
        }
        if stripeCustomer.status == ZEDPAY_STATUS.SUCCESS {
            weak var pvc = self.presentingViewController
            self.dismiss(animated: false, completion: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "zedPaySettingsVC") as! ZEDPaySettingsViewController
                vc.modalPresentationStyle = .fullScreen
                pvc?.present(vc, animated: true)
            })
            
        }
        
    }
    
}*/
