//
//  InitialViewController.swift
//  MyWeatherApp
//
//  Created by apple on 30/03/23.
//

import UIKit

class InitialViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var hourlycollvw: UICollectionView!
    @IBOutlet weak var todaycolVwLbl: UILabel!
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var mainViewImg: UIImageView!
    @IBOutlet weak var uvLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var feelslikeLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    var json = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hourlycollvw.delegate = self
        self.hourlycollvw.dataSource = self
        self.requestWeatherForLocation()
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyCollectionViewCell", for: indexPath) as! hourlyCollectionViewCell
        return cell
    }
    
    func requestWeatherForLocation() {
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=11.0346&lon=77.0156&appid=4cd569ffb3ecc3bffe9c0587ff02109f")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let err = error{
                print(err.localizedDescription)
            }
            if let resp = response as? HTTPURLResponse{
                print(resp.statusCode)
            }
            do{
                self.json = try JSONSerialization.jsonObject(with: data!) as! NSDictionary
                print(self.json)
            }
            catch let err as NSError{
                print(err.localizedDescription)
            }
            DispatchQueue.main.async {
                self.hourlycollvw.reloadData()
                self.Updates()
            }
        }
       
            task.resume()
    }
    
    func Updates(){
        self.locationLabel.text = self.json.value(forKey: "name") as! String
        self.descriptionLbl.text = ((self.json.value(forKey: "weather") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "description") as! String
        
        self.windSpeedLbl.text = "\((self.json.value(forKey: "wind") as! NSDictionary).value(forKey: "speed") as! NSNumber)"
        self.pressureLbl.text = "\((self.json.value(forKey: "main") as! NSDictionary).value(forKey: "pressure") as! NSNumber)"
        self.tempLbl.text = "\((self.json.value(forKey: "main") as! NSDictionary).value(forKey: "temp") as! NSNumber)"
        self.feelslikeLbl.text = "\((self.json.value(forKey: "clouds") as! NSDictionary).value(forKey: "all") as! NSNumber)"
        //self.uvLbl.text = "\((self.json.value(forKey: "wind") as! NSDictionary).value(forKey: "speed") as! NSNumber)"
        print(self.json)
    
        
        
    }
    
    @IBAction func nextBtnAct(_ sender: Any) {
        let pushvc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(pushvc, animated: true)
    }
}
