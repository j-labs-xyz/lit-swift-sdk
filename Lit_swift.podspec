#
#  Be sure to run `pod spec lint ecdsa_swift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                = "Lit_swift"
  s.version             = "0.0.1"
  s.summary             = "swift implementation for lit js sdk."
  s.homepage            = "https://github.com/j-labs-xyz/lit-swift-sdk"
  s.license             = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "leven" => "leven@j-labs.xyz" }
  s.platform            = :ios, "13.0"
  s.swift_version = '5.5'
  s.module_name = 'litSwift'
  s.source              = { :git => "https://github.com/j-labs-xyz/lit-swift-sdk", :tag => s.version }
  s.source_files = 'Lit_swift/**/*{h,swift}'

  s.dependency "PromiseKit"
  s.dependency "TweetNacl"
  s.dependency "Libecdsa_swift"
  s.dependency "web3-jlabs.swift", "~>1.4.2"
	

end
