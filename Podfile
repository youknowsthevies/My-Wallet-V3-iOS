ENV['COCOAPODS_DISABLE_STATS'] = 'true'

platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'Blockchain' do
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Messaging'
  pod 'SwiftLint', '0.30.1'

  target 'BlockchainTests' do
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
