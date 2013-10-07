#
# Be sure to run `pod spec lint DoubleNode.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "DoubleNode"
  s.version      = "0.0.12"
  s.summary      = "A collection of utility functions."
  # s.description  = <<-DESC
  #                   An optional longer description of DoubleNode
  #
  #                   * Markdown format.
  #                   * Don't worry about the indent, we strip it!
  #                  DESC
  s.homepage     = "https://github.com/ehlersd/DoubleNode"
  # s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"

  # Specify the license type. CocoaPods detects automatically the license file if it is named
  # 'LICENCE*.*' or 'LICENSE*.*', however if the name is different, specify it.
  s.license      = 'LICENSE'
  # s.license      = { :type => 'MIT (example)', :file => 'FILE_LICENSE' }

  # Specify the authors of the library, with email addresses. You can often find
  # the email addresses of the authors by using the SCM log. E.g. $ git log
  #
  s.author       = { "Darren Ehlers" => "me@darrenehlers.com" }
  # s.authors      = { "Darren Ehlers" => "me@darrenehlers.com", "other author" => "and email address" }
  #
  # If absolutely no email addresses are available, then you can use this form instead.
  #
  # s.author       = 'Darren Ehlers', 'other author'

  # Specify the location from where the source should be retrieved.
  #
  s.source       = { :git => "https://github.com/ehlersd/DoubleNode.git", :tag => s.version.to_s }


  # If this Pod runs only on iOS or OS X, then specify the platform and
  # the deployment target.
  #
  s.platform     = :ios, '5.1'

  # ――― MULTI-PLATFORM VALUES ――――――――――――――――――――――――――――――――――――――――――――――――― #

  # If this Pod runs on both platforms, then specify the deployment
  # targets.
  #
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  s.source_files = 'Classes/*.{h,m}','Categories/*.{h,m}'
  # s.exclude_files = 'Classes/Exclude'

  # A list of file patterns which select the header files that should be
  # made available to the application. If the pattern is a directory then the
  # path will automatically have '*.h' appended.
  #
  # If you do not explicitly set the list of public header files,
  # all headers of source_files will be made public.
  #
  # s.public_header_files = 'Classes/**/*.h'

  # A list of resources included with the Pod. These are copied into the
  # target bundle with a build phase script.
  #
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # A list of paths to preserve after installing the Pod.
  # CocoaPods cleans by default any file that is not used.
  # Please don't include documentation, example, and test files.
  #
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # Specify a list of frameworks that the application needs to link
  # against for this Pod to work.
  #
  s.frameworks  = 'AVFoundation','CoreTelephony','CoreData','AudioToolbox'

  # Specify a list of libraries that the application needs to link
  # against for this Pod to work.
  #
  # s.library   = 'iconv'
  # s.libraries = 'iconv', 'xml2'

  # If this Pod uses ARC, specify it like so.
  #
  s.requires_arc = true

  # If you need to specify any other build settings, add them to the
  # xcconfig hash.
  #
  # s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

  # Finally, specify any Pods that this Pod depends on.
  #
  # s.dependency 'JSONKit', '~> 1.4'
  s.dependency 'NSLogger'
  
  # This creates a new Pod::Specification instance, which has the the following attributes:
  # * part_of:  'RestKit', '0.9.3'
  # * name:    'RestKit/Network'
  # Other attributes are delegated to the `part_of' spec, so the version, summary etc will by default be the same
  s.subspec 'ColorUtils' do |cu|
    cu.description = 'A useful category extending UIColor with additional functionality including direct access to color components and creating colors from hex values.'
    cu.source_files = 'ColorUtils/ColorUtils/*.{h,m}'
  end
end
