//
//  ImagePreviewContainerView.swift
//  MyChat
//
//  Created by Muhammad Nobel Shidqi on 20/01/23.
//

import UIKit
import SnapKit

protocol ImagePreviewContainerViewDelegate: AnyObject {
    func imagePreviewContainerView(_ view: ImagePreviewContainerView, didRemoveImage removedImage: UIImage?)
}

final class ImagePreviewContainerView: UIView {
    
    weak var delegate: ImagePreviewContainerViewDelegate?
    
    private lazy var removeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(
            UIImage(systemName: "x.circle.fill")?.withTintColor(.systemPink),
            for: .normal
        )
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(onRemoveImageButtonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var imageView: UIImageView = UIImageView()

    init() {
        super.init(frame: UIScreen.main.bounds)
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        addSubview(imageView)
        addSubview(removeImageButton)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.verticalEdges.equalToSuperview().inset(10)
            make.width.height.equalTo(55)
        }
        removeImageButton.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    @objc
    private func onRemoveImageButtonDidTap(_ sender: UIButton) {
        delegate?.imagePreviewContainerView(self, didRemoveImage: imageView.image)
    }
    
}
