//
//  NMLocalizedPhoneCountryView.swift
//  NMLocalizedPhoneCountryView
//
//  Updated by Mobile Team of Namshi on 03/10/2018.
//  Originally created as CountryPickerView by Kizito Nwose on 18/09/2017.
//  Copyright © 2018 NAMSHI. All rights reserved.
//

import UIKit

public enum SearchBarPosition {
    case tableViewHeader, navigationBar, hidden
}

public enum FontTrait {
    case normal, bold, italic
}

public struct NMLocaleSetup {
    internal var baseLocale : String = "Base"
    internal var isRTL : Bool = false

    public init(baseLocale: String = "Base",
                isRTL: Bool = false) {
        self.baseLocale = baseLocale
        self.isRTL = isRTL
    }
    
    internal func isOtherLocale() -> Bool {

        return self.baseLocale != "Base"
    }
}

public struct NMState {
    private var name: String
    private var nameOtherLocale: String
    public var code: String

    internal init(name: String,
                  nameOtherLocale: String,
                  code: String) {
        self.name = name
        self.nameOtherLocale = nameOtherLocale
        self.code = code
    }
    
    public func getLocalizedName(locale: NMLocaleSetup) -> String {

        return (locale.baseLocale == "Base") ? self.name : self.nameOtherLocale
    }
}

public struct NMCountry {
    private var name: String
    private var nameOtherLocale: String
    public var code: String
    public var phoneCode: String
    public var postalCode: String = ""
    public var states: [NMState] = []
    public var carrierCodes: [String] = []
    private var currentLocale: NMLocaleSetup
    public var flag: UIImage {

        return UIImage(named: "NMLocalizedPhoneCountryView.bundle/Images/\(code.uppercased())",
            in: Bundle(for: NMLocalizedPhoneCountryView.self), compatibleWith: nil)!
    }
    
    internal init(name: String,
                  nameOtherLocale: String,
                  countryCode: String,
                  phoneCode: String,
                  postalCode: String?,
                  carrierCodes: [String]?,
                  states: [NSDictionary]?,
                  localeSetup: NMLocaleSetup) {
        self.name = name
        self.nameOtherLocale = nameOtherLocale
        self.code = countryCode
        self.phoneCode = phoneCode
        self.postalCode = postalCode ?? ""
        self.carrierCodes = []
        self.states = []
        self.currentLocale = localeSetup
        if let statesList = states {
            for stateObj in statesList {
                guard let stateName = stateObj["name"] as? String,
                    let stateCode = stateObj["code"] as? String else {
                        continue
                }
                var stateNameOtherLocale = stateName
                if localeSetup.isOtherLocale() {
                    let key = "name_\(localeSetup.baseLocale)"
                    if let nameOther = stateObj[key] as? String, nameOther.count > 0 {
                        stateNameOtherLocale = nameOther
                    }
                }
                let state = NMState(name: stateName, nameOtherLocale: stateNameOtherLocale, code: stateCode)
                self.states.append(state)
            }
        }
        if let carrierCodesList = carrierCodes {
            self.carrierCodes = carrierCodesList
        }
    }
    
    public func getLocalizedName(locale: NMLocaleSetup) -> String {

        return (locale.baseLocale == "Base") ? self.name : self.nameOtherLocale
    }
    
    public func fetchStateForName(_ stateName: String) -> NMState? {
        var selectedState : NMState? = nil
        for state in self.states {
            if stateName == state.getLocalizedName(locale: self.currentLocale) {
                selectedState = state
                break
            }
        }

        return selectedState
    }
    
    public func fetchStateForCode(stateCode: String) -> NMState? {
        var selectedState : NMState? = nil
        for state in self.states {
            if stateCode == state.code {
                selectedState = state
                break
            }
        }
        
        return selectedState
    }
}

public func ==(lhs: NMCountry, rhs: NMCountry) -> Bool {

    return lhs.code == rhs.code
}

public func !=(lhs: NMCountry, rhs: NMCountry) -> Bool {

    return lhs.code != rhs.code
}


public class NMLocalizedPhoneCountryView: NMNibView {
    @IBOutlet weak var spacingConstraint: NSLayoutConstraint!
    @IBOutlet public weak var flagImageView: UIImageView!
    @IBOutlet fileprivate weak var countryDetailsLabel: UILabel!
    internal var isViewControllerPushed: Bool = false
    public var jsonCountries: Array<Any>? = nil
    public var localeSetup : NMLocaleSetup = NMLocaleSetup() {
        didSet { setup() }
    }

    // Show/Hide the country code on the view.
    public var showCountryCodeInView = true {
        didSet { setup() }
    }
    
