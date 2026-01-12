#
# Be sure to run `pod lib lint FYContactUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FYContactUtil'
  s.version          = '0.1.1'
  s.summary          = 'A short description of FYContactUtil.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yanwenbo78201/FYContactUtil'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Computer' => 'yanwenbo78201@gmail.com' }
  s.source           = { :git => 'https://github.com/yanwenbo78201/FYContactUtil.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'

  s.source_files = 'FYContactUtil/Classes/**/*'
  
  # 公开头文件，使 Swift 可以访问
  s.public_header_files = 'FYContactUtil/Classes/**/*.h'
  
  # 必需的框架
  s.frameworks = 'Foundation', 'Contacts', 'AddressBook'
  
  # s.resource_bundles = {
  #   'FYContactUtil' => ['FYContactUtil/Assets/*.png']
  # }
  
  # s.dependency 'AFNetworking', '~> 2.3'
end
