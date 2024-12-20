//
//  MakeStickerViewController.swift
//  Avatar
//
//  Created by zk on 2024/9/26.
//

import UIKit
import Lottie
import SwiftUI
import SnapKit
import Kingfisher






struct MakeStickerEidtorView: UIViewControllerRepresentable {
    
    // 创建并返回 UIKit 的 UIViewController
    func makeUIViewController(context: Context) -> MakeStickerViewController {
        return MakeStickerViewController()
    }

    // 更新 UIKit 的 UIViewController，当 SwiftUI 状态更新时调用
    func updateUIViewController(_ uiViewController: MakeStickerViewController, context: Context) {
        // 在此处更新控制器（如果需要）
    }
}


class MakeStickerViewController: UIViewController, DraggableTextViewDelegate, UITextViewDelegate {

    let squareView = UIView()
    let saveButton = UIButton(type: .custom)
    var textViews: [DraggableTextView] = []
    var editingView: UIView?
    var labelTextView: DraggableTextView?
    
    var squareWith = 0.0
    var imageView = UIImageView()
    let fontView = MakeStickerFontView()
    let fontColorView = MakeStickerFontColorView()

    let textBtn = UIButton(type: .custom)
    let moreDetailBtn = UIButton(type: .custom)
    let detailScrollView = UIScrollView()
    let labelsView = MakeStickerLabelsView()
    
