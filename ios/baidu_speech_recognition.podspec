#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'baidu_speech_recognition'
  s.version          = '0.0.1'
  s.summary          = 'Baidu Speech Recognition Flutter plugin.'
  s.description      = <<-DESC
Baidu Speech Recognition Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/soragui/flutter_baidu_speech_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'soragui' => 'ziwo520@msn.cn' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

