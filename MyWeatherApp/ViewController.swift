//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by apple on 30/03/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var forcastCollView: UICollectionView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    let img = ["clear", "rain", "cloud", "cloud", "clear", "clear", "rain"]
    
    let days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var json = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        forcastCollView.delegate = self
        forcastCollView.dataSource = self
       // self.forcastCollView.backgroundColor = UIColor(red: 53.0/255.0, green: 95.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: self.forcastCollView.frame.size.width, height: 120)
        self.forcastCollView.collectionViewLayout = flowLayout
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    // Location
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }

        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=33.44&lon=-94.04&appid=4cd569ffb3ecc3bffe9c0587ff02109f")
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
                self.forcastCollView.reloadData()
            }
        }
       
            task.resume()
    }
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        headerView.backgroundColor = .red
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.height, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height + summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)
        
        locationLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        locationLabel.text = "Current Location"
        
//        tempLabel.text = "\(self.current?.main.temp ?? 0.00)"
        tempLabel.font = UIFont(name: "Helcetica-Bold", size: 32)
        summaryLabel.text = "Clear"
        
        return headerView
    }
    
    // Table
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if json.count > 0{
            return 1
        }else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.json.value(forKey: "daily") as! NSArray).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vcCollectionViewCell", for: indexPath) as! vcCollectionViewCell
        cell.tempicon.image = UIImage.init(named: "\(self.img[indexPath.row])")
        cell.dateLbl.text = "\(self.days[indexPath.row])"
        cell.maxtempLbl.text = "\((((self.json.value(forKey: "daily") as! NSArray).object(at: indexPath.row) as! NSDictionary).value(forKey: "temp") as! NSDictionary).value(forKey: "max") as! NSNumber)"
        cell.mintempLbl.text = "\((((self.json.value(forKey: "daily") as! NSArray).object(at: indexPath.row) as! NSDictionary).value(forKey: "temp") as! NSDictionary).value(forKey: "min") as! NSNumber)"
        print("\((((self.json.value(forKey: "daily") as! NSArray).object(at: indexPath.row) as! NSDictionary).value(forKey: "temp") as! NSDictionary).value(forKey: "min") as! NSNumber)")

        return cell
    }
    
}

