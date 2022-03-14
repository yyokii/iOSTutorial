//
//  DetailViewController.swift
//  RocketReserver
//
//  Created by Ellen Shapiro on 11/13/19.
//  Copyright © 2019 Apollo GraphQL. All rights reserved.
//

import UIKit

import Apollo
import KeychainSwift

class DetailViewController: UIViewController {
    
    @IBOutlet private var missionPatchImageView: UIImageView!
    @IBOutlet private var missionNameLabel: UILabel!
    @IBOutlet private var rocketNameLabel: UILabel!
    @IBOutlet private var launchSiteLabel: UILabel!
    @IBOutlet private var bookCancelButton: UIBarButtonItem!
    
    private var launch: LaunchDetailsQuery.Data.Launch? {
        didSet {
            self.configureView()
        }
    }
    
    var launchID: GraphQLID? {
        didSet {
            self.loadLaunchDetails()
        }
    }
    
    func configureView() {
        guard
            self.missionNameLabel != nil,
            let launch = self.launch else {
                return
            }
        
        self.missionNameLabel.text = launch.mission?.name
        self.title = launch.mission?.name
        
        let placeholder = UIImage(named: "placeholder")!
        
        if let missionPatch = launch.mission?.missionPatch {
            self.missionPatchImageView.sd_setImage(with: URL(string: missionPatch)!, placeholderImage: placeholder)
        } else {
            self.missionPatchImageView.image = placeholder
        }
        
        if let site = launch.site {
            self.launchSiteLabel.text = "Launching from \(site)"
        } else {
            self.launchSiteLabel.text = nil
        }
        
        if
            let rocketName = launch.rocket?.name ,
            let rocketType = launch.rocket?.type {
            self.rocketNameLabel.text = "🚀 \(rocketName) (\(rocketType))"
        } else {
            self.rocketNameLabel.text = nil
        }
        
        if launch.isBooked {
            self.bookCancelButton.title = "Cancel trip"
            self.bookCancelButton.tintColor = .red
        } else {
            self.bookCancelButton.title = "Book now!"
            // Get the color from the main window rather than the view to prevent alerts from draining color
            self.bookCancelButton.tintColor = UIApplication.shared.windows.first?.tintColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missionNameLabel.text = "Loading..."
        self.launchSiteLabel.text = nil
        self.rocketNameLabel.text = nil
        
        self.configureView()
    }
    
    private func loadLaunchDetails() {
        guard
            let launchID = self.launchID,
            launchID != self.launch?.id else {
                // This is the launch we're already displaying, or the ID is nil.
                return
            }
        
        Network.shared.apollo.fetch(query: LaunchDetailsQuery(launchId: launchID)) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                self.showAlert(title: "Network Error",
                               message: error.localizedDescription)
            case .success(let graphQLResult):
                if let launch = graphQLResult.data?.launch {
                    self.launch = launch
                }
                
                if let errors = graphQLResult.errors {
                    let message = errors
                        .map { $0.localizedDescription }
                        .joined(separator: "\n")
                    self.showAlert(title: "GraphQL Error(s)",
                                   message: message)
                }
            }
        }
    }
    
    @IBAction private func bookOrCancelTapped() {
        guard self.isLoggedIn() else {
            self.performSegue(withIdentifier: "showLogin", sender: self)
            return
        }
        
        guard let launch = self.launch else {
          // We don't have enough information yet to know
          // if we're booking or cancelling, bail.
          return
        }
            
        if launch.isBooked {
          print("Cancel trip!")
        } else {
          print("Book trip!")
        }
    }
    
    private func bookTrip(with id: GraphQLID) {
        // TODO: Add code to book trip
    }
    
    private func cancelTrip(with id: GraphQLID) {
        // TODO: Add code to cancel trip
    }
    
    private func isLoggedIn() -> Bool {
        let keychain = KeychainSwift()
        return keychain.get(LoginViewController.loginKeychainKey) != nil
    }
}

