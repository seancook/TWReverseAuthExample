Pod::Spec.new do |s|
  s.name             = "TWReverseAuth"
  s.version          = "0.1.0"
  s.summary          = "Reverse auth for the Twitter API, if you need the access token and secret."
  s.description      = <<-DESC
All credit goes to Sean Cook, who created the original: https://github.com/seancook/TWReverseAuthExample

I just made it usable from Cocoapods.
                       DESC

  s.author           = { "Caesar Wirth" => "wirth_caesar@cyberagent.co.jp" }
  s.license          = 'MIT'
  s.source           = { :git => "https://github.com/cjwirth/TWReverseAuthExample", :tag => s.version.to_s }
  s.homepage         = 'https://github.com/cjwirth/TWReverseAuthExample'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Classes'

  s.dependency 'OAuthCore'

  s.frameworks = 'Accounts', 'Social'
end

