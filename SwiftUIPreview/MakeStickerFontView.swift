//
//  MakeStickerFontView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/10/10.
//

import UIKit

class MakeStickerFontCell: UICollectionViewCell {
    
    let bgView = UIView()
    let label = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bgView.layer.borderColor = UIColor(hexRGB: "#FC4793").cgColor
                bgView.layer.borderWidth = 2.5
            } else {
                bgView.layer.borderColor = UIColor(hexRGB: "#DEDEDE").cgColor
                bgView.layer.borderWidth = 1.0
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bgView.addSubview(label)
        bgView.layer.cornerRadius = 17
        bgView.layer.borderColor = UIColor(hexRGB: "#DEDEDE").cgColor
        bgView.layer.borderWidth = 1.0
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(34)
        }
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(34)
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class MakeStickerFontView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var selectAction: ((String) -> Void)?
    var fontsView: UICollectionView?
    
    private var selectIndex: Int?
    var selectFont: String = "" {
        didSet {
            
            if let old = fonts.firstIndex(where: { $0 == oldValue }) {
                let cell = self.fontsView?.cellForItem(at: IndexPath(item: old, section: 0))
                cell?.isSelected = false
            }
            if let item = fonts.firstIndex(where: { $0 == selectFont}) {
                let cell = self.fontsView?.cellForItem(at: IndexPath(item: item, section: 0))
                cell?.isSelected = true
            } else {
                if let index = selectIndex {
                    self.fontsView?.deselectItem(at:  IndexPath(item: index, section: 0), animated: true)
                }
            }
        }
    }
    
    let fonts = [
        "Arbutus-Regular",
        "Butcherman-Regular",
        "Chewy-Regular",
        "ConcertOne-Regular",
        "Fruktur-Regular",
        "LeckerliOne-Regular",
        "Lemonada-Bold",
        "Piedra-Regular",
        "RussoOne-Regular",
        "SpicyRice-Regular",
        "WendyOne-Regular"
    ]
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MakeStickerFontCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MakeStickerFontCell", for: indexPath) as! MakeStickerFontCell
        let fontName = fonts[indexPath.item]
        cell.label.text = fontName.components(separatedBy: "-").first
        cell.label.font = UIFont.CustomFont(name: fontName, size: 14)
        cell.label.textColor = UIColor(hex: "#333333")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex = indexPath.item
        selectFont = fonts[indexPath.item]
        selectAction?(selectFont)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let fontTitle = UILabel()
        fontTitle.text = "Font"
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
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize // 自动计算 cell 大小
        layout.minimumInteritemSpacing = 10 // 列间距
        layout.minimumLineSpacing = 10 // 行间距
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let fontsView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        fontsView.delegate = self
        fontsView.dataSource = self
        fontsView.showsHorizontalScrollIndicator = false
        fontsView.register(MakeStickerFontCell.self, forCellWithReuseIdentifier: "MakeStickerFontCell")
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
