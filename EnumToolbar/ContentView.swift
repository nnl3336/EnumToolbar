//
//  ContentView.swift
//  EnumToolbar
//
//  Created by Yuki Sasaki on 2025/09/04.
//

import SwiftUI
import CoreData

enum ToolbarState {
    case normal       // 通常
    case selecting    // セルを選択してるとき
    case editing      // editボタンを押したとき
}

// 3. SwiftUI で使う
struct ContentView: View {
    
    var body: some View {
            BoolToolbarView()
                .edgesIgnoringSafeArea(.bottom)
    }
}

// 1. SwiftUI から UIViewController を表示する
struct BoolToolbarView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SlideMenuViewController {
        let vc = SlideMenuViewController()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SlideMenuViewController, context: Context) {
    }
}


class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI
    private var tableView = UITableView()
    private var bottomToolbar: UIToolbar = UIToolbar()
    
    // MARK: - Data
    private var cells: [MenuCell] = []
    
    // MARK: - State
    private var toolbarState: ToolbarState = .normal {
        didSet {
            updateToolbar()
        }
    }
    
    private var selectedItems: Set<MenuCell> = []   // ← ここで保持

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()
        setupTableView()  // toolbarの上にテーブルを配置
        updateToolbar()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView,
                       contextMenuConfigurationForRowAt indexPath: IndexPath,
                       point: CGPoint) -> UIContextMenuConfiguration? {

            print("長押し判定 indexPath.row: \(indexPath.row)")

            if indexPath.row == 0 {
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                    guard let self = self else {
                        // nil ではなく空のメニューを返す
                        return UIMenu(title: "", children: [])
                    }

                    let selectAction = UIAction(title: "Select", image: UIImage(systemName: "checkmark")) { _ in
                        // セル選択処理
                    }
                    let action1 = UIAction(title: "アクション1", image: UIImage(systemName: "star")) { _ in }
                    let action2 = UIAction(title: "アクション2", image: UIImage(systemName: "trash")) { _ in }

                    return UIMenu(title: "メニュー", children: [selectAction, action1, action2])
                }
            } else {
                return nil
            }
        }
    



    
    // MARK: - Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupToolbar() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)
        
        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Update
    private func updateToolbar() {
        switch toolbarState {
        case .normal:
            bottomToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
            ]
            
        case .selecting:
            bottomToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(title: "Move", style: .plain, target: self, action: #selector(moveTapped)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteTapped))
            ]
            
        case .editing:
            bottomToolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped)),
                UIBarButtonItem.flexibleSpace(),
                UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
            ]
        }
    }
    
    @objc private func cancelTapped() {
        toolbarState = .normal
        tableView.allowsMultipleSelection = false
        if let selected = tableView.indexPathsForSelectedRows {
            for indexPath in selected {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func addTapped() {
        let newCell = MenuCell(title: "セル \(cells.count + 1)")
        cells.append(newCell)
        tableView.reloadData()
    }
    
    @objc private func editTapped() { toolbarState = .editing }
    @objc private func moveTapped() { print("Move") }
    @objc private func deleteTapped() { print("Delete") }
    @objc private func saveTapped() { toolbarState = .normal }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cells[indexPath.row].title
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toolbarState = .selecting
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            toolbarState = .normal
        }
    }
}

//

struct MenuCell: Identifiable, Hashable {
    let id = UUID()
    var title: String
}
