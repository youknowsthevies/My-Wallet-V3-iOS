ENV['COCOAPODS_DISABLE_STATS'] = 'true'

platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'Blockchain' do
  pod 'Charts', '~> 3.4.0'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  pod 'PhoneNumberKit', '~> 2.1'
  pod 'SwiftLint', '0.30.1'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '897f8acd327bb900aa97a6b92e602c6076e978bc'
  pod 'zxcvbn-ios', '1.0.4'

  target 'BlockchainTests' do
    inherit! :search_paths
  end
end

target 'PlatformUIKit' do
  pod 'zxcvbn-ios', '1.0.4'
  pod 'Charts', '~> 3.4.0'
  pod 'PhoneNumberKit', '~> 2.1'

  target 'PlatformUIKitTests' do
    inherit! :search_paths
  end
end

target 'StellarKit' do
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '897f8acd327bb900aa97a6b92e602c6076e978bc'

  target 'StellarKitTests' do
    inherit! :search_paths
  end
end

target 'BitcoinKit' do
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', commit: 'fc38082243575a7b5c626272790cb764062a836b', submodules: true
  
  target 'BitcoinKitTests' do
    inherit! :search_paths
  end
end

target 'HDWalletKit' do
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', commit: 'fc38082243575a7b5c626272790cb764062a836b', submodules: true
  
  target 'HDWalletKitTests' do
    inherit! :search_paths
  end
end

# Post Installation:
# - Disable code signing for pods.
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
