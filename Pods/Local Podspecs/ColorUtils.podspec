Pod::Spec.new do |s|
  s.name         = "ColorUtils"
  s.version      = "1.0.3"
  s.summary      = "A useful category extending UIColor with additional functionality including direct access to color components and creating colors from hex values."
  s.homepage     = "http://charcoaldesign.co.uk/source/cocoa#colorutils"
  s.license      = 'LICENSE'
  s.author       = { "Nick Lockwood" => "support@charcoaldesign.co.uk" }
  s.source       = { :git => "git@github.com:ehlersd/ColorUtils.git", :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.source_files = 'ColorUtils/*.{h,m}'
  s.requires_arc = true
end
