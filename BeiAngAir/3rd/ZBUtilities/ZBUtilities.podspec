Pod::Spec.new do |s|
  s.name         = "ZBUtilities"
  s.version      = "0.0.4"
  s.summary      = "ZBUtilities for Zoombin."
  s.homepage     = "https://github.com/qq30135878/ZBUtilities"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bin Zhang" => "30135878@qq.com" }
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/qq30135878/ZBUtilities.git", :tag => "0.0.4" }
  s.source_files  = "*.{h,m}"
  s.public_header_files = "*.h"
  s.requires_arc = true
  s.dependency 'MBProgressHUD', '~> 0.8'
end
