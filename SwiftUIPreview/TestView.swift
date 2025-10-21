//
//  TestView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/6/25.
//

import SwiftUI
import Lottie
import Kingfisher

struct TestView: View {
    @State var save = false
    @State var showLottie = false
    @State var att = AttributedString("abc123ABC", attributes: AttributeContainer([NSAttributedString.Key.strokeWidth : 3, .strokeColor: UIColor.blue]))
    
    @State var text: String = ""
    @State var text1: String = ""
    @FocusState private var focusedField: String?
    
    @ViewBuilder
    func commentGuide() -> some View {
        Image("img_comment_guidebox").resizable().frame(width: 287, height: 99)
            .overlay(alignment: .topLeading) {
                Image("icon_Select").resizable()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .padding(.top, 8).padding(.leading, 16)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("Waiting for your message... tick-tock~").font(.PoppinsLatinMedium(size: 13)).foregroundStyle(Color.black).minimumScaleFactor(0.3)
                    .frame(width: 181, height: 44)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 34).padding(.trailing, 22)
            }
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 6)
            .padding(.bottom, 80)
    }
    
    
    var body: some View {
        VStack {

            commentGuide()
            
            ZStack {
                VStack {
                    Color.clear.frame(height: 10)
                    Color.black
                    Color.blue
                    Color.red
                }
                

//                        .blur(radius: 40) // 模糊半径
//                        .frame(width: 300, height: 200)
                Rectangle().fill(.ultraThinMaterial)
                Color.white.opacity(0.8)
//                Rectangle().fill(.ultraThinMaterial)

//                    .background(.ultraThinMaterial)
//                    .blur(radius: 40)
                
            }
            
            
//            IDCardViewRepresentable(url: "", save: $save, type: 0, onClose: {
//                
//            })
//                .frame(width: 343, height: 500)
//                .padding(.top, 100)
//                .padding(.bottom, 14)
//            Button {
//                save = true
//            } label: {
//                Text("Save").font(.PoppinsLatinBold(size: 16)).foregroundStyle(Color.white)
//                    .frame(width: 250, height: 54)
//                    .background(.red)
//            }
            
//            LottieView(animation: .named("swipeLeft"))
//                .playing(loopMode: .loop)  // 或 .playing(), .paused()
//                .frame(width: 200, height: 200)
//                .background(Color.black)
//            
//            LottieView {
//                try await DotLottieFile.named("vipWelcome")
//            }
//            .playing(loopMode: .loop)
//            .aspectRatio(375.0/500.0, contentMode: .fit)
//            .offset(y: -20)
//            .allowsHitTesting(false)

            
            LoadingDotsView()

        }

    }
}


#Preview {
    TestView()
}

//#Preview {
//    IDCardViewRepresentable(type: 0)
//}
//
//#Preview {
//    IDCardViewRepresentable(type: 1)
//}
//
//#Preview {
//    IDCardViewRepresentable(type: 2)
//}

struct LoadingDotsView: View {
    @State private var dotCount = 1
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let maxDots: Int = 3

    var body: some View {
        let dots = String(repeating: ".", count: dotCount)
        Text("Loading\(dots)")
            .onReceive(timer) { _ in
                dotCount = dotCount % maxDots + 1
            }
    }
}

//
//  IDCardView.swift
//  Avatar
//
//  Created by zk on 2025/9/10.
//

import SwiftUI
import Kingfisher
import Photos


struct IDCardCreateView: View {
    @State var url: String
    var portal: String
    var onClose: ()->Void
    
    @State private var save = false
    
