//
//  DetailImageViewController.swift
//  DiaryPhotoDemo
//
//  Created by Kiên Nguyễn on 12/22/17.
//  Copyright © 2017 Kien Nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class DetailImageViewController: UIViewController {
    
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var detailImageCollectionView: UICollectionView!
    
    @IBOutlet weak var litstImageCollectionView: UICollectionView!
    
    var images: [UIImage] = []
    var imagesCreateByDate: ImagesCreateByDate!{
        didSet{
            if let imagesInfors = imagesCreateByDate.imagesCreateByDate{
                for imageInfor in imagesInfors{
                    if let img = imageInfor.image{
                        images.append(img)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVideoFromImages(images: images)
    }

    func setupCollectionView() {
        //detail image collectionview
        
        detailImageCollectionView.delegate = self
        detailImageCollectionView.dataSource = self
        detailImageCollectionView.register(UINib.init(nibName: "DetailPortrailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "portrailImageCell")
        detailImageCollectionView.register(UINib.init(nibName: "DetailLanscapeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "lanscapeImageCell")
        
        litstImageCollectionView.delegate = self
        litstImageCollectionView.dataSource = self
        litstImageCollectionView.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
    }

    func initVideoFromImages(images: [UIImage]) {
        //let size = CGSize(width: 1920, height: 1280)
        let settings = CreateVideoFromImages.videoSettings(codec: AVVideoCodecType.jpeg.rawValue, width: (Int(self.playerView.frame.width)), height: (Int(self.playerView.frame.height)))
        let movieMaker = CreateVideoFromImages(videoSettings: settings)
        movieMaker.createMovieFrom(images: images){ (fileURL:URL) in
//            let video = AVAsset(url: fileURL)
            let player = AVPlayer(url: fileURL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.playerView.layer.bounds
            self.playerView.layer.addSublayer(playerLayer)
            player.play()
//            let playerItem = AVPlayerItem(asset: video)
//            let player = CXEPlayer()
//            player.setPlayerItem(playerItem: playerItem)
//
//            fileURL = player
        }
    }
}

extension DetailImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailImageCollectionView{
            return 10
        }else{
            return 10
        }
    }    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == detailImageCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath) as! DetailLanscapeCollectionViewCell
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
            return cell
        }
    }
}
