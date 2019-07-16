//
//  NewTodosViewController.swift
//  ToDoS
//
//  Created by iglo on 16/07/19.
//  Copyright © 2019 iglo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewTodosViewController: UIViewController {
    
    
    @IBOutlet weak var viewNewTodos: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    
    var titleTodos = ""
    var descTodos = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewNewTodos.layer.cornerRadius = 8
        saveButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        
        if titleTodos != "" || descTodos != ""{
            titleTextField.text = titleTodos
            descTextField.text = descTodos
        }
        
        titleTextField.delegate = self
        descTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()

    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        saveRequest()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveRequest(){
        
        let urlPost = "https://todo-backend-restify-redux.herokuapp.com/"
        let header = ["Content-Type" : "Application/json"]
        let param : Parameters = [
            "title" : titleTextField.text! ,
            "order" : descTextField.text!]
        
        Alamofire.request(urlPost, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)
                print(responseJSON)
                self.dismiss(animated: true, completion: nil)
            }else{
                print("error")
            }
        }
    }
}

extension NewTodosViewController: UITextFieldDelegate{
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func hideKeyboardWhenTappedAround(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
