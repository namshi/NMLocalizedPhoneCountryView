//
//  NMLocalizedPhoneCountryViewController.swift
//  NMLocalizedPhoneCountryView
//
//  Updated by Mobile Team of Namshi on 03/10/2018.
//  Originally created as CountryPickerView by Kizito Nwose on 18/09/2017.
//  Copyright © 2018 NAMSHI. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class NMLocalizedPhoneCountryViewController: UITableViewController {

    fileprivate var searchController: UISearchController?
    fileprivate var searchResults = [NMCountry]()
    fileprivate var isSearchMode = false
    fileprivate var sectionsTitles = [String]()
    fileprivate var countries = [String: [NMCountry]]()
    fileprivate var hasPreferredSection: Bool {
  
        return localizedPhoneCountryView.preferredCountriesSectionTitle != nil &&
            localizedPhoneCountryView.preferredCountries.count > 0
    }
    fileprivate var originalSemanticContentAttribute: UISemanticContentAttribute!
    fileprivate var showOnlyPreferredSection: Bool {
  
        return localizedPhoneCountryView.showOnlyPreferredSection
    }
    
    weak var localizedPhoneCountryView: NMLocalizedPhoneCountryView!
    
    /// Change the font of countries list screen
    internal var font = UIFont.systemFont(ofSize: 17.0) {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSemanticContentAttribute()
        prepareTableItems()
        prepareNavItem()
        prepareSearchBar()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetSemanticContentAttribute()
    }

    func setSemanticContentAttribute() {
        self.originalSemanticContentAttribute = UIView.appearance().semanticContentAttribute
        UIView.appearance().semanticContentAttribute = localizedPhoneCountryView.localeSetup.isRTL ? .forceRightToLeft : .forceLeftToRight
    }

    func resetSemanticContentAttribute() {
        UIView.appearance().semanticContentAttribute = self.originalSemanticContentAttribute
    }
}


// UI Setup
@available(iOS 9.0, *)
extension NMLocalizedPhoneCountryViewController {
    
    func prepareTableItems()  {
        let excludedCountries = localizedPhoneCountryView.excludedCountriesList
        var countriesArray : [NMCountry] = []
        for country in localizedPhoneCountryView.getCountries() {
            if !excludedCountries.contains(country.code.uppercased()) {
                countriesArray.append(country)
            }
        }
        
        if !showOnlyPreferredSection {

            var header = Set<String>()
            countriesArray.forEach{
                let name = $0.getLocalizedName(locale: localizedPhoneCountryView.localeSetup)
                header.insert(String(name[name.startIndex]))
            }

            var data = [String: [NMCountry]]()
            countriesArray.forEach({
                let name = $0.getLocalizedName(locale: localizedPhoneCountryView.localeSetup)
                let index = String(name[name.startIndex])
                var dictValue = data[index] ?? [NMCountry]()
                dictValue.append($0)
                
                data[index] = dictValue
            })

            // Sort the sections
            data.forEach { key, value in
                data[key] = value.sorted(by: { (lhs, rhs) -> Bool in
           
                    return lhs.getLocalizedName(locale: localizedPhoneCountryView.localeSetup) < rhs.getLocalizedName(locale: localizedPhoneCountryView.localeSetup)
                })
            }

            sectionsTitles = header.sorted()
            countries = data
        }
        
        // Add preferred section if data is available
        if hasPreferredSection, let preferredTitle = localizedPhoneCountryView.preferredCountriesSectionTitle {
            sectionsTitles.insert(preferredTitle, at: sectionsTitles.startIndex)
            countries[preferredTitle] = localizedPhoneCountryView.preferredCountries
        }
    
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
    }
    
    func prepareNavItem() {
        navigationItem.title = localizedPhoneCountryView.navigationTitle

        // Add a custom close button
        let closeButton = localizedPhoneCountryView.closeButtonNavigationItem
        closeButton.target = self
        closeButton.action = #selector(close)
        navigationItem.leftBarButtonItem = closeButton
    }
    
