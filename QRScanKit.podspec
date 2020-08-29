
Pod::Spec.new do |s|
  s.name             = 'QRScanKit'
  s.version          = '1.1.1'
  s.summary          = 'QRScanKit.'
  s.homepage         = 'https://github.com/huawt/QRScanKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'huawt' => 'ghost263sky@163.com' }
  s.source           = { :git => 'https://github.com/huawt/QRScanKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'QRScanKit/Classes/**/*'

  s.resource = 'QRScanKit/ScanResource.bundle'

  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreImage', 'CoreGraphics'
  s.dependency 'ZXingObjCFork', '~> 3.6.5'
  s.dependency 'Masonry'
  s.dependency 'TLToastHUD'
  s.dependency 'LRTools'

end
