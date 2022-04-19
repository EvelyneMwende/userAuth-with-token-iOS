//
//  HomePageViewController.swift
//  UserAuth
//
//  Created by Eclectics on 07/04/2022.
//

import UIKit
import SwiftKeychainWrapper

class HomePageViewController: UIViewController {

    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signOutButtonTapped(_ sender: Any) {
        print("Sign Out button tapped")
        
        //CLEAR ACCESS TOKEN AND USER ID FROM KEY CHAIN
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        
        //NAVIGATE TO SIGN IN PAGE
        let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        
        let appDelegate = UIApplication.shared.delegate
        //appDelegate?.window??.rootViewController = signInPage
        
        UIApplication.shared.windows.first?.rootViewController = signInPage

        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    @IBAction func loadMemberProfileButtonTapped(_ sender: Any) {
        print("Load Member Profile button tapped")
        loadMemberProfile()
        
    }

//    @IBAction func routesButtonTapped(_ sender: Any) {
//        let vc = RouteViewController()
//        vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
//        self.present(vc, animated: true, completion: nil)
//    }
    
    
    func loadMemberProfile(){
        //READ Access token and User ID from KEYCHAIN
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        
        print("RETRIEVAL")
        print(accessToken!)
        print(userId!)
        //send HTTP request with id
        let myURL = URL(string: "https://hidden-journey-35693.herokuapp.com/api/users/\(userId!)")
        
        var request = URLRequest(url: myURL!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        
        //Send http request using task
        let task = URLSession.shared.dataTask(with: request){(data: Data?, response: URLResponse?, error: Error?) in
            
            //once the http request completes check if there is an error
            //if there is an error
            if error != nil {
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                print("Error = \(String(describing: error))")
                return
            }
            
            //if there is no error convert the response received from the server into an NSDictionary
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                //unwrap the JSON to see if its not empty
                if let parseJSON = json {
                    DispatchQueue.main.async {
                        let success = parseJSON["success"] as? Bool
                        print("Success: \(String(describing: success))")
                        
                        if let status = success{
                            print("Status: \(String(describing: status))")
                            
                            if(status == true){
                                let user = parseJSON["data"] as? NSDictionary
                                print("Response1: \(String(describing: user!))")
                                
                                var dic:NSDictionary = NSDictionary(dictionary:user!)
                                //print(dic.allKeys(for: "Evelyne"))
                                print(dic["name"]!)
                                
                                if let res = user{
                                    print("Response2: \(String(describing: res))")
                                }else{
                                    print("NILL VALUE")
                                    return
                                }
                                self.userFullNameLabel.text = "Full name: \(dic["name"]!)"
                                self.userEmailLabel.text = "Email: \(dic["email"]!)"
                                self.userPhoneNumberLabel.text = "Phone number: \(dic["phone_number"]!)"
                            }
                        }else{
                            print("Errorrr")
                            return
                        }
                        
                    }
                }
                //if the JSON response is empty
                else{
                    self.displayMessage(userMessage: "Sorry! We are experiencing some technical difficulties at the moment")
                }
                
            }catch{
                self.displayMessage(userMessage: "Oops! Something went wrong")
                print(error)
            }
        }
        
        task.resume()
        
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
    
    struct ApiResponse: Codable{
        let success: Bool?
        let data: DataRes?
    }

    struct DataRes: Codable{
        //getting name only for the source dictionary
        let id: Int?
        let name: String?
        let email: String?
        let phone_number: String?
        let number_plate: String?
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

