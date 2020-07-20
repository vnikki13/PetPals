//
//  Profile.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/19/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
