//
//  VideoThumbnailView.swift
//  RestfulApiDemoMVC
//
//  Created by Lydia Lu on 2024/11/5.
//

import Foundation
import UIKit

class VideoThumbnailView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        backgroundColor = .systemGray6
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }.resume()
    }
}