    var body: some View {
        VStack(spacing: 0) {
            let type = Int.random(in: 0...2)
            let typeStr = type == 0 ? "INFJ" : (type == 1 ? "ENFP" : "INTJ")
            HStack {
                Spacer()
                Button {
//                    Collector.collect(["portal": portal, "Style": "\(typeStr)"], "IDCard_Close_Click")
                    onClose()
                } label: {
                    Image("icon_close_2").resizable().frame(width: 24, height: 24).padding(20)
                }
            }
            .frame(width: 343)

            IDCardViewRepresentable(url: url, save: $save, type: type, onClose: {
                onClose()
            })
            .frame(width: 343, height: 500)
            .onAppear {
//                Collector.collect(["portal": portal, "Style": "\(typeStr)"], "IDCard_Show")
            }

            Button {
                save = true
//                Collector.collect(["portal": portal, "Style": "\(typeStr)"], "IDCard_Save_Click")
            } label: {
                Text("Save").font(.PoppinsLatinBold(size: 16)).foregroundStyle(Color.white)
                    .frame(width: 250, height: 54)
//                    .background(LinearGradient(colors: Color.buttonGradient, startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
            .padding(.bottom, 100)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
        
    }
}




struct IDCardViewRepresentable: UIViewRepresentable {
    var url: String
    @Binding var save: Bool
    var type: Int
    var onClose: ()->Void
    typealias UIViewType = IDCardView

    func makeUIView(context: Context) -> IDCardView {
        return IDCardView(frame: CGRect(x: 0, y: 0, width: 343, height: 500), type: type, url: url)
    }
    
    func updateUIView(_ uiView: IDCardView, context: Context) {
        if save {
            uiView.saveScreenshot { suc in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    save = false
                    if suc {
                        onClose()
                    }
                })
            }
        }
    }
    
}



class IDCardView: UIView {
    var url: String
    var type: Int
    
    private var bgImg = UIImageView()
    
    
    func setupSaveButton() {
        let saveButton = UIButton(type: .custom)
        saveButton.setTitle("Save".localizedString, for: .normal)
        saveButton.addTarget(self, action: #selector(saveScreenshot), for: .touchUpInside)
        // 创建 CAGradientLayer
        let gradientLayer = CAGradientLayer()
        // 设置渐变的颜色数组
        gradientLayer.colors = [
            UIColor(hexRGB: "#FB458F").cgColor,   // 起始颜色
            UIColor(hexRGB: "#FF5DC2").cgColor   // 结束颜色
        ]
        // 设置渐变的起始和结束点 (0,0) 为左上角，(1,1) 为右下角
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        // 设置渐变层的大小为视图的大小
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 250, height: 54)
        // 添加渐变层到视图的 layer 上
        saveButton.layer.insertSublayer(gradientLayer, at: 0)
        saveButton.layer.cornerRadius = 21
        saveButton.layer.masksToBounds = true
        addSubview(saveButton)
    }
    
