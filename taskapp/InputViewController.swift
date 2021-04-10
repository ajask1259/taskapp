//
//  inputViewController.swift
//  taskapp
//
//  Created by 荒井竣哉 on 2021/04/05.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    let realm = try! Realm()
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //キーボードで隠れないようにする
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //背景タップ時dismissKeyboradを呼ぶ設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.category.text!
            self.realm.add(self.task,update: .modified)
        }
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    //タスクのローカル通知登録
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトル内容設定
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するトリガー（日付マッチ）を作成
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year,.month,.day,.hour,.minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //上記からローカル通知作成
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request){(error)in
            print(error ?? "ローカル通知登録　OK")// error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
            
        }
    }
    
    @objc func dismissKeyboard(){
        //キーボード閉じる
        view.endEditing(true)
    }
    

    @IBAction func categoryexit(_ sender: Any) {
    }
    
    @IBAction func titleexit(_ sender: Any) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("テキストフィールドがタップされた")
        return true
        
    }
    //キーボードで隠れないようにするためのやつ
    @objc func keyboardWillShow(notification: NSNotification) {
        if !category.isFirstResponder {
            return
        }
    
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardRect.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
