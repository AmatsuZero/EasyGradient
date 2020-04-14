#
# Be sure to run `pod lib lint EasyGradient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyGradient'
  s.version          = '0.1.0'
  s.summary          = '轻松设置渐变色'
  s.description      = <<-DESC
  不需要创建子类，不需要 CAGradientLayer，一样设置渐变色
                       DESC

  s.homepage         = 'https://github.com/AmatsuZero/EasyGradient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AmatsuZero' => 'jiangzhenhua@baidu.com' }
  s.source           = { :git => 'https://github.com/AmatsuZero/EasyGradient.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'EasyGradient/Classes/**/*'
  s.frameworks = 'UIKit'
end
