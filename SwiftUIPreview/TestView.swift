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
    @State var showLottie = false
    @State var att = AttributedString("abc123ABC", attributes: AttributeContainer([NSAttributedString.Key.strokeWidth : 3, .strokeColor: UIColor.blue]))
    var body: some View {
        VStack {
            IDCardViewRepresentable(type: 0)
                .frame(width: 343, height: 500)
                .padding(.top, 100)
            
            
//            Image("bg_card1").resizable().frame(width: 343, height: 100)
//                .overlay {
//                    VStack(spacing: 0) {
//                        AttributedText(text: Binding.constant("INFJ-Advocate"), font: UIFont.VAGRoundedNextSemiBold(size: 37) , colors: [UIColor.white], strokeWidth: 5, strokeColor: UIColor.black, maxSize: CGSize(width: 227, height: 50))
////                            .frame(width: 127, height: 40)
////                            .shadow(color: Color.black, radius: 0, y: 4)
////                            .padding(.top, 38)
//                        
////                        AttributedText(text: Binding(get: { "Insight Guards Ideals" }, set: { _ in }), font: UIFont.VAGRoundedNextBlack(size: 14) , colors: [UIColor.white], strokeWidth: 2, strokeColor: UIColor.black)
////                            .frame(height: 27)
////                            .shadow(color: Color.black, radius: 0, y: 1)
////                            .padding(.top, 20)
////                        
////                        HStack {
////                            AttributedText(text: Binding(get: { "OOTD" }, set: { _ in }), font: UIFont.VAGRoundedNextBlack(size: 14) , colors: [UIColor(hexRGB: "#F4D25F"), UIColor(hexRGB: "#E86A53")], strokeWidth: 3, strokeColor: UIColor.black)
////                                .frame(height: 27)
////                                .shadow(color: Color.black, radius: 0, y: 3)
////                                .padding(.top, 53)
////                                .padding(.leading, 18)
////                                .rotationEffect(Angle(degrees: -6))
////                            
////                            Spacer()
////                        }
////                        
////                        HStack {
////                            Spacer()
////
////                            AttributedText(text: Binding(get: { "Empathy Overload" }, set: { _ in }), font: UIFont.VAGRoundedNextBlack(size: 14) , colors: [UIColor(hexRGB: "#F4D25F"), UIColor(hexRGB: "#E86A53")], strokeWidth: 3, strokeColor: UIColor.black)
////                                .frame(height: 27)
////                                .shadow(color: Color.black, radius: 0, y: 3)
////                                .padding(.top, 98)
////                                .padding(.leading, 18)
////                                .rotationEffect(Angle(degrees: 8))
////                            
////                        }
//                        
//                        Spacer()
//
//                    }
//                }
            
            LottieView(animation: .named("swipeLeft"))
                .playing(loopMode: .loop)  // 或 .playing(), .paused()
                .frame(width: 200, height: 200)
                .background(Color.black)
            
            Button {
                showLottie = !showLottie
            } label: {
                Text("ShowLottie")
            }
            
            if showLottie {
                LottieView {
                    try await DotLottieFile.named("vipWelcome")
                }
                .playing(loopMode: .loop)
                .aspectRatio(375.0/500.0, contentMode: .fit)
                .offset(y: -20)
                .allowsHitTesting(false)
            }

            
            Spacer()
            ZStack(alignment: .bottom) {
                
                LoadingDotsView()
                
                Image("bg_tip_follow")
                    .resizable()
                    .frame(width: 316, height: 71)
                
                Text("Follow after watching!")
                    .font(.PoppinsLatinBold(size: 13))
                    .foregroundStyle(Color.white)
                    .minimumScaleFactor(0.5)
                    .frame(width: 160, height: 38)
                    .padding(.bottom, 16)
                                
                ZStack(alignment: .trailing) {
                    Text("Follow")
                        .font(.PoppinsLatinBold(size: 11))
                        .foregroundStyle(Color(hex: "333333"))
                        .minimumScaleFactor(0.5)
                        .frame(width: 57, height: 24)
                        .background(Color(hex: "FFE968"))
                        .clipShape(Capsule())
                        .background {
                            Capsule()
                                .shadow(color: Color(hex: "B80071"), radius: 0, y: 2.5)
                        }
                        .padding(.bottom, 24)
                        .offset(x: 110)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: 316, height: 71)
            Color.clear.frame(height: 2)

        }
    }
}