    // Exclude countries list
    public var excludedCountriesList : [String] = [] {
        didSet { setup() }
    }
    
    // Show/Hide the phone code on the view.
    public var showPhoneCodeInView = true {
        didSet { setup() }
    }
    
    /// Change the font of phone code
    public var normalFont = UIFont.systemFont(ofSize: 17.0) {
        didSet { setup() }
    }
    
    /// Set the font trait for selectedCountryView
    public var selectedCountryFontTrait : FontTrait = .bold {
        didSet { setup() }
    }
    
    /// Set the font trait for Countries List View Controller
    public var countriesListFontTrait : FontTrait = .normal
    
    /// Change the text color of phone code
    public var textColor = UIColor.black {
        didSet { setup() }
    }
    
    /// The spacing between the flag image and the text.
    public var flagSpacingInView: CGFloat {
        get {
    
            return spacingConstraint.constant
        }
        set {
            spacingConstraint.constant = newValue
        }
    }

    weak public var dataSource: NMLocalizedPhoneCountryViewDataSource?
    weak public var delegate: NMLocalizedPhoneCountryViewDelegate?
    
    fileprivate var _selectedCountry: NMCountry?
    internal(set) public var selectedCountry: NMCountry {
        get {
            let countries = getCountries()
            return _selectedCountry
                ?? countries.first(where: { $0.code == Locale.current.regionCode })
                ?? countries.first(where: { $0.code == "NG" })!
        }
        set {
            _selectedCountry = newValue
            setup()
        }
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        flagImageView.image = selectedCountry.flag
        countryDetailsLabel.font = self.getFontForSymbolicTrait(trait: selectedCountryFontTrait)
        countryDetailsLabel.textColor = textColor
        countryDetailsLabel.textAlignment = localeSetup.isOtherLocale() ? .right : .left
        if showPhoneCodeInView && showCountryCodeInView {
            countryDetailsLabel.text = "(\(selectedCountry.code)) \(selectedCountry.phoneCode)"

            return
        }
        
        if showCountryCodeInView || showPhoneCodeInView {
            countryDetailsLabel.text = showCountryCodeInView ? selectedCountry.code : selectedCountry.phoneCode
        } else {
            countryDetailsLabel.text = nil
        }
    }
    
    @IBAction func openCountryPickerController(_ sender: Any) {
        if let vc = window?.topViewController {
            if let tabVc = vc as? UITabBarController,
                let selectedVc = tabVc.selectedViewController {
                showCountriesList(from: selectedVc)
            } else {
                showCountriesList(from: vc)
            }
        }
    }
    
    public func showCountriesList(from viewController: UIViewController) {
        let countryVc = NMLocalizedPhoneCountryViewController(style: .grouped)
        countryVc.localizedPhoneCountryView = self
        countryVc.font = self.getFontForSymbolicTrait(trait: countriesListFontTrait)
        if let viewController = viewController as? UINavigationController {
            delegate?.localizedPhoneCountryView(self, willShow: countryVc)
            viewController.pushViewController(countryVc, animated: true) {
                self.isViewControllerPushed = true
                self.delegate?.localizedPhoneCountryView(self, didShow: countryVc)
            }
        } else {
            let navigationVC = UINavigationController(rootViewController: countryVc)
            delegate?.localizedPhoneCountryView(self, willShow: countryVc)
            viewController.present(navigationVC, animated: true) {
                self.isViewControllerPushed = false
                self.delegate?.localizedPhoneCountryView(self, didShow: countryVc)
            }
        }
    }
    
    internal func getCountries() -> [NMCountry] {
        var countries = [NMCountry]()
        if jsonCountries == nil {
            // get Local Bundle Countries
            countries = getLocalCountries()
        } else {
            // get Countries From the Application
            countries = getCountriesFrom(self.jsonCountries!)
            // fallback To Local Countries On Empty Remote Countries
            if countries.count == 0 {
                countries = getLocalCountries()
            }
        }
        
        return countries
    }
    
    private func getLocalCountries() -> [NMCountry] {
        var countries = [NMCountry]()
        let bundle = Bundle(for: NMLocalizedPhoneCountryView.self)
        guard let jsonPath = bundle.path(forResource: "NMLocalizedPhoneCountryView.bundle/Data/CountryCodes", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {

                return countries
        }
        
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization
            .ReadingOptions.allowFragments)) as? Array<Any> {
            countries = getCountriesFrom(jsonObjects)
        }
        
