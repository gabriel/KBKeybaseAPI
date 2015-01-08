Pod::Spec.new do |s|

  s.name         = "KBKeybase"
  s.version      = "0.1.1"
  s.summary      = "Keybase.io API client for iOS/OSX."
  s.homepage     = "https://github.com/gabriel/KBKeybase"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/KBKeybase", :tag => s.version.to_s }

  s.ios.platform = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.osx.platform = :osx, "10.8"
  s.osx.deployment_target = "10.8"

  s.requires_arc = true

  s.default_subspec = 'Crypto'

  s.subspec 'Client' do |a|
    a.source_files = 'KBKeybase/Client/**/*.{c,h,m}'
    a.dependency 'TSTripleSec'
    a.dependency 'GHBignum'
    a.dependency 'AFNetworking'
    a.dependency 'Mantle'
    a.dependency 'ObjectiveSugar'
    a.dependency 'GHKit'
  end

  s.subspec 'Models' do |a|
    a.source_files = 'KBKeybase/Models/**/*.{c,h,m}'
    a.dependency 'Mantle'
    a.dependency 'TSTripleSec'
  end

  s.subspec 'Crypto' do |a|
    a.source_files = 'KBKeybase/Crypto/**/*.{h,m}'
    a.dependency 'TSTripleSec'
    a.dependency 'GHKit'
    a.dependency 'ObjectiveSugar'
  end

end