#Preview {
    IDCardViewRepresentable(type: 0)
}

#Preview {
    IDCardViewRepresentable(type: 1)
}

#Preview {
    IDCardViewRepresentable(type: 2)
}

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

struct IDCardViewRepresentable: UIViewRepresentable {
    var type: Int
    typealias UIViewType = IDCardView

    func makeUIView(context: Context) -> IDCardView {
        return IDCardView(frame: CGRect(x: 0, y: 0, width: 343, height: 500), type: type)
    }
    
    func updateUIView(_ uiView: IDCardView, context: Context) {
        
    }
    
    
    
}



class IDCardView: UIView {
    var type: Int
    
    init(frame: CGRect, type: Int) {
        self.type = type
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        if let type = coder.decodeObject(forKey: "type") as? Int {
            self.type = type
        } else {
            self.type = 0
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
        let bgImg = UIImageView(image: UIImage(named: "bg_idcard_1"))
        bgImg.frame = self.bounds
        addSubview(bgImg)
        
        let imageView = UIImageView()
        let url = URL(string: "https://img.zthd.io/us/avatars/264ef1293d73cacd8174ac2f406b9f74.webp")
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 34, width: 300, height: 50), text: "INFJ".localizedString + "-" + "Advocate".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
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
        let url = URL(string: "https://img.zthd.io/us/avatars/264ef1293d73cacd8174ac2f406b9f74.webp")
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 34, width: 300, height: 50), text: "ENFP".localizedString + "-" + "Campaigner".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(titleLabel)
        
        let featureLabel = createLabel(frame: CGRect(x: 95, y: 98, width: 160, height: 27), text: "Novelty & Passion-Driven".localizedString, font: UIFont.VAGRoundedNextBlack(size: 14), colors: [UIColor.white], strokeWidth: 2, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 1), shadowBlurRadius: 0, numberOfLines: 1)
        addSubview(featureLabel)
        
        let tag1Bg = createTagBgView(frame: CGRect(x: 19, y: 260, width: 85, height: 41))
        tag1Bg.transform = CGAffineTransform(rotationAngle: -6 * .pi / 180)
        addSubview(tag1Bg)
        
        let tag1 = createLabel(frame: CGRect(x: 3, y: 3, width: 85, height: 41), text: "Curiosity".localizedString, font: UIFont.VAGRoundedNextBlack(size: 16), colors: [UIColor(hexRGB: "#8BE5B6"), UIColor(hexRGB: "#F1D98B"), UIColor(hexRGB: "#DE72D8"), UIColor(hexRGB: "#74AAE8")], strokeWidth: 3, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 3), shadowBlurRadius: 0, numberOfLines: 1)
        tag1Bg.addSubview(tag1)
        
        
        let tag2Bg = createTagBgView(frame: CGRect(x: 247, y: 126, width: 82, height: 52))
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
        let url = URL(string: "https://img.zthd.io/us/avatars/264ef1293d73cacd8174ac2f406b9f74.webp")
        imageView.kf.setImage(with: url)
        imageView.frame = CGRect(x: 59, y: 137, width: 225, height: 237)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        addSubview(imageView)
        
        let titleLabel = createLabel(frame: CGRect(x: 21.5, y: 34, width: 300, height: 50), text: "INTJ".localizedString + "-" + "Architect".localizedString, font: UIFont.VAGRoundedNextBlack(size: 36), colors: [UIColor.white], strokeWidth: 5, strokeColor: .black, shadowOffset: CGSize(width: 0, height: 4), shadowBlurRadius: 0, numberOfLines: 1)
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



extension String {
    var localized: LocalizedStringKey {
        .init(self)
    }
    
    var localizedString: String {
        NSLocalizedString(self, comment: "")
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
