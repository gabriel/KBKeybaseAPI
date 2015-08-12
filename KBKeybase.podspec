Pod::Spec.new do |s|

  s.name         = "KBKeybase"
  s.version      = "0.1.15"
  s.summary      = "Keybase.io API client for iOS/OSX."
  s.homepage     = "https://github.com/gabriel/KBKeybase"
  s.license      = { :type => "MIT" }
  s.author       = { "Gabriel Handford" => "gabrielh@gmail.com" }
  s.source       = { :git => "https://github.com/gabriel/KBKeybase.git", :tag => s.version.to_s }

  s.ios.platform = :ios, "7.0"
  s.ios.deployment_target = "7.0"

  s.osx.platform = :osx, "10.8"
  s.osx.deployment_target = "10.8"

  s.requires_arc = true

  s.source_files = "KBKeybase/**/*.{h,m}"
  s.dependency "TSTripleSec"
  s.dependency "AFNetworking"
  s.dependency "Mantle"
  s.dependency "ObjectiveSugar"
  s.dependency "GHKit"
  s.dependency "NAChloride"
  s.dependency "NACrypto"

  s.subspec "Core" do |a|
    a.source_files = "KBKeybase/Core/**/*.{h,m}"
    a.dependency "GHKit"
    a.dependency "Mantle"
    a.dependency "ObjectiveSugar"
    a.dependency "TSTripleSec"
    a.dependency "NAChloride"
    a.dependency "NACrypto"
  end

end
