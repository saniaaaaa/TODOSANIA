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
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var notesJSON : JSON = []
    var idxSelected = 0
    var idDeleteTodo = ""
    var idEditToDo = ""
    
    let transition = SlideInTransition()
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        loadTodo {
            self.todoTableView.reloadData()
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        todoTableView.addSubview(refreshControl)
        
        
    }
    
    @IBAction func openMenu(_ sender: Any) {
        
        guard let menuTableViewController = storyboard?.instantiateViewController(withIdentifier: "MenuTableViewController") as? MenuTableViewController else { return }
        menuTableViewController.didTapMenuType = { menuType in
            self.transitionToNewContent(menuType)
        }
        menuTableViewController.modalPresentationStyle = .overCurrentContext
        menuTableViewController.transitioningDelegate = self
        present(menuTableViewController, animated: true)
    }
    

    @objc func refresh(sender: AnyObject){
        loadTodo {
            self.todoTableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    
    func loadTodo(completion: @escaping()->()){
        
        let urlGet = "https://todo-backend-restify-redux.herokuapp.com"
        
        Alamofire.request(urlGet, method: .get).responseData { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)
                self.notesJSON = responseJSON
                
                print(responseJSON)
                completion()
                
            }else{
                let alert = UIAlertController(title: "Gagal", message: "gagal load ToDo, mohon coba lagi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
            }
        }
    }
    
    func deleteTodo(id: String){

        let urlDelete = "https://todo-backend-restify-redux.herokuapp.com/\(id)"
        
        Alamofire.request(urlDelete, method: .delete).responseData { (response) in
            if response.result.isSuccess{
                self.loadTodo(completion: {
                    self.todoTableView.reloadData()
                })
            }else{
                let alert = UIAlertController(title: "Gagal", message: "ToDo gagal dihapus, mohon coba lagi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
            }

        }
    }
    
    func updateTodo(id: String){
        let urlUpdate = "https://todo-backend-restify-redux.herokuapp.com/\(id)"
        
        Alamofire.request(urlUpdate, method: .patch).responseData { (response) in
            if response.result.isSuccess{
                let responseJSON = JSON(response.result.value!)

                self.idEditToDo = responseJSON["id"].stringValue
                print(responseJSON)
                self.performSegue(withIdentifier: "toEdit", sender: self)
            }else{
                let alert = UIAlertController(title: "Gagal", message: "gagal mengambil data, mohon coba lagi", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert,animated: true)
                
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
