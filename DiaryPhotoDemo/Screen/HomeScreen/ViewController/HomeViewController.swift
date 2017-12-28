//
//  HomeViewController.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/22/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import AddressBook
import Contacts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var photosTableView: UITableView!
    var listImageInfor: [ImageInfor] = []
    var listImageCreateDate = [ImagesCreateByDate]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
        photosTableView.register(UINib.init(nibName: "ListImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ListImageCell")
        
        
        self.loadPhotoFromAlbum()
        
        
    }
    
    func loadPhotoFromAlbum(){
        let imageManager = PHImageManager()
        let requestOption = PHImageRequestOptions()
        requestOption.isSynchronous = true
        requestOption.deliveryMode = .highQualityFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        
        DispatchQueue.global(qos: .background).async{
            if fetchResult.count > 0 {
                
                for i in 0..<fetchResult.count {
                    let asset = fetchResult.object(at: i)
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: requestOption, resultHandler: { image, error in
                        if let img = image{
                            print("image size: \(img.size)")
                            let location = asset.location
                            let createDate = asset.creationDate
                            let imgInfor = ImageInfor(location: location, date: createDate, img: img)
//                            print("location \(i): \(String(describing: asset.location))")
//                            print("time picked: \(i): \(String(describing: asset.creationDate))")
                            self.listImageInfor.append(imgInfor)
                            
                        }
                    })
                }
                self.listImageCreateDate = self.classifyImageByCreateDate(listImage: self.listImageInfor)
                print("")
                DispatchQueue.main.async {
                    self.photosTableView.reloadData()
                }
                
            }
        }
        
    }
    
    func getAddressFromLocation(location: CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (data, error) -> Void in
            
            //get address and extract city and state
            let address = data![0].postalAddress!
            let city = address.city
            let detailAddress = address.street + ", " + address.subAdministrativeArea + ", " + address.subLocality
            //                                    let info = address.city + ", "  + address.country + ", " + address.isoCountryCode + ", " + address.postalCode + ", " + address.state + ", " + address.street + ", " + address.subAdministrativeArea + ", " + address.subLocality
            
            let place = city + ", " + detailAddress
            print(place)
        }
        
    }
    
    func convertDictToArray(dict: [String: [ImageInfor]]) -> [ImagesCreateByDate]{
        var dictArr = [ImagesCreateByDate]()
        for (key, value) in dict{
            let imgCreateByDate = ImagesCreateByDate(createDate: key, imagesCreateByDate: value)
            dictArr.append(imgCreateByDate)
        }
        
        return dictArr
    }
    
    func classifyImageByCreateDate(listImage: [ImageInfor]) -> [ImagesCreateByDate]{
        var listDictImageCreateDate = [String: [ImageInfor]]()

        for img in listImage{
            
            if let createDate = img.createDate{
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "dd-MM-yyyy"
                let createDateStr = dateFormater.string(from: createDate)
                
                if listDictImageCreateDate.count > 0{

                    if listDictImageCreateDate.keys.contains(createDateStr){
                        listDictImageCreateDate[createDateStr]?.append(img)
                    }else{

                        listDictImageCreateDate[createDateStr] = [ImageInfor]()
                        listDictImageCreateDate[createDateStr]?.append(img)
                    }
                }else{
                    listDictImageCreateDate[createDateStr] = [ImageInfor]()
                    listDictImageCreateDate[createDateStr]?.append(img)
                    print("ahihi")
                }
                
            }
        }
        return convertDictToArray(dict: listDictImageCreateDate)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return listImageCreateDate.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListImageCell", for: indexPath) as! ListImageTableViewCell
        
        let data = listImageCreateDate[indexPath.section]
        cell.imagesCreateByDate = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width / 4 - 2
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return listImageCreateDate[section].createDate!
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HeaderView()
        view.title.text = listImageCreateDate[section].createDate
        view.showAll.tag = section
        view.showAll.addTarget(self, action: #selector(showAllImage(sender:)), for: .touchUpInside)
        return view
    }
    
    @objc func showAllImage(sender: UIButton) {
        let section = sender.tag
//        let vc = DetailImageViewController()
        let vc = PlayVideoViewController()
        vc.imagesCreateByDate = listImageCreateDate[section]
        navigationController?.pushViewController(vc, animated: true)
    }
}
