//
//  SignInViewController.swift
//  UserAuth
//
//  Created by Eclectics on 07/04/2022.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPsswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        print("Sign In Button Tapped")
        
        // read values from text fields
        let userName = userNameTextField.text
        let userPassword = userPsswordTextField.text
        
        
        //validate required fields are not empty
        if(userName?.isEmpty)! || (userPassword?.isEmpty)! {
            
            //display alert message here
            print("Username \(String(describing: userName)) or password \(String(describing: userPassword)) is empty")
            
            displayMessage(userMessage: "One of the required fields is empty")
            return
        }
        
        //Show Progress bar/Activity Indicator
        let myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        //position progress bar at the center of the screen
        myActivityIndicator.center = view.center
        
        //prevent progress bar frpm hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = false
        
        //start Activity Indicator/Progress Bar
        myActivityIndicator.startAnimating()
        
        //add actvity indicator as a subview to our main view
        view.addSubview(myActivityIndicator)
        
        //create http request
        let myUrl = URL(string: "https://1057-41-81-148-175.ngrok.io/api/users/login")
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST" //compose a query string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString =
        [
            "email": userName!,
            "password": userPassword!
        
        ] as [String: String]
        
        //convert dictionary into a json body
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        }catch let error{
            //converting  dictionary into a json body error
            print(error.localizedDescription)
            displayMessage(userMessage: "Oops! Something went wrong")
            return
        }
        
        
        let task = URLSession.shared.dataTask(with: request){
            (data: Data?, response: URLResponse?, error: Error?) in
            
            //remove activity indicator after receiving resonse
            self.removeActityIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil {
                //get error that occured from the server
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again")
                print("Error = \(String(describing: error))")
                return
            }
            //if no error
            //convert data Object received into an NSDictionary
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json{
                    //if parseJSON is not empty
                    let success = parseJSON["success"] as? Bool
                    let message = parseJSON["message"] as? String
                    
                    
                    if(success == false){
                        self.displayMessage(userMessage: "Request was unsuccessful \n \(String(describing: message!))")
                                    return
                    }
                    
                    let accessToken = parseJSON["token"] as? String
                    let userID = parseJSON["id"] as? String
                    print("Access Token = \(String(describing: accessToken!))")
                    
                        //navigate to home page
                        DispatchQueue.main.async {
                            let homePage = self.storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") as! HomePageViewController
                            
                            let appDelegate = UIApplication.shared.delegate
                            appDelegate?.window??.rootViewController = homePage
                            
                            UIApplication.shared.windows.first?.rootViewController = homePage
                            
                            UIApplication.shared.windows.first?.makeKeyAndVisible()
                            
                            
                            

                        }
                        //store value in keychain
                        //DONE LATER
                        
                    
                } else{
                    //if parseJSON is empty
                    self.displayMessage(userMessage: "Unsuccessful request")
                }
                
                
            }catch {
                //converting json response body to dictionary error
                self.displayMessage(userMessage: "Looks like Something went wrong")
                return
            }
        }
        task.resume()
        
    }
    
    @IBAction func registerNewAccountButtonTapped(_ sender: Any) {
        print("Register New Account Button Tapped")
        
        let registerViewController =
        self.storyboard?
            .instantiateViewController(withIdentifier: "RegisterUserViewController") as! RegisterUserViewController
        
        self.present(registerViewController, animated: true)
    }
    
    //Stop displaying progress bar
    func removeActityIndicator(activityIndicator: UIActivityIndicatorView){
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        
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
