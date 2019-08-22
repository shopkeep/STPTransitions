Pod::Spec.new do |s|

  s.name         = "STPTransitions"
  s.version      = "0.0.5"
  s.summary      = "Unified, easy API for custom iOS view controller transitioning."

  s.homepage     = "http://github.com/stepanhruda/STPTransitions"

  s.license      = 'MIT'

  s.author       = { "Stepan Hruda" => "stepan.hruda@gmail.com" }

  s.platform     = :ios, '9.0'

  s.source       = { :git => "https://github.com/shopkeep/STPTransitions.git", :tag => "0.0.5" }

  s.source_files  = 'Core/**/*.{h,m}'

  s.requires_arc = true

  s.framework  = 'UIKit'

end
