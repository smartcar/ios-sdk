Pod::Spec.new do |s|
  s.name             = 'SmartcarAuth'
  s.version          = '5.4.1'
  s.summary          = 'Smartcar Authentication SDK for iOS written in Swift 5.'

  s.description      = <<-DESC
    Smartcar Authentication SDK for iOS written in Swift 5.
        - Facilitates the flow to redirect to Smartcar and retrieve an authorization code
                       DESC

  s.homepage         = 'https://github.com/smartcar/ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Smartcar Inc.' => 'hello@smartcar.com' }
  s.source           = { :git => 'https://github.com/smartcar/ios-sdk.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '10.0'
  s.source_files = 'SmartcarAuth/**/*.swift'
  s.swift_version = '5.0'

end