    func prepareSearchBar() {
        let searchBarPosition = localizedPhoneCountryView.searchBarPosition
        if searchBarPosition == .hidden  {
         
            return
        }
        searchController = UISearchController(searchResultsController:  nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.hidesNavigationBarDuringPresentation = searchBarPosition == .tableViewHeader
        searchController?.definesPresentationContext = true
        searchController?.searchBar.delegate = self
        searchController?.delegate = self
        searchController?.searchBar.semanticContentAttribute = localizedPhoneCountryView.localeSetup.isOtherLocale() ? .forceRightToLeft : .forceLeftToRight
        searchController?.searchBar.placeholder = localizedPhoneCountryView.searchBarPlaceHolderTitle
        searchController?.searchBar.setValue(localizedPhoneCountryView.searchBarCancelButtonTitle, forKey: "cancelButtonText")
        searchController?.hidesNavigationBarDuringPresentation = false

        switch searchBarPosition {
        case .tableViewHeader: tableView.tableHeaderView = searchController?.searchBar
        case .navigationBar: navigationItem.titleView = searchController?.searchBar
        default: break
        }
    }
    
    @objc private func close() {
        if localizedPhoneCountryView.isViewControllerPushed {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK:- UITableViewDataSource
extension NMLocalizedPhoneCountryViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return isSearchMode ? 1 : sectionsTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return isSearchMode ? searchResults.count : countries[sectionsTitles[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        let countryName = country.getLocalizedName(locale: localizedPhoneCountryView.localeSetup)
        let name = localizedPhoneCountryView.showPhoneCodeInList ? "\(countryName) (\(country.phoneCode))" : countryName
        cell.imageView?.image = country.flag
        cell.textLabel?.text = name
        cell.textLabel?.font = self.font
        cell.accessoryType = country == localizedPhoneCountryView.selectedCountry ? .checkmark : .none
        cell.separatorInset = .zero
        cell.textLabel?.textAlignment = localizedPhoneCountryView.localeSetup.isRTL ? .right : .left

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
   
        return isSearchMode ? nil : sectionsTitles[section].uppercased()
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearchMode {
      
            return nil
        } else {
            if hasPreferredSection {
            
                return Array<String>(sectionsTitles.dropFirst())
            }
            
            return sectionsTitles
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {

        return sectionsTitles.index(of: title)!
    }
}

//MARK:- UITableViewDelegate
extension NMLocalizedPhoneCountryViewController {

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = self.font
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        searchController?.dismiss(animated: false, completion: nil)
        
        let completion = {
            self.localizedPhoneCountryView.didSelectCountry(country)
        }
        // If this is root, dismiss, else pop
        if navigationController?.viewControllers.count == 1 {
            navigationController?.dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true, completion: completion)
        }
    }
}

// MARK:- UISearchResultsUpdating
extension NMLocalizedPhoneCountryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        isSearchMode = false
        if let text = searchController.searchBar.text?.lowercased(), text.count > 0 {
            isSearchMode = true
            searchResults.removeAll()
            
            var indexArray = [NMCountry]()

            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[localizedPhoneCountryView.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(text[text.startIndex]).uppercased()] {
                indexArray = array
            }

            searchResults.append(contentsOf: indexArray.filter({ $0.getLocalizedName(locale: localizedPhoneCountryView.localeSetup).lowercased().hasPrefix(text) }))
        }
        tableView.reloadData()
    }
}

// MARK:- UISearchBarDelegate
extension NMLocalizedPhoneCountryViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Hide the back/left navigationItem button
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Show the back/left navigationItem button
        prepareNavItem()
        navigationItem.hidesBackButton = false
    }
    
}

// MARK:- UISearchControllerDelegate
// Fixes an issue where the search bar goes off screen sometimes.
extension NMLocalizedPhoneCountryViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        self.navigationController?.navigationBar.isTranslucent = false
    }
}