    let inputTextView = UITextView()
    
    
    @objc func btnClick(btn: UIButton) {
        if btn == textBtn {
            textBtn.isSelected = true
            moreDetailBtn.isSelected = false
            textBtn.titleLabel?.font = .PoppinsLatinBold(size: 17)
            moreDetailBtn.titleLabel?.font = .PoppinsLatin(size: 17)
            detailScrollView.isHidden = true
            labelsView.isHidden = false
        } else {
            textBtn.isSelected = false
            moreDetailBtn.isSelected = true
            moreDetailBtn.titleLabel?.font = .PoppinsLatinBold(size: 17)
            textBtn.titleLabel?.font = .PoppinsLatin(size: 17)
            detailScrollView.isHidden = false
            labelsView.isHidden = true
            if let textView = editingView as? DraggableTextView {
                textView.isActive = true
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        squareWith = min(view.frame.width, 460.0)
        setupSquareView()
        setupSaveButton()
        

        textBtn.setTitle("Text", for: .normal)
        textBtn.setTitleColor(UIColor(hexRGB: "#8E8E8E"), for: .normal)
        textBtn.setTitleColor(UIColor(hexRGB: "#333333"), for: .selected)
        textBtn.titleLabel?.font = .PoppinsLatinBold(size: 17)
        textBtn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        textBtn.isSelected = true
        detailScrollView.isHidden = true
        view.addSubview(textBtn)
        textBtn.snp.makeConstraints { make in
            make.top.equalTo(squareView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(40)
        }
        
        moreDetailBtn.setTitle("More Details", for: .normal)
        moreDetailBtn.setTitleColor(UIColor(hexRGB: "#8E8E8E"), for: .normal)
        moreDetailBtn.setTitleColor(UIColor(hexRGB: "#333333"), for: .selected)
        moreDetailBtn.titleLabel?.font = .PoppinsLatin(size: 17)
        moreDetailBtn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        view.addSubview(moreDetailBtn)
        moreDetailBtn.snp.makeConstraints { make in
            make.top.equalTo(squareView.snp.bottom).offset(8)
            make.leading.equalTo(textBtn.snp.trailing).offset(16)
            make.height.equalTo(40)
        }
        
        labelsView.click = {[weak self] text in
            if text.isEmpty {
                self?.addTextView(withText: "Enter Something")
                self?.inputTextView.text = ""
                self?.inputTextView.isHidden = false
                self?.inputTextView.becomeFirstResponder()
            } else {
                self?.setLabelTextView(withText: text)
            }
        }
        view.addSubview(labelsView)
        labelsView.snp.makeConstraints { make in
            make.top.equalTo(textBtn.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top)
        }
        

        view.addSubview(detailScrollView)
        detailScrollView.snp.makeConstraints { make in
            make.top.equalTo(textBtn.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top)
        }
        
        let textDetailView = UIView()
        detailScrollView.addSubview(textDetailView)
        textDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(detailScrollView.snp.width)
        }
        
//        let fontView = MakeStickerFontView()
        fontView.selectAction = {[weak self]  fontName in
            if let editingTextView = self?.editingView as? DraggableTextView {
                editingTextView.font = UIFont.CustomFont(name: fontName, size: 35)
            }
        }
        textDetailView.addSubview(fontView)
        fontView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        fontColorView.selectAction = {[weak self]  colors in
            if let editingTextView = self?.editingView as? DraggableTextView {
                editingTextView.colors = colors
            }
        }
        textDetailView.addSubview(fontColorView)
        fontColorView.snp.makeConstraints { make in
            make.top.equalTo(fontView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        let strokeView = MakeStickerStrokeView()
        strokeView.click = {[weak self] state in
            if let editingTextView = self?.editingView as? DraggableTextView {
                editingTextView.isStroke = state == 1
            }
        }
        textDetailView.addSubview(strokeView)
        strokeView.snp.makeConstraints { make in
            make.top.equalTo(fontColorView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let alignmentView = MakeStickerAlignmentView()
        alignmentView.click = {[weak self] state in
            if let editingTextView = self?.editingView as? DraggableTextView {
                editingTextView.textAlignment = NSTextAlignment(rawValue: state) ?? .center
            }
        }
        textDetailView.addSubview(alignmentView)
        alignmentView.snp.makeConstraints { make in
            make.top.equalTo(strokeView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(10)
        }
        
        inputTextView.delegate = self
        inputTextView.layer.cornerRadius = 10
        inputTextView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        inputTextView.layer.borderWidth = 2
        view.addSubview(inputTextView)
        inputTextView.snp.makeConstraints { make in
            make.bottom.equalTo(0)
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
        }
        inputTextView.isHidden = true
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if let editingView = editingView as? DraggableTextView {
            editingView.text = textView.text
        }
    }

    
    func setupSquareView() {
        let bgImageView = UIImageView(image: UIImage(named: "EditorCanvasBg"))
        bgImageView.contentMode = .scaleAspectFill
        view.addSubview(bgImageView)
        bgImageView.frame = CGRect(x: (view.bounds.width-squareWith)/2, y: 0, width: squareWith, height: squareWith)
        
//        imageView.kf.setImage(with: <#T##Source?#>)
        squareView.addSubview(imageView)
        
        squareView.clipsToBounds = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(squareTapAction))
        squareView.addGestureRecognizer(tapGes)
        view.addSubview(squareView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        squareView.frame = CGRect(x: (view.bounds.width-squareWith)/2, y: 0, width: squareWith, height: squareWith)
        
    }
    
    @objc func squareTapAction() {
        endEdit()
    }
    
    func endEdit() {
        if let textView = editingView as? DraggableTextView {
            textView.isActive = false
        }
        self.inputTextView.resignFirstResponder()
        self.inputTextView.isHidden = true
    }
    
    func setupSaveButton() {
        saveButton.setTitle("Add to iMessage", for: .normal)
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
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 42)
        // 添加渐变层到视图的 layer 上
        saveButton.layer.insertSublayer(gradientLayer, at: 0)
        saveButton.layer.cornerRadius = 21
        saveButton.layer.masksToBounds = true
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 300, height: 42))
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func setLabelTextView(withText text: String) {
        endEdit()
        if labelTextView != nil {
            labelTextView?.text = text
            labelTextView?.isActive = true
            editingView = labelTextView
            return
        }
        let labelTextView = DraggableTextView(text: text)
        squareView.addSubview(labelTextView)
        labelTextView.snp.makeConstraints { make in
            make.centerX.equalTo(squareWith/2)
            make.centerY.equalTo(squareWith/2)
            make.width.lessThanOrEqualTo(squareWith)
            make.height.greaterThanOrEqualTo(50)
        }
        labelTextView.delegate = self
        editingView = labelTextView
        self.labelTextView = labelTextView
    }
    
    func addTextView(withText text: String) {
        endEdit()
        
        let textView = DraggableTextView(text: text)
        squareView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(squareWith/2)
            make.centerY.equalTo(squareWith/2)
            make.width.lessThanOrEqualTo(squareWith)
            make.height.greaterThanOrEqualTo(50)
        }
        textView.delegate = self
        textViews.append(textView)
        editingView = textView
    }
    
    @objc func saveScreenshot() {
        endEdit()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            let image = self.takeScreenshot()
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // 保存到相册
        })
    }
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(squareView.bounds.size, false, 0)
        squareView.drawHierarchy(in: squareView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: DraggableTextViewDelegate
    func remove(textView: DraggableTextView) {
        textView.removeFromSuperview()
        textViews.removeAll { view in
            view == textView
        }
        if editingView == textView {
            editingView = nil
        }
    }
    
    func eidt(textView: DraggableTextView) {
        self.inputTextView.text = textView.text
        self.inputTextView.isHidden = false
        self.inputTextView.becomeFirstResponder()
    }
    
    func active(textView: DraggableTextView, active: Bool) {
        if active, editingView != textView {
            endEdit()
            editingView = textView
            fontView.selectFont = textView.font.fontName
            fontColorView.selectFontColor = textView.colors
            squareView.bringSubviewToFront(textView)
        }
    }
    
    func move(textView: DraggableTextView, translation: CGPoint) {
        textView.snp.updateConstraints { make in
            make.centerX.equalTo(translation.x)
            make.centerY.equalTo(translation.y)
        }
    }
    
}



protocol DraggableTextViewDelegate: AnyObject {
    func remove(textView: DraggableTextView)
    func eidt(textView: DraggableTextView)
    func active(textView: DraggableTextView, active: Bool)
    func move(textView: DraggableTextView, translation: CGPoint)
}


class DraggableTextView: UILabel {

    override var text: String? {
        didSet {
            if let text = text, !text.isEmpty {

            } else {
                text = "Enter Something"
            }
        }
    }
    
    weak var delegate: DraggableTextViewDelegate?
    var colors: [UIColor] = [.black] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var isStroke: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    private let controlImageView = UIImageView()
    private let deleteButton = UIButton(type: .custom)
    private let editButton = UIButton(type: .custom)
    private var dashLayer: CAShapeLayer?
    
    private var beginAngle: CGFloat = 0
    private var beginDistance: CGFloat = 0

    var isActive: Bool = true {
        didSet {
            updateDashedBorder()
            updateButtonVisibility()
            delegate?.active(textView: self, active: isActive)
        }
    }
    
    override public func drawText(in rect: CGRect) {
        
        guard let _ = text, let currentContext = UIGraphicsGetCurrentContext() else {
            super.drawText(in: rect)
            return
        }
        
        if isStroke {
            self.textColor = .white
            currentContext.setLineWidth(2)
            currentContext.setLineJoin(.round)
            currentContext.setTextDrawingMode(.stroke)
            super.drawText(in: rect)
        }
        
        if colors.count <= 1 {
            currentContext.setTextDrawingMode(.fill)
            self.textColor = colors.first
            super.drawText(in: rect)
            return
        }
        
        let shadowOffset = self.shadowOffset
        currentContext.setTextDrawingMode(.fill)
        if let gradientColor = drawGradientColor(in: rect, colors: colors.map({$0.cgColor})) {
            self.textColor = gradientColor
        }
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
        
        self.shadowOffset = shadowOffset
    }
    
    
    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }
        
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    convenience init(text: String) {
        self.init(frame: CGRect.zero)
        self.text = text
        self.font = UIFont.systemFont(ofSize: 35)
        self.textAlignment = .left
        self.backgroundColor = .clear
        self.numberOfLines = 0
        setupControlImageView()
        setupButtons()
        setupDashedBorder()
    }
    
    private func setupView() {
        isUserInteractionEnabled = true // 允许用户交互
        
        // 添加整体拖动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleViewPan(_:)))
        addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        addGestureRecognizer(tapGesture)
        tapGesture.require(toFail: panGesture)
        
        let tap2Gesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap2(_:)))
        tap2Gesture.numberOfTapsRequired = 2
        addGestureRecognizer(tap2Gesture)
        
    }
    
