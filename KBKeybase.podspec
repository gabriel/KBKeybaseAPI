Pod::Spec.new do |s|

  s.name         = "KBKeybase"
  s.version      = "0.1.1"
  s.summary      = "Keybase.io API client for iOS/OSX."
  s.homepage     = "https://github.com/gabriel/KBKeybase"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/KBKeybase", :tag => "0.1.1" }
  s.platform = :ios, "7.0"
  s.dependency 'TSTripleSec'
  s.dependency 'KBCrypto'
  s.dependency 'AFNetworking'
  s.dependency 'Mantle'
  s.dependency 'SSKeychain'
  s.dependency 'ObjectiveSugar'
  s.dependency 'GHKit'
  s.source_files = 'KBKeybase/**/*.{c,h,m}'
  s.requires_arc = true

end
