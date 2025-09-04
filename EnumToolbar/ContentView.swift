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

// 1. SwiftUI から UIViewController を表示する
struct MenuCell: Identifiable, Hashable {
    let id = UUID()
    var title: String
}

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - UI
    private var tableView = UITableView()
    private var bottomToolbar: UIToolbar = UIToolbar()

    // MARK: - Data
    private var cells: [MenuCell] = []
    private var selectedItems = Set<MenuCell>()

    // MARK: - State
    private var toolbarState: ToolbarState = .normal {
        didSet { updateToolbar() }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupToolbar()
        setupTableView()
        updateToolbar()
    }

    // MARK: - Setup
    private func setupToolbar() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)

        NSLayoutConstraint.activate([
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

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
        tableView.allowsMultipleSelection = true
    }

    // MARK: - Toolbar Update
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
    @objc private func cancelTapped() {
        toolbarState = .normal
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        selectedItems.removeAll()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let menuCell = cells[indexPath.row]
        cell.textLabel?.text = menuCell.title
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toolbarState = .selecting
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            toolbarState = .normal
        }
    }

    // MARK: - Context Menu (長押し)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {

        let menuCell = cells[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else {
                return UIMenu(title: "", children: [])
            }

            // 選択できない場合は非活性
            let attributes: UIMenuElement.Attributes =
                self.selectedItems.contains(menuCell) ? [] : []

            let selectAction = UIAction(title: "Select", attributes: attributes) { _ in
                if self.selectedItems.contains(menuCell) {
                    self.selectedItems.remove(menuCell)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                    self.selectedItems.insert(menuCell)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
                self.toolbarState = .selecting
                print("Selected: \(self.selectedItems.map { $0.title })")
            }

            let action1 = UIAction(title: "アクション1") { _ in print("アクション1") }
            let action2 = UIAction(title: "アクション2") { _ in print("アクション2") }

            return UIMenu(title: "メニュー", children: [selectAction, action1, action2])
        }
    }
}
