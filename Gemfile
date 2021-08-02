source "https://rubygems.org"

gem "bundler"
gem "fastlane"
gem "dotenv"
gem "danger"
gem "danger-swiftlint"
gem 'danger-swiftformat'
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