    @objc func saveScreenshot(done: @escaping (Bool)->Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
//                    Sper.alertTopError("Photo library access is required")
                }
                done(false)
                return
            }
            DispatchQueue.main.async {
                let image = self.takeScreenshot()
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                done(true)
                DispatchQueue.main.async {
//                    Sper.alertBottomDone("Save success")
                }
            }
        }
    }
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        var image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        if let pngData = image.pngData(), let png = UIImage(data: pngData) {
            image = png
        }
        return image
    }
    
    
    init(frame: CGRect, type: Int, url: String) {
        self.type = type
        self.url = url
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        if let type = coder.decodeObject(forKey: "type") as? Int {
            self.type = type
        } else {
            self.type = 0
        }
        if let type = coder.decodeObject(forKey: "url") as? String {
            self.url = type
        } else {
            self.url = ""
        }
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        if type == 1 {
            createENFPView()
        } else if type == 2 {
            createINTJView()
        } else {
            createINFJView()
        }
    }
    
    func createINFJView() {
        bgImg = UIImageView(image: UIImage(named: "bg_idcard_1"))
        bgImg.frame = self.bounds
        addSubview(bgImg)
        
        let imageView = UIImageView()
        let url = URL(string: url)
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 30, width: 300, height: 56), text: "INFJ".localizedString + "-" + "Advocate".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(titleLabel)
        
        let featureLabel = createLabel(frame: CGRect(x: 95, y: 98, width: 160, height: 27), text: "Insight Guards Ideals".localizedString, font: UIFont.VAGRoundedNextBlack(size: 14), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 1), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(featureLabel)
        
        let tag1Bg = createTagBgView(frame: CGRect(x: 19, y: 175, width: 64, height: 32))
        tag1Bg.transform = CGAffineTransform(rotationAngle: -6 * .pi / 180)
        addSubview(tag1Bg)
        
        let tag1 = createLabel(frame: CGRect(x: 3, y: 2, width: 64, height: 32), text: "OOTD".localizedString, font: UIFont.VAGRoundedNextBlack(size: 16), colors: [UIColor(hexRGB: "#F4D25F"), UIColor(hexRGB: "#E86A53")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 1)
        tag1Bg.addSubview(tag1)
        
        
        let tag2Bg = createTagBgView(frame: CGRect(x: 237, y: 297, width: 96, height: 52))
        tag2Bg.transform = CGAffineTransform(rotationAngle: 8 * .pi / 180)
        addSubview(tag2Bg)
        let tag2 = createLabel(frame: CGRect(x: 5, y: 5, width: 90, height: 48), text: "Much Empathy".localizedString, font: UIFont.VAGRoundedNextBlack(size: 18), colors: [UIColor(hexRGB: "#F4D25F"), UIColor(hexRGB: "#E86A53")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 0, lineHeight: 19)
        tag2Bg.addSubview(tag2)
        
        let intro = createLabel(frame: CGRect(x: 74, y: 396, width: 200, height: 50), text: "\"Counselor Personality\": Niche but Deep".localizedString, font: UIFont.VAGRoundedNextBlack(size: 17), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 2), shadowBlurRadius: 0, numberOfLines: 2)
        addSubview(intro)
    }
    
    func createENFPView() {
        let bgImg = UIImageView(image: UIImage(named: "bg_idcard_2"))
        bgImg.frame = self.bounds
        addSubview(bgImg)
        
        let imageView = UIImageView()
        let url = URL(string: url)
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 30, width: 300, height: 56), text: "ENFP".localizedString + "-" + "Campaigner".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(titleLabel)
        
        let featureLabel = createLabel(frame: CGRect(x: 95, y: 98, width: 160, height: 27), text: "Novelty & Passion-Driven".localizedString, font: UIFont.VAGRoundedNextBlack(size: 14), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 1), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(featureLabel)
        
        let tag1Bg = createTagBgView(frame: CGRect(x: 19, y: 260, width: 85, height: 41))
        tag1Bg.transform = CGAffineTransform(rotationAngle: -6 * .pi / 180)
        addSubview(tag1Bg)
        
        let tag1 = createLabel(frame: CGRect(x: 3, y: 3, width: 85, height: 41), text: "Curiosity".localizedString, font: UIFont.VAGRoundedNextBlack(size: 16), colors: [UIColor(hexRGB: "#8BE5B6"), UIColor(hexRGB: "#F1D98B"), UIColor(hexRGB: "#DE72D8"), UIColor(hexRGB: "#74AAE8")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 1)
        tag1Bg.addSubview(tag1)
        
        
        let tag2Bg = createTagBgView(frame: CGRect(x: 247, y: 130, width: 82, height: 52))
        tag2Bg.transform = CGAffineTransform(rotationAngle: 8 * .pi / 180)
        addSubview(tag2Bg)
        let tag2 = createLabel(frame: CGRect(x: 5, y: 5, width: 76, height: 48), text: "Back to School".localizedString, font: UIFont.VAGRoundedNextBlack(size: 16), colors: [UIColor(hexRGB: "#D68EFE"), UIColor(hexRGB: "#F5EF84"), UIColor(hexRGB: "#92EFD6"), UIColor(hexRGB: "#D3D4FF")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 0, lineHeight: 19)
        tag2Bg.addSubview(tag2)
        
        let intro = createLabel(frame: CGRect(x: 74, y: 396, width: 200, height: 50), text: "\"Cheerful Puppy\": Enthusiastic, creative".localizedString, font: UIFont.VAGRoundedNextBlack(size: 17), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 2), shadowBlurRadius: 0, numberOfLines: 2)
        addSubview(intro)
    }
    
    
    func createINTJView() {
        let bgImg = UIImageView(image: UIImage(named: "bg_idcard_3"))
        bgImg.frame = self.bounds
        addSubview(bgImg)
        
        let imageView = UIImageView()
        let url = URL(string: url)
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 30, width: 300, height: 56), text: "INTJ".localizedString + "-" + "Architect".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(titleLabel)
        
        let featureLabel = createLabel(frame: CGRect(x: 95, y: 98, width: 160, height: 27), text: "Reason Builds Future".localizedString, font: UIFont.VAGRoundedNextBlack(size: 14), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 1), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(featureLabel)
        
        let tag1Bg = createTagBgView(frame: CGRect(x: 19, y: 175, width: 80, height: 50))
        tag1Bg.transform = CGAffineTransform(rotationAngle: -6 * .pi / 180)
        addSubview(tag1Bg)
        
        let tag1 = createLabel(frame: CGRect(x: 3, y: 3, width: 80, height: 50), text: "Sharp Roast".localizedString, font: UIFont.VAGRoundedNextBlack(size: 18), colors: [UIColor(hexRGB: "#FDE9B0"), UIColor(hexRGB: "#99E1F7")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 2, lineHeight: 19)
        tag1Bg.addSubview(tag1)
        
        
        let tag2Bg = createTagBgView(frame: CGRect(x: 237, y: 297, width: 100, height: 50))
        tag2Bg.transform = CGAffineTransform(rotationAngle: 8 * .pi / 180)
        addSubview(tag2Bg)
        let tag2 = createLabel(frame: CGRect(x: 3, y: 3, width: 100, height: 50), text: "Focus on Work".localizedString, font: UIFont.VAGRoundedNextBlack(size: 18), colors: [UIColor(hexRGB: "#FDE9B0"), UIColor(hexRGB: "#99E1F7")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 0, lineHeight: 19)
        tag2Bg.addSubview(tag2)
        
        let intro = createLabel(frame: CGRect(x: 74, y: 396, width: 200, height: 50), text: "\"Cool top student\"：calmness, strategy".localizedString, font: UIFont.VAGRoundedNextBlack(size: 17), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 2), shadowBlurRadius: 0, numberOfLines: 2)
        addSubview(intro)
    }
    
    
    func createLabel(frame: CGRect, text: String, font: UIFont, colors: [UIColor], strokeWidth: CGFloat, strokeColor: UIColor, shadowOffset: CGSize, shadowBlurRadius: CGFloat, numberOfLines: Int = 0, lineHeight: CGFloat = 0) -> GradientLabel {
        let titleLabel = GradientLabel(frame: frame)
        titleLabel.text = text
        titleLabel.font = font
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = numberOfLines
        titleLabel.colors = colors
        titleLabel.start = CGPointMake(0.5, 0)
        titleLabel.end = CGPointMake(0.5, 1)
        titleLabel.strokeWidth = strokeWidth
        titleLabel.strokeColor = strokeColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustFontSizeToFitMultiline(minScale: 0.5, lineHeight: lineHeight)
        
        // 创建阴影
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowOffset = shadowOffset
        shadow.shadowBlurRadius = shadowBlurRadius

        let paragraphStyle = NSMutableParagraphStyle()
        if lineHeight > 0 {
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
        }
        paragraphStyle.alignment = .center
        // 创建带阴影的富文本
        let attributes: [NSAttributedString.Key: Any] = [
            .shadow: shadow, .paragraphStyle: paragraphStyle
        ]
        let attributedText = NSAttributedString(string: titleLabel.text ?? "", attributes: attributes)
        titleLabel.attributedText = attributedText
        return titleLabel
    }
    
    func createTagBgView(frame: CGRect) -> UIView {
        let bgView = UIImageView(frame: CGRect(x: frame.minX-3, y: frame.minY-3, width: frame.width+6, height: frame.height+10))
        bgView.image = UIImage(named: "bg_idcard_text")
        bgView.layer.allowsEdgeAntialiasing = true
        bgView.layer.shouldRasterize = true
        bgView.layer.rasterizationScale = UIScreen.main.scale
        return bgView
    }
    
}


