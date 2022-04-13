//
//  RouteViewController.swift
//  UserAuth
//
//  Created by Eclectics on 13/04/2022.
//

import UIKit
import SwiftKeychainWrapper

class RouteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(RoutesTableViewCell.self,
                       forCellReuseIdentifier: RoutesTableViewCell.identifier)
        return table
    }()
    
    private var viewModels = [RoutesTableViewCellViewModel]()
    private var routes = [Route]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Routes"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .systemBackground
        
        getTopRoutes()
    }
    
    
    
    
    private func getTopRoutes(){
        getRoutes{[weak self] result in
            switch result{
            case .success(let routes):
                self?.routes = routes
                self?.viewModels = routes.compactMap({
                    RoutesTableViewCellViewModel(
                        entry: $0.entry,
                        exit_point:$0.exit_point,
                        price: $0.price )
                    
                })
                
                //refresh tableview
                DispatchQueue.main.async{
                    self?.tableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                break
            default:
                break
            }
            
        }
    }
    
    //give cell a frame
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RoutesTableViewCell.identifier,
            for:indexPath) as? RoutesTableViewCell else {
                fatalError()
            }
//        cell.textLabel?.text = "Something"
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    //make cells taller than their standard height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func getRoutes(completion: @escaping (Result<[Route], Error>)->Void){
        
        //READ Access token and User ID from KEYCHAIN
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        
        print("RETRIEVAL")
        print(accessToken!)
    
        //send HTTP request with id
        let myURL = URL(string: "https://hidden-journey-35693.herokuapp.com/api/routes/")
        
        var request = URLRequest(url: myURL!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){data, _, error in
            if let error = error{
                self.displayMessage(userMessage: "Oops! Something went wrong")
                print("Error: \(error)")
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    //try to decode using a json decoder
                    let result  = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Routes: \(result.result.count)")
                    completion(.success(result.result))
                }
                catch{
                    self.displayMessage(userMessage: "We are sorry! Something went wrong")
                    print("Error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        
    }
    
    //Models
    struct APIResponse: Codable {
        let success: Bool
        let result: [Route]
    }

    //structure what we want to fetch from the api
    struct Route: Codable {
        let entry: String
        let exit_point: String
        let price: Int
        
    }
    
    //Creating an ALERT
    func displayMessage(userMessage: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default)
            {(action: UIAlertAction) in
                //the code in this block will be triggered when the OK button is tapped
                print("Ok button tapped")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
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
