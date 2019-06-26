//
//  NMDelegate+DataSource.swift
//  NMLocalizedPhoneCountryView
//
//  Updated by Mobile Team of Namshi on 03/10/2018.
//  Originally created as CountryPickerView by Kizito Nwose on 16/02/2017.
//  Copyright © 2018 NAMSHI. All rights reserved.
//

import Foundation
import UIKit

public protocol NMLocalizedPhoneCountryViewDelegate: class {
    /// Called when the user selects a country from the list.
    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, didSelectCountry country: NMCountry)
    
    /// Called before the internal UITableViewController is presented or pushed.
    /// If the presenting view controller is not a UINavigationController, the UITableViewController
    /// is embedded in a UINavigationController.
    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, willShow viewController: UITableViewController)
    
    /// Called after the internal UITableViewController is presented or pushed.
    /// If the presenting view controller is not a UINavigationController, the UITableViewController
    /// is embedded in a UINavigationController.
    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, didShow viewController: UITableViewController)
}

public protocol NMLocalizedPhoneCountryViewDataSource: class {
    /// An array of countries you wish to show at the top of the list.
    /// This is useful if your app is targeted towards people in specific countries.
    /// - requires: The title for the section to be returned in `sectionTitleForPreferredCountries`
    func preferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> [NMCountry]
    
    /// The desired title for the preferred section.
    /// - **See:** `preferredCountries` method. Both are required for the section to be shown.
    func sectionTitleForPreferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String?
    
    /// This determines if only the preferred section is shown
    func showOnlyPreferredSection(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool
    
    /// The navigation item title when the internal view controller is pushed/presented.
    func navigationTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String?
    
    /// A navigation item button to be used if the internal view controller is presented/pushed.
    /// Return `nil` to use a default "Close" button.
    func closeButtonNavigationItem(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> UIBarButtonItem?
    
    /// The desired position for the search bar.
    func searchBarPosition(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> SearchBarPosition
    
    /// The search bar placeholder title when the internal view controller is pushed/presented.
    func searchBarPlaceholderTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String?
    
    /// The search bar cancel button title when it is being edited
    func searchBarCancelButtonTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String?
    
    /// This determines if a country's phone code is shown alongside the country's name on the list.
    /// e.g Nigeria (+234)
    func showPhoneCodeInList(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool
}

// MARK:- NMLocalizedPhoneCountryViewDataSource default implementations
public extension NMLocalizedPhoneCountryViewDataSource {
    
    func preferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> [NMCountry] {

        return []
    }
    
    func sectionTitleForPreferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {

        return nil
    }
    
    func showOnlyPreferredSection(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool {

        return false
    }
    
    func navigationTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {

        return nil
    }
    
    func closeButtonNavigationItem(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> UIBarButtonItem? {

        return nil
    }
    
    func searchBarPosition(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> SearchBarPosition {

        return .tableViewHeader
    }
    
    func searchBarPlaceholderTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {
        
        return nil
    }
    
    func searchBarCancelButtonTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {
        
        return nil
    }
    
    func showPhoneCodeInList(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool {

        return false
    }
}


// MARK:- NMLocalizedPhoneCountryViewDelegate default implementations
public extension NMLocalizedPhoneCountryViewDelegate {

    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, willShow viewController: UITableViewController) {
        
    }
    
    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, didShow viewController: UITableViewController) {

    }

}