extension UILabel {
    func adjustFontSizeToFitMultiline(minScale: CGFloat = 0.5, lineHeight: CGFloat = 0) {
        guard let text = text, !text.isEmpty else { return }
        
        let originalFont = font ?? UIFont.systemFont(ofSize: 17)
        var currentFontSize = originalFont.pointSize
        
        while currentFontSize > originalFont.pointSize * minScale {
            let testFont = UIFont(descriptor: originalFont.fontDescriptor, size: currentFontSize)
            
            let paragraphStyle = NSMutableParagraphStyle()
            if lineHeight > 0 {
                paragraphStyle.minimumLineHeight = lineHeight
                paragraphStyle.maximumLineHeight = lineHeight
            }
            paragraphStyle.alignment = .center
            let attributes = [NSAttributedString.Key.font: testFont, .paragraphStyle: paragraphStyle]
            
            let textSize = (text as NSString).boundingRect(
                with: CGSize(width: frame.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            
            if textSize.height <= frame.height {
                font = testFont
                break
            }
            
            currentFontSize -= 1.0
        }
        
        if currentFontSize <= originalFont.pointSize * minScale {
            font = UIFont(descriptor: originalFont.fontDescriptor, size: originalFont.pointSize * minScale)
        }
    }
}



struct IDCardSelectView: View {
    @State var img: UIImage
    var onCreateOC: ()->Void
    var onCreateCard: ()->Void
    var onClose: ()->Void
    
    @State private var save = false
    
    var body: some View {
        VStack(spacing: 0) {
//            HStack {
//                Spacer()
//                Button {
//                    onClose()
//                } label: {
//                    Image("icon_close_vip").resizable().frame(width: 24, height: 24).padding(20)
//                }
//            }
//            .padding(.horizontal, 16)
            
            VStack(spacing: 20) {
                Image(uiImage: img).resizable().frame(width: 200, height: 200)
                    .padding(.top, 40)
                
                Text("Great creation! Craft an OC/ID Card to boost love for your avatar~").font(.PoppinsLatinMedium(size: 16)).foregroundStyle(Color(hex: "#333333")).multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                HStack(spacing: 20) {
                    Button {
                        onCreateOC()
                    } label: {
                        VStack(spacing: 8) {
                            Image("icon_idcard_oc").resizable().frame(width: 36, height: 36)
                            Text("Create OC").font(.PoppinsLatinMedium(size: 12)).foregroundStyle(Color(hex: "#333333"))
                        }
                        .frame(width: 134, height: 122)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        }
                    }
                    
                    Button {
                        onCreateCard()
                    } label: {
                        VStack(spacing: 8) {
                            Image("icon_idcard_card").resizable().frame(width: 36, height: 36)
                            Text("Create ID Card").font(.PoppinsLatinMedium(size: 12)).foregroundStyle(Color(hex: "#333333"))
                        }
                        .frame(width: 134, height: 122)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#E5E5E5"), lineWidth: 1)
                        }
                    }
                }
                .padding(.bottom, 40)
                
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    onClose()
                } label: {
                    Image("icon_close_b").resizable().frame(width: 14, height: 14).padding(22)
                }
            }
            .frame(maxWidth: 400)
            .background(.white)
            .cornerRadius(20)
            .padding(.horizontal, 16)
            .padding(.bottom, 120)

            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
        
    }
}

extension String {
    var localized: LocalizedStringKey {
        .init(self)
    }
    
    var localizedString: String {
        NSLocalizedString(self, comment: "")
    }
}
