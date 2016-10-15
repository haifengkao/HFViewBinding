#
# Be sure to run `pod lib lint HFTableCollectionBindingHelper.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HFViewBinding"
  s.version          = "2.3.0"
  s.summary          = "iOS table view and collection view binding to arrays"
  s.description      = <<-DESC
                       helper functions to bind UITableView or UICollectionView instances to arrays

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/haifengkao/HFViewBinding"
  s.license          = 'MIT'
  s.author           = { "Hai Feng Kao" => "haifeng@cocoaspice.in" }
  s.source           = { :git => "https://github.com/haifengkao/HFViewBinding.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'KVOMutableArray'
  s.dependency 'WZProtocolInterceptor'
end
