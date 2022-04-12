//
//  RegisterUserViewController.swift
//  UserAuth
//
//  Created by Eclectics on 07/04/2022.
//

import UIKit
import CoreData

class RegisterUserViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var numberPlateTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        print("Cancel button tapped")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        print("Sign up button tapped")
        
        //validate required fields are not empty
        if  (nameTextField.text?.isEmpty)! ||
            (emailAddressTextField.text?.isEmpty)! ||
            (phoneNumberTextField.text?.isEmpty)! ||
            (numberPlateTextField.text?.isEmpty)! ||
            (passwordTextField.text?.isEmpty)!
        {
            //display alert message and return
            displayMessage(userMessage: "All fields must not be empty")
            return
        }
        
        //Validate password
        if
            ((passwordTextField.text?.elementsEqual(passwordConfirmTextField.text!))! != true){
            
            //display alert message and return
            displayMessage(userMessage: "Password and Confirmation Password should Match")
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
        
        view.addSubview(myActivityIndicator)
        
        //create http request
        let myUrl = URL(string: "https://1057-41-81-148-175.ngrok.io/api/users/register")
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST" //compose a query string
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //JSON payload on the HTTP body
        let postString =
        [
            "name" : nameTextField.text!,
            "email" : emailAddressTextField.text!,
            "phone_number": phoneNumberTextField.text!,
            "number_plate": numberPlateTextField.text!,
            "password": passwordTextField.text!
        ] as [String: String]
        
        //converting it into a JSON payload
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: .prettyPrinted)
        } catch let error {
            
            print(error.localizedDescription)
            displayMessage(userMessage: "Something went wrong. Try again")
            return
        }
        
        //send http request
        //create a resumable task
        let task = URLSession.shared.dataTask(with: request) {
            (data: Data?, response:
                URLResponse?, error: Error?) in
            //hide progress bar/ activity indicator
            
            self.removeActityIndicator(activityIndicator: myActivityIndicator)
            
            // if an error takes place display error message
            if error != nil{
                self.displayMessage(userMessage: "Could not successfully perform this request. Please try again later")
                
                print("ERROR : \(String(describing: error))")
                return
            }
            
            //if we receive a response from the server convert it to a dictionary
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                if let parseJSON = json {
                    let userId = parseJSON["userId"] as? String
                    print("User id: \(String(describing: userId!))")
                    
                    if(userId?.isEmpty)!{
                        self.displayMessage(userMessage: "Could not perform account creation. Please try again later")
        
                        return
                    }else{
                        self.displayMessage(userMessage: "Successfully Registered a New Account. Procceed to Sign In")
        
                    }
                }else{
                    self.displayMessage(userMessage: "The request could not be performed. Please try again later")
                }
                
            }catch{
                self.removeActityIndicator(activityIndicator: myActivityIndicator)
                self.displayMessage(userMessage: "Ooops! We ran into an error. Please try again later")
            }
            
        }
        //after receiving a response stop activity
        task.resume()
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
