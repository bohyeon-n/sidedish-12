//
//  ViewController.swift
//  Banchan
//
//  Created by Chaewan Park on 2020/04/21.
//  Copyright © 2020 Chaewan Park. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel = CategorizedBanchanViewModel()
    private let delegate = BanchanDelegate()
    
    private let group = DispatchGroup()
    private let queue = DispatchQueue(label: "networking")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureViewModel()
        configureUseCase()
    }
    
    private func configureTableView() {
        tableView.register(BanchanHeaderView.nib, forHeaderFooterViewReuseIdentifier: BanchanHeaderView.reuseIdentifier)
        tableView.delegate = delegate
        tableView.dataSource = viewModel
    }
    
    private func configureViewModel() {
        viewModel.updateNotify { change in
            DispatchQueue.main.async {
                if let section = change?.section {
                    self.tableView.reloadSections(IndexSet(section...section), with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
                self.group.leave()
            }
        }
    }
    
    private func configureUseCase() {
        BanchanUseCase.performFetching(with: NetworkManager()) { index, banchans in
            self.queue.async {
                self.group.wait()
                self.group.enter()
                self.viewModel.append(key: index, value: banchans)
            }
        }
    }
}