        return countries
    }
    
    private func getCountriesFrom(_ jsonArray : Array<Any>) -> [NMCountry] {
        var countries = [NMCountry]()
        for jsonObject in jsonArray {
            
            guard let countryObj = jsonObject as? Dictionary<String, Any> else {
                continue
            }
            guard let name = countryObj["name"] as? String,
                let code = countryObj["code"] as? String,
                let phoneCode = countryObj["dial_code"] as? String else {
                    continue
            }
            var nameOtherLocale = name
            if localeSetup.isOtherLocale() {
                let key = "name_\(localeSetup.baseLocale)"
                if let nameOther = countryObj[key] as? String, nameOther.count > 0 {
                    nameOtherLocale = nameOther
                }
            }
            var postalCode = ""
            if let postCode = countryObj["postal_code"] as? String {
                postalCode = postCode
            }
            let states = countryObj["states"] as? [NSDictionary]
            let carrierCodes = countryObj["carrier_codes"] as? [String]
            let country = NMCountry(name: name, nameOtherLocale: nameOtherLocale, countryCode: code, phoneCode: phoneCode, postalCode: postalCode, carrierCodes: carrierCodes, states: states, localeSetup: localeSetup)
            countries.append(country)
        }

        return countries
    }
    
    private func getFontForSymbolicTrait(trait: FontTrait) -> UIFont {
        var newFont = normalFont
        switch trait {
        case .italic:
            newFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: normalFont.pointSize)
        case .bold:
            newFont = UIFont(descriptor: normalFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: normalFont.pointSize)
        default:
            newFont = normalFont
        }

        return newFont
    }
}

//MARK: Helper methods
extension NMLocalizedPhoneCountryView {
    
    public func setCountryByPhoneCode(_ phoneCode: String) {
        if let country = getCountries().first(where: { $0.phoneCode == phoneCode }) {
            selectedCountry = country
            delegate?.localizedPhoneCountryView(self, didSelectCountry: country)
        }
    }
    
    public func setCountryByCode(_ code: String) {
        if let country = getCountries().first(where: { $0.code == code }) {
            selectedCountry = country
            delegate?.localizedPhoneCountryView(self, didSelectCountry: country)
        }
    }
    
    public func getCountryByPhoneCode(_ phoneCode: String) -> NMCountry? {

        return getCountries().first(where: { $0.phoneCode == phoneCode })
    }
    
    public func getCountryByCode(_ code: String) -> NMCountry? {

        return getCountries().first(where: { $0.code == code })
    }
}


// MARK:- An internal implementation of the NMLocalizedPhoneCountryViewDelegate.
// Sets internal properties before calling external delegate.

extension NMLocalizedPhoneCountryView {
    func didSelectCountry(_ country: NMCountry) {
        selectedCountry = country
        delegate?.localizedPhoneCountryView(self, didSelectCountry: country)
    }
}

// MARK:- An internal implementation of the NMLocalizedPhoneCountryViewDataSource.
// Returns default options where necessary if the data source is not set.

extension NMLocalizedPhoneCountryView: NMLocalizedPhoneCountryViewDataSource {
    var preferredCountries: [NMCountry] {

        return dataSource?.preferredCountries(in: self) ?? preferredCountries(in: self)
    }
    
    var preferredCountriesSectionTitle: String? {

        return dataSource?.sectionTitleForPreferredCountries(in: self)
    }
    
    var showOnlyPreferredSection: Bool {

        return dataSource?.showOnlyPreferredSection(in: self) ?? showOnlyPreferredSection(in: self)
    }
    
    var navigationTitle: String? {

        return dataSource?.navigationTitle(in: self)
    }
    
    var searchBarPlaceHolderTitle: String? {
        guard let placeHolderTitle = dataSource?.searchBarPlaceholderTitle(in: self) else {
            
            return "Search"
        }
        
        return placeHolderTitle
    }
    
    var searchBarCancelButtonTitle: String? {
        guard let cancelButtonTitle = dataSource?.searchBarCancelButtonTitle(in: self) else {
            
            return "Cancel"
        }
        
        return cancelButtonTitle
    }
    
    var closeButtonNavigationItem: UIBarButtonItem {
        guard let button = dataSource?.closeButtonNavigationItem(in: self) else {

            return UIBarButtonItem(title: "Close", style: .done, target: nil, action: nil)
        }

        return button
    }
    
    var searchBarPosition: SearchBarPosition {

        return dataSource?.searchBarPosition(in: self) ?? searchBarPosition(in: self)
    }
    
    var showPhoneCodeInList: Bool {

        return dataSource?.showPhoneCodeInList(in: self) ?? showPhoneCodeInList(in: self)
    }
    
}