    private func setupControlImageView() {
        controlImageView.image = UIImage(named: "icon_Rotation")// 控制手柄的图标
        controlImageView.isUserInteractionEnabled = true
        addSubview(controlImageView)

        // 使用 SnapKit 进行约束
        controlImageView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().offset(10)
            make.width.height.equalTo(20) // 控制手柄的大小
        }
        
        // 添加拖动手势
        let controlPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        controlImageView.addGestureRecognizer(controlPanGesture)
    }
    
    private func setupButtons() {
        // 设置删除按钮
        deleteButton.setImage(UIImage(named: "icon_close"), for: .normal)
        deleteButton.addTarget(self, action: #selector(removeSelf), for: .touchUpInside)
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }
        // 设置编辑按钮
        editButton.setImage(UIImage(named: "icon_label_edit"), for: .normal)
        editButton.addTarget(self, action: #selector(editText), for: .touchUpInside)
        addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(20)
        }

        updateButtonVisibility()
    }
    
    private func updateButtonVisibility() {
        deleteButton.isHidden = !isActive
        editButton.isHidden = !isActive
        controlImageView.isHidden = !isActive
    }

    private func setupDashedBorder() {
        dashLayer = CAShapeLayer()
        dashLayer?.strokeColor = UIColor.red.cgColor
        dashLayer?.lineWidth = 1.0
        dashLayer?.lineDashPattern = [4, 4]
        dashLayer?.fillColor = UIColor.clear.cgColor
        updateDashedBorder()
        
        if let dashLayer = dashLayer {
            layer.insertSublayer(dashLayer, at: 0)
        }
    }
    
    private func updateDashedBorder() {
        let path = UIBezierPath(rect: bounds)
        dashLayer?.path = path.cgPath
        
        // 控制虚线边框的可见性
        dashLayer?.isHidden = !isActive
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        switch gesture.state {
        case .began:
            beginAngle = atan2(location.y - center.y, location.x - center.x)
            beginDistance = hypot(location.x - center.x, location.y - center.y)
        case .changed:
            // 计算旋转和缩放
            let angle = atan2(location.y - center.y, location.x - center.x)
            let distance = hypot(location.x - center.x, location.y - center.y)
            // 更新旋转和缩放
            self.transform = CGAffineTransformRotate(self.transform, angle - beginAngle)
                .scaledBy(x: distance / beginDistance, y: distance / beginDistance)

            updateDashedBorder() // 更新虚线边框
        case .ended, .cancelled:
            beginAngle = 0
            beginDistance = 0
        default:
            break
        }
    }

    @objc private func handleViewPan(_ gesture: UIPanGestureRecognizer) {
        guard isActive else { return } // 只有在激活状态下才允许拖动
        let translation = gesture.translation(in: superview)

        switch gesture.state {
        case .began, .changed:
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(.zero, in: superview) // 重置平移量
        case .ended, .cancelled:
            // 手势结束时，更新约束
            delegate?.move(textView: self, translation: center)
        default:
            break
        }
        
    }
    
    @objc private func handleViewTap(_ gesture: UIPanGestureRecognizer) {
        isActive = true
    }
    
    @objc private func handleViewTap2(_ gesture: UIPanGestureRecognizer) {
        delegate?.eidt(textView: self)
    }
    
    @objc func removeSelf() {
        delegate?.remove(textView: self)
    }
    
    @objc func editText() {
        delegate?.eidt(textView: self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDashedBorder() // 确保路径跟随视图的大小变化
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 检查主视图的 bounds 内是否有点击
        if super.point(inside: point, with: event) {
            return true
        }
        
        // 检查超出主视图的子视图
        for subview in self.subviews {
            let pointInSubview = subview.convert(point, from: self)
            if subview.bounds.contains(pointInSubview) {
                return true
            }
        }
        
        // 如果点击不在主视图或子视图的范围内，返回 false
        return false
    }
    
    
}


#Preview(body: {
    MakeStickerEidtorView()
})
