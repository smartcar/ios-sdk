Pod::Spec.new do |s|
  s.name             = 'SmartCarOAuthSDK'
  s.version          = '0.1.0'
  s.summary          = 'SmartCar Authentication SDK for iOS written in Swift 3.'
 
  s.description      = <<-DESC
SmartCar Authentication SDK for iOS written in Swift 3.
        - Allows the ability to generate buttons to login with each manufacturer which launches the OAuth flow
        - Allows the ability to use dropdown/custom buttons to trigger OAuth flow
        - Facilitates the flow with a SFSafariViewController to redirect to SmartCar and retrieve an access code and an access token
                       DESC
 
  s.homepage         = 'https://github.com/smartcar/ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Smartcar Inc.' => 'jeremyziyuzhang@gmail.com' }
  s.source           = { :git => 'https://github.com/smartcar/ios-sdk.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'SmartCarOAuthSDK/*.swift'
 
end