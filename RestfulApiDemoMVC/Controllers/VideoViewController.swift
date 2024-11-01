import UIKit

// MARK: - VideoViewController.swift
class VideoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var videos: [Video] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: VideoTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        fetchVideos()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        title = "熱門影片"
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let video = videos[indexPath.row]
        showEditAlert(for: video)
    }
    
    // 實現滑動刪除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let video = videos[indexPath.row]
            // 假設 video.id 存在
            if let videoId = video.id {
                deleteVideo(videoId: videoId)
            }
        }
    }
    
    // MARK: - Networking
    private func fetchVideos() {
        NetworkManager.shared.fetchVideos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let videos):
                    self?.videos = videos
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Fetch error:", error)
                    self?.showError(error)
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
    
    // MARK: - CRUD UI Actions
    @objc private func addButtonTapped() {
        showCreateAlert()
    }
    
    private func showCreateAlert() {
        let alert = UIAlertController(
            title: "新增影片",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "標題"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "描述"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "新增", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text,
                  let description = alert.textFields?[1].text else { return }
            
            let newVideo = Video(from: Snippet(
                title: title,
                description: description,
                thumbnails: Thumbnails(medium: ThumbnailInfo(url: "placeholder_url"))
            ))
            
            self?.createNewVideo(newVideo)
        })
        
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
    
    // MARK: - CRUD Operations
    private func createNewVideo(_ video: Video) {
        NetworkManager.shared.createVideo(video: video) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let video):
                    print("視頻創建成功:", video.title)
                    self?.fetchVideos()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
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

extension VideoViewController {
    // 添加收藏功能到現有的 TableView
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        
        let favoriteAction = UIContextualAction(style: .normal, title: "收藏") { [weak self] (action, view, completion) in
            let video = self?.videos[indexPath.row]
            self?.addToFavorites(video)
            completion(true)
        }
        favoriteAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    private func addToFavorites(_ video: Video?) {
        guard let video = video else { return }
        
        let alert = UIAlertController(
            title: "添加到收藏",
            message: "要添加筆記嗎？",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "筆記（選填）"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "確定", style: .default) { [weak self] _ in
            let note = alert.textFields?.first?.text
            let favoriteVideo = FavoriteVideo(from: video, note: note)
            
            LocalFavoriteManager.shared.addToFavorites(favoriteVideo) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showSuccessAlert()
                    case .failure(let error):
                        self?.showError(error)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}
