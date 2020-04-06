ENV['COCOAPODS_DISABLE_STATS'] = 'true'

platform :ios, '11.0'
use_frameworks!
inhibit_all_warnings!

target 'Blockchain' do
  pod 'SwiftLint', '0.30.1'
  target 'BlockchainTests' do
    inherit! :search_paths
  end
end

def lib_wally
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', commit: 'fc38082243575a7b5c626272790cb764062a836b', submodules: true
end

target 'BitcoinKit' do
  lib_wally
  target 'BitcoinKitTests' do
    inherit! :search_paths
    lib_wally
  end
end

target 'HDWalletKit' do
  lib_wally
  target 'HDWalletKitTests' do
    inherit! :search_paths
    lib_wally
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
