import UIKit

// MARK: - VideoViewController.swift
class VideoViewController: UIViewController {
    
    private let videoService: VideoServiceProtocol
    private let alertPresenter: AlertPresenterProtocol
    
    private var videos: [Video] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: VideoTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Initialization
        init(videoService: VideoServiceProtocol = VideoService(),
             alertPresenter: AlertPresenterProtocol = AlertPresenter.shared) {
            self.videoService = videoService
            self.alertPresenter = alertPresenter
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            self.videoService = VideoService()
            self.alertPresenter = AlertPresenter.shared
            super.init(coder: coder)
        }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchVideos()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        title = "熱門影片"
    }
    
    // MARK: - Data Fetching
    private func fetchVideos() {
        videoService.fetchVideos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let videos):
                    self?.videos = videos
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.alertPresenter.showError(error, on: self ?? UIViewController())
                }
            }
        }
    }
    
    // MARK: - Actions
    private func addToFavorites(_ video: Video) {
        alertPresenter.showFavoritePrompt(on: self) { [weak self] note in
            guard let self = self else { return }
            self.videoService.addToFavorites(video, note: note) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.alertPresenter.showSuccess(message: "已添加到收藏", on: self)
                    case .failure(let error):
                        self.alertPresenter.showError(error, on: self)
                    }
                }
            }
        }
    }
    
        private func showSuccessAlert() {
            let alert = UIAlertController(
                title: "成功",
                message: "已添加到收藏",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
        }
    
    // MARK: - Error Handling
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "錯誤",
            message: "無法載入影片：\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showEditAlert(for video: Video) {
        let alert = UIAlertController(
            title: "編輯影片",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = video.title
            textField.placeholder = "標題"
        }
        
        alert.addTextField { textField in
            textField.text = video.description
            textField.placeholder = "描述"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text,
                  let description = alert.textFields?[1].text,
                  let videoId = video.id else { return }
            
            let updatedVideo = Video(from: Snippet(
                title: title,
                description: description,
                thumbnails: Thumbnails(medium: ThumbnailInfo(url: video.thumbnailURL))
            ))
            
            self?.updateVideo(updatedVideo, videoId: videoId)
        })
        
        present(alert, animated: true)
    }
    

    
    private func updateVideo(_ video: Video, videoId: String) {
        NetworkManager.shared.updateVideo(video, videoId: videoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedVideo):
                    print("視頻更新成功:", updatedVideo.title)
                    self?.fetchVideos()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func deleteVideo(videoId: String) {
        NetworkManager.shared.deleteVideo(videoId: videoId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("視頻刪除成功")
                    self?.fetchVideos()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
}

extension VideoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.identifier,
                                                     for: indexPath) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        
        let video = videos[indexPath.row]
        cell.configure(with: video)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        
        let favoriteAction = UIContextualAction(style: .normal, title: "收藏") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            let video = self.videos[indexPath.row]
            self.addToFavorites(video)
            completion(true)
        }
        favoriteAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
}
