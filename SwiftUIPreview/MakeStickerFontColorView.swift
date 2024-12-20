//
//  MakeStickerFontColorView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/10/10.
//

import UIKit
import SnapKit

class MakeStickerFontColorCell: UICollectionViewCell {
    
    var colors: [UIColor] = [.black] {
        didSet {
            updateLayer()
        }
    }
    let bgView = UIView()
    let colorView = UIView()
    var bgLayer: CAGradientLayer?
    var colorLayer: CAGradientLayer?

    override var isSelected: Bool {
        didSet {
            if isSelected {
                if colors == [.white] {
                    colorView.layer.borderColor = UIColor.black.cgColor
                } else {
                    colorView.layer.borderColor = UIColor.white.cgColor
                }
                colorView.isHidden = false
            } else {
                colorView.isHidden = true
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        colorView.layer.cornerRadius = 15
        colorView.layer.borderColor = UIColor.white.cgColor
        colorView.layer.borderWidth = 2.0
        colorView.isHidden = true
        colorView.frame = CGRect(x: 2, y: 2, width: 30, height: 30)
        bgView.layer.cornerRadius = 17
        bgView.layer.masksToBounds = true
        bgView.addSubview(colorView)
        bgView.frame = CGRect(origin: .zero, size: CGSize(width: 34, height: 34))
        contentView.addSubview(bgView)
        
        bgLayer = gradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 34, height: 34)))
        bgView.layer.insertSublayer(bgLayer!, at: 0)
        colorLayer = gradientLayer(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        colorView.layer.insertSublayer(colorLayer!, at: 0)
        
    }
    
    
    func updateLayer() {
        if colors.count == 1 {
            bgLayer?.isHidden = true
            colorLayer?.isHidden = true
            bgView.backgroundColor = colors.first
            colorView.backgroundColor = colors.first
        } else {
            bgLayer?.colors = colors.map({ color in
                color.cgColor
            })
            colorLayer?.colors = colors.map({ color in
                color.cgColor
            })
            bgLayer?.isHidden = false
            colorLayer?.isHidden = false
        }
    }
    
    
    func gradientLayer(frame: CGRect) -> CAGradientLayer {
        // 创建 CAGradientLayer
        let gradientLayer = CAGradientLayer()
        // 设置渐变的颜色数组
        gradientLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor
        ]
        // 设置渐变的起始和结束点 (0,0) 为左上角，(1,1) 为右下角
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        // 设置渐变层的大小为视图的大小
        gradientLayer.frame = frame
        // 添加渐变层到视图的 layer 上
        return gradientLayer
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class MakeStickerFontColorView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var selectAction: (([UIColor]) -> Void)?
    var fontsView: UICollectionView?
    
    private var selectIndex: Int?
    var selectFontColor: [UIColor] = [.black] {
        didSet {
            if let old = colorList.firstIndex(where: { $0 == oldValue }) {
                let cell = self.fontsView?.cellForItem(at: IndexPath(item: old, section: 0))
                cell?.isSelected = false
            }
            if let item = colorList.firstIndex(where: { $0 == selectFontColor}) {
                let cell = self.fontsView?.cellForItem(at: IndexPath(item: item, section: 0))
                cell?.isSelected = true
            } else {
                if let index = selectIndex {
                    self.fontsView?.deselectItem(at:  IndexPath(item: index, section: 0), animated: true)
                }
            }
        }
    }
    
    let colorList = [
        [UIColor.black],
        [UIColor(89, 0, 255, 1), UIColor(255, 0, 109, 1)],
        [UIColor(0, 190, 255, 1), UIColor(0, 255, 45, 1)],
        [UIColor(245, 255, 0, 1), UIColor(255, 0, 0, 1)],
        [UIColor(255, 91, 0, 1), UIColor(0, 66, 255, 1)],
        [UIColor(50, 197, 255, 1), UIColor(182, 32, 224, 1), UIColor(247, 181, 0, 1)],
        [
          UIColor(182, 32, 224, 1),
          UIColor(98, 54, 255, 1),
          UIColor(0, 145, 255, 1),
          UIColor(109, 212, 0, 1),
          UIColor(247, 181, 0, 1),
          UIColor(250, 100, 0, 1),
          UIColor(224, 32, 32, 1)
        ],
        [UIColor(0, 102, 255, 1)],
        [UIColor(175, 89, 62, 1)],
        [UIColor(1, 163, 104, 1)],
        [UIColor(255, 134, 31, 1)],
        [UIColor(237, 10, 63, 1)],
        [UIColor(255, 63, 52, 1)],
        [UIColor(118, 215, 234, 1)],
        [UIColor(131, 89, 163, 1)],
        [UIColor(251, 232, 112, 1)],
        [UIColor(197, 225, 122, 1)],
      ];
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MakeStickerFontColorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MakeStickerFontColorCell", for: indexPath) as! MakeStickerFontColorCell
        cell.colors = colorList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.item
        selectFontColor = colorList[indexPath.item]
        selectAction?(selectFontColor)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let fontTitle = UILabel()
        fontTitle.text = "Font Color"
        fontTitle.textColor = UIColor(hexRGB: "#333333")
        fontTitle.font = .PoppinsLatinBold(size: 14)
        addSubview(fontTitle)
        fontTitle.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(17)
            make.height.equalTo(40)
        }
        
        // 设置 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 34, height: 34) // 自动计算 cell 大小
        layout.minimumInteritemSpacing = 10 // 列间距
        layout.minimumLineSpacing = 10 // 行间距
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let fontsView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        fontsView.delegate = self
        fontsView.dataSource = self
        fontsView.showsHorizontalScrollIndicator = false
        fontsView.register(MakeStickerFontColorCell.self, forCellWithReuseIdentifier: "MakeStickerFontColorCell")
        self.fontsView = fontsView
        addSubview(fontsView)
        fontsView.snp.makeConstraints { make in
            make.top.equalTo(fontTitle.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
