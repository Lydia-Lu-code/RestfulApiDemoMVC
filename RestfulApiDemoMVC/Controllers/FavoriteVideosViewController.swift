import UIKit

class FavoriteVideosViewController: UIViewController {
    // MARK: - Properties
    private var favoriteVideos: [FavoriteVideo] = []
    
    private var favoriteManager: FavoriteManageable {
        FavoriteManagerProvider.shared.favoriteManager
    }
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(FavoriteVideoCell.self, forCellReuseIdentifier: FavoriteVideoCell.identifier)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchFavorites()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "我的收藏"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        // 新增重新整理控制項
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFavorites), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Management
    @objc private func refreshFavorites() {
        fetchFavorites()
    }
    
    private func fetchFavorites() {
        favoriteManager.fetchFavorites { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let favorites):
                    self?.favoriteVideos = favorites
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func updateFavorite(_ favorite: FavoriteVideo) {
        favoriteManager.updateFavorite(favorite) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchFavorites()
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    private func deleteFavorite(at indexPath: IndexPath) {
        let favorite = favoriteVideos[indexPath.row]
        favoriteManager.deleteFavorite(id: favorite.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.favoriteVideos.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
    
    // MARK: - Alert Controllers
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "錯誤",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showEditAlert(for favorite: FavoriteVideo) {
        let alert = UIAlertController(
            title: "編輯收藏",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = favorite.title
            textField.placeholder = "標題"
        }
        
        alert.addTextField { textField in
            textField.text = favorite.note
            textField.placeholder = "筆記"
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "更新", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?[0].text,
                  let newNote = alert.textFields?[1].text else { return }
            
            var updatedFavorite = favorite
            updatedFavorite.title = newTitle
            updatedFavorite.note = newNote
            
            self?.updateFavorite(updatedFavorite)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FavoriteVideosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteVideoCell.identifier,
                                                     for: indexPath) as? FavoriteVideoCell else {
            return UITableViewCell()
        }
        
        let favorite = favoriteVideos[indexPath.row]
        cell.configure(with: favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // 略高於普通cell，為了顯示筆記
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                  forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFavorite(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = favoriteVideos[indexPath.row]
        showEditAlert(for: favorite)
    }
}
