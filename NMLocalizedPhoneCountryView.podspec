Pod::Spec.new do |spec|

  spec.name         = "NMLocalizedPhoneCountryView"
  spec.version      = "1.0.8"
  spec.summary      = "iOS library to add support for selecting a country and its international phone code in your app"
  spec.description      = <<-DESC
  iOS library to add support for selecting a country and its international phone code in your app with localized country names. It can also exclude countries based on countryCodes. Inspiration from https://github.com/kizitonwose/CountryPickerView pod.
  DESC

  spec.homepage     = "https://github.com/namshi/NMLocalizedPhoneCountryView"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Namshi General Trading L.L.C' => 'mobile-dev@namshi.com' }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/namshi/NMLocalizedPhoneCountryView.git", :tag => spec.version }
  spec.social_media_url = 'https://twitter.com/namshidotcom'
  spec.source_files  = "NMLocalizedPhoneCountryView/**/*.{swift,xib}"
  spec.resource_bundles = {
    'NMLocalizedPhoneCountryView' => ['NMLocalizedPhoneCountryView/Assets/NMLocalizedPhoneCountryView.bundle/*']
  }
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }

end
