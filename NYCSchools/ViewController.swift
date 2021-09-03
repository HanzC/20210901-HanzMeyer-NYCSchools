//
//  ViewController.swift
//  NYCSchools
//
//  Created by Hanz Meyer on 9/1/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate
{
    @IBOutlet var tableView: UITableView!
    var tableArray = [String] ()
    var spinner: UIActivityIndicatorView?
    var array: NSArray = []
    var satArray: NSArray = []
    var firstString = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /* Set Table View Properties */
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        parseJSON()
    }
    
    func parseJSON()
    {
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            // Fallback on earlier versions
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }
        spinner!.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(spinner!)
        spinner!.startAnimating()
        
        /* Initiate API Request */
        let url = URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")
        let session = URLSession.shared

        let request = NSMutableURLRequest()
        request.timeoutInterval = 15
        request.httpMethod = "GET"
        request.url = url
        
        let task = session.dataTask(with: request as URLRequest) { [self] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            if statusCode != 200 {
                if let url = url {
                    print(String(format: " *** Error getting %@, HTTP status code %li", url as CVarArg, statusCode))
                }
                DispatchQueue.main.async(execute: { [self] in
                    spinner!.stopAnimating()
                    // Describes and logs the error preventing us from receiving a response
                    print("Error: \((error as NSError?)?.userInfo ?? [:])")
                    let alert = UIAlertController(title: (error as NSError?)?.userInfo["NSLocalizedDescription"] as? String, message: "", preferredStyle: .alert)
                    let closeAction = UIAlertAction(
                        title: "Close",
                        style: .default,
                        handler: { action in
                        })
                    alert.addAction(closeAction)
                    present(alert, animated: true)
                })
                return
            }

            if let data = data {
                print(" *** Data received:     \(data)")
            }
            print(String(format: " *** Response received: %ld", statusCode))

            do {
                if let data = data
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    //print(json)
                    
                    //let array: NSArray = json as! NSArray
                    self.array = json as! NSArray
                    print(array.value(forKeyPath: "school_name")!)
                    self.tableArray = array.value(forKeyPath: "school_name")! as! [String]
                    
                }
                DispatchQueue.main.async(execute: { [self] in
                    self.tableView.reloadData()
                    spinner!.stopAnimating()
                })
            } catch
            {
                
            }
        }
        task.resume()
    }
    
    func parseSATJSON()
    {
        if #available(iOS 13.0, *) {
            spinner = UIActivityIndicatorView(style: .large)
        } else {
            // Fallback on earlier versions
            spinner = UIActivityIndicatorView(style: .whiteLarge)
        }
        spinner!.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(spinner!)
        spinner!.startAnimating()
        
        /* Initiate API Request */
        let url = URL(string: firstString)
        let session = URLSession.shared

        let request = NSMutableURLRequest()
        request.timeoutInterval = 15
        request.httpMethod = "GET"
        request.url = url
        
        let task = session.dataTask(with: request as URLRequest) { [self] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            if statusCode != 200 {
                if let url = url {
                    print(String(format: " *** Error getting %@, HTTP status code %li", url as CVarArg, statusCode))
                }
                DispatchQueue.main.async(execute: { [self] in
                    spinner!.stopAnimating()
                    // Describes and logs the error preventing us from receiving a response
                    print("Error: \((error as NSError?)?.userInfo ?? [:])")
                    let alert = UIAlertController(title: (error as NSError?)?.userInfo["NSLocalizedDescription"] as? String, message: "", preferredStyle: .alert)
                    let closeAction = UIAlertAction(
                        title: "Close",
                        style: .default,
                        handler: { action in
                        })
                    alert.addAction(closeAction)
                    present(alert, animated: true)
                })
                return
            }

            if let data = data {
                print(" *** Data received:     \(data)")
            }
            print(String(format: " *** Response received: %ld", statusCode))

            do {
                if let data = data
                {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    //print(json)
                    
                    self.satArray = json as! NSArray
                    print(satArray)
                    
                    if satArray.count > 0
                    {
                        // Get Reading Score and print
                        let readingScore = satArray.object(at: 0)
                        print(" *** Reading Score:  \((readingScore as AnyObject).value(forKeyPath: "sat_critical_reading_avg_score")!)")
                        
                        // Get Writing Score and print
                        let writingScore = satArray.object(at: 0)
                        print(" *** Writing Score:  \((writingScore as AnyObject).value(forKeyPath: "sat_writing_avg_score")!)")
                        
                        // Get Math Score and print
                        let mathScore = satArray.object(at: 0)
                        print(" *** Math Score:  \((mathScore as AnyObject).value(forKeyPath: "sat_math_avg_score")!)")

                        DispatchQueue.main.async(execute: { [self] in
                            presentCustomViewController((readingScore as AnyObject).value(forKeyPath: "sat_critical_reading_avg_score")! as! String,
                                                        (writingScore as AnyObject).value(forKeyPath: "sat_writing_avg_score")! as! String,
                                                        (mathScore as AnyObject).value(forKeyPath: "sat_math_avg_score")! as! String)
                            spinner!.stopAnimating()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: { [self] in
                            let alert = UIAlertController(title: "No Scores Found", message: "", preferredStyle: .alert)
                            let closeAction = UIAlertAction(
                                title: "Close",
                                style: .default,
                                handler: { action in
                                })
                            alert.addAction(closeAction)
                            present(alert, animated: true)
                            spinner!.stopAnimating()
                            return
                        })
                    }
                }
            } catch
            {
                
            }
        }
        task.resume()
    }
    
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellIdentifier = "cell"
        var cell = tableView.cellForRow(at: indexPath)

        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            cell?.textLabel?.text = self.tableArray[indexPath.row]
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.tableArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //print(" *** Data received:     \(data)")
        //print(array.value(forKeyPath: "dbn")!)
        let array2 = array.object(at: indexPath.row)
        print(" *** DBN:  \((array2 as AnyObject).value(forKeyPath: "dbn")!)")
        
        // Get SAT URL and append dbn value
        firstString = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\((array2 as AnyObject).value(forKeyPath: "dbn")!)"
        print(firstString)
        parseSATJSON()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    
    // MARK: - Custom View Controller
    func presentCustomViewController(_ readScore: String, _ writingScore: String, _ mathScore: String)
    {
        // Create a view controller
        let controller: UIViewController = UIViewController()
        let view: UIView = UIView()
        view.backgroundColor = UIColor.lightGray
        controller.view = view
        
        // Create Main Label
        let description = UILabel(frame: CGRect(x: self.tableView.center.x - 100, y: 10, width: 200, height: 40))
        description.font = UIFont(name: "Arial-BoldMT", size: 20)
        description.backgroundColor = UIColor.clear
        description.text = "SAT Scores"
        description.numberOfLines = 1
        description.textAlignment = .center
        view.addSubview(description)
        
        //1A. Create Reading Score Label
        let readScoreLbl = UILabel(frame: CGRect(x: 10, y: description.frame.maxY + 30, width: 150, height: 40))
        readScoreLbl.font = UIFont(name: "Arial", size: 16)
        readScoreLbl.backgroundColor = UIColor.clear
        readScoreLbl.text = "Reading Score: "
        readScoreLbl.numberOfLines = 1
        readScoreLbl.textAlignment = .left
        view.addSubview(readScoreLbl)
        
        //1B. Create Reading Score Value
        let readScoreValue = UILabel(frame: CGRect(x: readScoreLbl.frame.maxX + 20, y: description.frame.maxY + 30, width: 100, height: 40))
        readScoreValue.font = UIFont(name: "Arial", size: 16)
        readScoreValue.backgroundColor = UIColor.clear
        readScoreValue.text = readScore
        readScoreValue.numberOfLines = 1
        readScoreValue.textAlignment = .left
        view.addSubview(readScoreValue)
        
        //==============================
        
        //2A. Create Writing Score Label
        let writeScoreLbl = UILabel(frame: CGRect(x: 10, y: readScoreLbl.frame.maxY + 20, width: 150, height: 40))
        writeScoreLbl.font = UIFont(name: "Arial", size: 16)
        writeScoreLbl.backgroundColor = UIColor.clear
        writeScoreLbl.text = "Writing Score: "
        writeScoreLbl.numberOfLines = 1
        writeScoreLbl.textAlignment = .left
        view.addSubview(writeScoreLbl)
        
        //2B. Create Writing Score Value
        let writeScoreValue = UILabel(frame: CGRect(x: writeScoreLbl.frame.maxX + 20, y: readScoreValue.frame.maxY + 20, width: 100, height: 40))
        writeScoreValue.font = UIFont(name: "Arial", size: 16)
        writeScoreValue.backgroundColor = UIColor.clear
        writeScoreValue.text = writingScore
        writeScoreValue.numberOfLines = 1
        writeScoreValue.textAlignment = .left
        view.addSubview(writeScoreValue)
        
        //==============================
        
        //3A. Create Math Score Label
        let mathScoreLbl = UILabel(frame: CGRect(x: 10, y: writeScoreLbl.frame.maxY + 20, width: 150, height: 40))
        mathScoreLbl.font = UIFont(name: "Arial", size: 16)
        mathScoreLbl.backgroundColor = UIColor.clear
        mathScoreLbl.text = "Math Score: "
        mathScoreLbl.numberOfLines = 1
        mathScoreLbl.textAlignment = .left
        view.addSubview(mathScoreLbl)
        
        //3B. Create Writing Score Value
        let mathScoreValue = UILabel(frame: CGRect(x: mathScoreLbl.frame.maxX + 20, y: writeScoreValue.frame.maxY + 20, width: 100, height: 40))
        mathScoreValue.font = UIFont(name: "Arial", size: 16)
        mathScoreValue.backgroundColor = UIColor.clear
        mathScoreValue.text = mathScore
        mathScoreValue.numberOfLines = 1
        mathScoreValue.textAlignment = .left
        view.addSubview(mathScoreValue)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    
}
