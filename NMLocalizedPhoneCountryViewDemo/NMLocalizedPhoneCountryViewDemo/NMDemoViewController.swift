//
//  DemoViewController.swift
//  NMLocalizedPhoneCountryViewDemo
//
//  Updated by Mobile Team of Namshi on 03/10/2018.
//  Originally created as CountryPickerViewDemo by Kizito Nwose on 18/09/2017.
//  Copyright © 2018 NAMSHI. All rights reserved.
//


import UIKit
import NMLocalizedPhoneCountryView

class DemoViewController: UITableViewController {

    @IBOutlet weak var searchBarPosition: UISegmentedControl!
    @IBOutlet weak var showPhoneCodeInView: UISwitch!
    @IBOutlet weak var showCountryCodeInView: UISwitch!
    @IBOutlet weak var localizeCountryCodeInView: UISwitch!
    @IBOutlet weak var showPreferredCountries: UISwitch!
    @IBOutlet weak var showOnlyPreferredCountries: UISwitch!
    @IBOutlet weak var showPhoneCodeInList: UISwitch!
    @IBOutlet weak var cpvMain: NMLocalizedPhoneCountryView!
    
    @IBOutlet weak var phoneNumberField: UITextField!
    weak var cpvTextField: NMLocalizedPhoneCountryView!
    @IBOutlet weak var cpvIndependent: NMLocalizedPhoneCountryView!
    let cpvInternal = NMLocalizedPhoneCountryView()
    
    @IBOutlet weak var presentationStyle: UISegmentedControl!
    @IBOutlet weak var selectCountryButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let cp = NMLocalizedPhoneCountryView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        phoneNumberField.leftView = cp
        phoneNumberField.leftViewMode = .always
        self.cpvTextField = cp

        cpvMain.tag = 1
        cpvTextField.tag = 2
        cpvIndependent.tag = 3
        
        getCountriesFromAPI()
        
        [cpvMain, cpvTextField, cpvIndependent, cpvInternal].forEach {
            $0?.dataSource = self
            $0?.excludedCountriesList = ["AE", "QA", "SA", "OM", "KW", "BH", "GI", "IM", "ME", "RE", "TG"]
        }
        
        cpvInternal.delegate = self
        cpvMain.countryDetailsLabel.font = UIFont.systemFont(ofSize: 20)
        
        [showPhoneCodeInView, showCountryCodeInView, localizeCountryCodeInView,
         showPreferredCountries,  showOnlyPreferredCountries].forEach {
            $0.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        }
        
        selectCountryButton.addTarget(self, action: #selector(selectCountryAction(_:)), for: .touchUpInside)
        
        phoneNumberField.showDoneButtonOnKeyboard()
    }
    
    private func getCountriesFromAPI() {
        let wrongAPI = "https://api.myjson.com/bins/o4bto" // Wrong format of json
        let correctAPI = "https://api.myjson.com/bins/7e1q4" // Correct format of json
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: wrongAPI)!
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("API Error: \(error!.localizedDescription)")
            } else {
                print("API Response: \(String(describing: data))") // JSON Serialization
                if let dataResponse = data {
                    if let jsonObjects = (try? JSONSerialization.jsonObject(with: dataResponse, options: JSONSerialization
                        .ReadingOptions.allowFragments)) as? Array<Any> {
                        print("API jsonObjects: \(String(describing: jsonObjects))") // JSON Serialization
                        self.cpvIndependent.jsonCountries = jsonObjects
                    }
                }
            }
        }
        task.resume()
    }
    
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        switch sender {
        case showCountryCodeInView:
            cpvMain.showCountryCodeInView = sender.isOn
        case showPhoneCodeInView:
            cpvMain.showPhoneCodeInView = sender.isOn
        case localizeCountryCodeInView:
            cpvMain.localeSetup = NMLocaleSetup(baseLocale: sender.isOn ? "ar" : "Base", isRTL: sender.isOn)
        case showPreferredCountries:
            if !sender.isOn && showOnlyPreferredCountries.isOn {
                showOnlyPreferredCountries.setOn(false, animated: true)
            }
        case showOnlyPreferredCountries:
            if sender.isOn && !showPreferredCountries.isOn {
                let title = "Missing requirement"
                let message = "You must select the \"Show preferred countries section\" option."
                showAlert(title: title, message: message)
                sender.isOn = false
            }
        default: break
        }
    }
    
    @objc func selectCountryAction(_ sender: Any) {
        switch presentationStyle.selectedSegmentIndex {
        case 0:
            if let nav = navigationController {
                cpvInternal.showCountriesList(from: nav)
            }
        case 1: cpvInternal.showCountriesList(from: self)
        default: break
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

extension DemoViewController: NMLocalizedPhoneCountryViewDelegate {
    func localizedPhoneCountryView(_ localizedPhoneCountryView: NMLocalizedPhoneCountryView, didSelectCountry country: NMCountry) {
        // Only countryPickerInternal has it's delegate set
        let title = "Selected Country"
        let name = country.getLocalizedName(locale: localizedPhoneCountryView.localeSetup)
        let message = "Name: \(name) \nCode: \(country.code) \nPhone: \(country.phoneCode) \nand States: \(country.states.count)"
        showAlert(title: title, message: message)
    }
}

extension DemoViewController: NMLocalizedPhoneCountryViewDataSource {
    func preferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> [NMCountry] {
        if localizedPhoneCountryView.tag == cpvMain.tag && showPreferredCountries.isOn {
            var countries = [NMCountry]()
            ["NG", "US", "GB"].forEach { code in
                if let country = localizedPhoneCountryView.getCountryByCode(code) {
                    countries.append(country)
                }
            }
            return countries
        }
        return []
    }
    
    func sectionTitleForPreferredCountries(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {
        if localizedPhoneCountryView.tag == cpvMain.tag && showPreferredCountries.isOn {
            return "Preferred title"
        }
        return nil
    }
    
    func showOnlyPreferredSection(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool {
        if localizedPhoneCountryView.tag == cpvMain.tag {
            return showOnlyPreferredCountries.isOn
        }
        return false
    }
    
    func navigationTitle(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> String? {
        return "Select any Country"
    }
        
    func searchBarPosition(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> SearchBarPosition {
        if localizedPhoneCountryView.tag == cpvMain.tag {
            switch searchBarPosition.selectedSegmentIndex {
            case 0: return .tableViewHeader
            case 1: return .navigationBar
            default: return .hidden
            }
        }
        return .tableViewHeader
    }
    
    func showPhoneCodeInList(in localizedPhoneCountryView: NMLocalizedPhoneCountryView) -> Bool {
        if localizedPhoneCountryView.tag == cpvMain.tag {
            return showPhoneCodeInList.isOn
        }
        return false
    }
}


extension UITextField {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}
