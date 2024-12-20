//
//  MakeStickerSelectView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/10/11.
//

import UIKit
import SnapKit

class MakeStickerSelectView: UIView {
    var click: ((Int)->Void)?
    var imgs: [String] = [""]
    var state: Int = 0 {
        didSet {
            if imgs.indices.contains(state) {
                let img = imgs[state]
                strokeImgView.image = UIImage(named: img)
            }
        }
    }
    
    let strokeLabel = UILabel()
    let strokeImgView = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        strokeLabel.text = "Stroke the text"
        strokeLabel.textColor = UIColor(hexRGB: "#333333")
        strokeLabel.font = .PoppinsLatinBold(size: 14)
        addSubview(strokeLabel)
        
        strokeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(17)
        }
        
        addSubview(strokeImgView)
        strokeImgView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        
    }
    
    @objc func tapAction() {
        
    }

    
}


class MakeStickerStrokeView: MakeStickerSelectView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgs = ["icon_Unchecked", "icon_Select"]
        self.state = 0
    }

    override func tapAction() {
        state += 1
        if state > 1 {
            state = 0
        }
        click?(state)
    }
    
}


class MakeStickerAlignmentView: MakeStickerSelectView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgs = ["icon_alignleft", "icon_center", "icon_alignright"]
        self.state = 0
        strokeLabel.text = "Text Alignment"
    }

    override func tapAction() {
        state += 1
        if state > 2 {
            state = 0
        }
        click?(state)
    }
    
}
