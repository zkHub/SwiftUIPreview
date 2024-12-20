//
//  MakeStickerLabelsView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/10/12.
//

import UIKit


class MakeStickerLabelsCell: UICollectionViewCell {
    
    let bgView = UIView()
    let imgView = UIImageView()
    let label = UILabel()
    var text = "" {
        didSet {
            if text.isEmpty {
                label.text = ""
                imgView.isHidden = false
            } else {
                label.text = text
                imgView.isHidden = true
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bgView.layer.borderColor = UIColor(hexRGB: "#FC4793").cgColor
                bgView.layer.borderWidth = 2.5
                label.textColor = UIColor(hexRGB: "#FD53AC")
                label.font = .PoppinsLatinBold(size: 13)
            } else {
                bgView.layer.borderColor = UIColor(hexRGB: "#DEDEDE").cgColor
                bgView.layer.borderWidth = 1.0
                label.textColor = UIColor(hexRGB: "#333333")
                label.font = .PoppinsLatinMedium(size: 13)
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.layer.cornerRadius = 14
        bgView.layer.borderColor = UIColor(hexRGB: "#DEDEDE").cgColor
        bgView.layer.borderWidth = 1.0
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.font = .PoppinsLatinMedium(size: 13)
        label.textColor = UIColor(hexRGB: "#333333")
        label.numberOfLines = 0
        label.textAlignment = .center
        bgView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        imgView.image = UIImage(named: "icon_edit")
        imgView.isHidden = true
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



class MakeStickerLabelsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var click: ((String) -> Void)?
    
    private let labels = [
        "",
        "Hello Guys",
        "HOAX!!",
        "I HEAR U",
        "Correct!",
        "MUCH LOVE",
        "I LOVE YOU",
        "Excuse ME?",
        "EXCELENTE",
        "YOU ARE THE BEST",
        "LET ME SEE",
        "WHO IS TALKING",
        "I WON'T SAY ANYTHING!",
        "THANK YOU",
        "LAST WARNING",
        "BLESS YOU",
        "PLEASE",
        "PAUSE",
        "GIVE ME FIVE!",
        "Good Morning everyone",
        "Sorry",
        "NO",
        "ONE LOVE!",
        "FOR REAL？",
        "be careful",
        "YOU ARE MY BROTHER",
        "YOU'RE SWEET!"
    ]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MakeStickerLabelsCell", for: indexPath) as! MakeStickerLabelsCell
        cell.text = labels[indexPath.item]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = labels[indexPath.item]
        click?(text)
    }
    
    
    let labelsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 76, height: 76) // 自动计算 cell 大小
        layout.minimumInteritemSpacing = 13 // 列间距
        layout.minimumLineSpacing = 13 // 行间距
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        labelsView.delegate = self
        labelsView.dataSource = self
        labelsView.register(MakeStickerLabelsCell.self, forCellWithReuseIdentifier: "MakeStickerLabelsCell")
        addSubview(labelsView)
        labelsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
