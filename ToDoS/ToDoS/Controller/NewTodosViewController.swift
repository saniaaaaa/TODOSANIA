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
    
    var idUpdate = ""
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
        if idUpdate == ""{
            saveRequest()
        }else{
            updateRequest(id: idUpdate)
        }
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
                
                let alert = UIAlertController(title: "Berhasil", message: "ToDo berhasil disimpan, mohon untuk refresh table terlebih dahulu", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)

            }else{
                let alert = UIAlertController(title: "Gagal", message: "ToDo gagal disimpan, mohon coba lagi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
            }
        }
    }
    
    func updateRequest(id: String){
        let urlUpdate = "https://todo-backend-restify-redux.herokuapp.com/\(id)"
        let header = ["Content-Type" : "Application/json"]
        let param : Parameters = [
            "title" : titleTextField.text!,
            "order" : descTextField.text!]
        
        Alamofire.request(urlUpdate, method: .patch, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)
                print(responseJSON)
                
                let alert = UIAlertController(title: "Berhasil", message: "ToDo berhasil diupdate, mohon untuk refresh table terlebih dahulu", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
                
            }else{
                let alert = UIAlertController(title: "Gagal", message: "ToDo gagal diupdate, mohon coba lagi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
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
