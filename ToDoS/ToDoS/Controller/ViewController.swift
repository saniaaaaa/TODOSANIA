//
//  ViewController.swift
//  ToDoS
//
//  Created by iglo on 16/07/19.
//  Copyright © 2019 iglo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    
    var menuShowing = false
    var notesJSON : JSON = []
    var editJSON : JSON = []
    var idxSelected = 0
    var idDeleteTodo = ""
    var idEditToDo = ""
    
    let transition = SlideInTransition()
    
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuShowing = false
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        loadTodo()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        todoTableView.addSubview(refreshControl)
        

//        let button = UIButton()
//        button.frame = CGRect(x: 0, y: 0, width: 51, height: 31)
//        button.setImage(UIImage(named: "icon"), for: .normal)
//        button.addTarget(self, action: #selector(openMenu), for: .touchUpInside)
//
//        let barButton = UIBarButtonItem()
//        barButton.customView = button
//        self.navigationItem.rightBarButtonItem = barButton
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        todoTableView.reloadData()
    }
    
    @IBAction func openMenu(_ sender: Any) {
//        viewMenu.isHidden = false
//        if menuShowing == false{
//            leadingConstraint.constant = 0
//            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//        }else if menuShowing == true{
//            leadingConstraint.constant = -175
//            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//        }
//        menuShowing = !menuShowing
        
        guard let menuTableViewController = storyboard?.instantiateViewController(withIdentifier: "MenuTableViewController") as? MenuTableViewController else { return }
        menuTableViewController.didTapMenuType = { menuType in
            self.transitionToNewContent(menuType)
        }
        menuTableViewController.modalPresentationStyle = .overCurrentContext
        menuTableViewController.transitioningDelegate = self
        present(menuTableViewController, animated: true)
    }
    
    
    @IBAction func newTodoTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        viewMenu.isHidden = true
        performSegue(withIdentifier: "toNewTodos", sender: self)
    }
    
    @objc func refresh(sender: AnyObject){
        loadTodo()
        todoTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadTodo(){
        
        let urlGet = "https://todo-backend-restify-redux.herokuapp.com"
        
        Alamofire.request(urlGet, method: .get).responseData { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)
                self.notesJSON = responseJSON
                
                print(responseJSON)
                self.todoTableView.reloadData()
                
            }else{
                print("error")
            }
        }
    }
    
    func deleteTodo(id: String){

        let urlDelete = "https://todo-backend-restify-redux.herokuapp.com/\(id)"
        
        Alamofire.request(urlDelete, method: .delete).responseData { (response) in
            if response.result.isSuccess{
                print("success")
            }else{
                print("error")
            }

        }
    }
    
//    func updateTodo(){
//        let urlUpdate = "https://todo-backend-restify-redux.herokuapp.com/rkxxoQvyr"
//        let header = ["Content-Type" : "Application/json"]
//        let param : Parameters = ["id": idEditToDo ]
//
//        Alamofire.request(urlUpdate, method: .patch, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
//            if response.result.isSuccess{
//                let responseJSON = JSON(response.result.value!)
//
//                self.editJSON = responseJSON
//                self.idEditToDo = responseJSON["id"].stringValue
//                print(responseJSON)
//                self.performSegue(withIdentifier: "toEdit", sender: self)
//            }else{
//                let error: NSError = response.result.error! as NSError
//                print(error)
//                let errorJSON = JSON(response.result.error!)
//                print(errorJSON)
//            }
//        }
//
//    }
    
    func updateTodo(id: String){
        let urlUpdate = "https://todo-backend-restify-redux.herokuapp.com/\(id)"
        
        Alamofire.request(urlUpdate, method: .patch).responseData { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)
                
                self.editJSON = responseJSON
                self.idEditToDo = responseJSON["id"].stringValue
                print(responseJSON)
                self.performSegue(withIdentifier: "toEdit", sender: self)
            }else{
                let error: NSError = response.result.error! as NSError
                print(error)
                let errorJSON = JSON(response.result.error!)
                print(errorJSON)
            }

        }
        
    }
    
    
}



extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesJSON.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        
        
        cell.titleLabel.text = notesJSON[indexPath.row]["title"].stringValue
        cell.descLabel.text = notesJSON[indexPath.row]["order"].stringValue
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            let alert = UIAlertController(title: "Alert", message: "Apakah anda yakin ingin menghapus todo ini?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Iya", style: .default, handler: { (action) in
                
                print(indexPath.row)
                self.idxSelected = indexPath.row
                self.idDeleteTodo = self.notesJSON[indexPath.row]["id"].stringValue
                print(self.self.idxSelected)
                print("delete")
                self.deleteTodo(id: self.idDeleteTodo)
                self.todoTableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Tidak", style: .cancel, handler: nil))
            
            self.present(alert,animated: true)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, index) in
            self.idEditToDo = self.notesJSON[indexPath.row]["id"].stringValue
            self.idxSelected = indexPath.row
            self.updateTodo(id: self.idEditToDo)
        }
        
        edit.backgroundColor = .lightGray
        delete.backgroundColor = .red
        
        return[delete, edit]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit"{
            let vc = segue.destination as! NewTodosViewController
            
            vc.idUpdate = idEditToDo
            for i in 0...notesJSON.count - 1{
                if notesJSON[i]["id"].stringValue == idEditToDo{
                    vc.titleTodos = notesJSON[i]["title"].stringValue
                    vc.descTodos = notesJSON[i]["order"].stringValue
                }
            }
            
        }
    }
}


extension ViewController: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
    
    func transitionToNewContent(_ menuType : MenuType){
        switch menuType {
        case .newTodo:
            performSegue(withIdentifier: "toNewTodos", sender: self)
        case .todo:
            dismiss(animated: true, completion: nil)
        }
    }
    
}
