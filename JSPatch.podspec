Pod::Spec.new do |s|
  s.name         = "JSPatch"
  s.version      = "0.1.4"
  s.summary      = "JSPatch bridge Objective-C and JavaScript. You can call any"  \
                   " Objective-C class and method in JavaScript by just" \
                   " including a small engine."

  s.description  = <<-DESC
                   JSPatch bridges Objective-C and JavaScript using the
                   Objective-C runtime. You can call any Objective-C class and
                   method in JavaScript by just including a small engine.
                   That makes the APP obtaining the power of script language:
                   add modules or replacing Objective-C codes to fix bugs dynamically.
                   DESC

  s.homepage     = "https://github.com/bang590/JSPatch"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "bang" => "bang590@gmail.com" }
  s.social_media_url   = "http://twitter.com/bang590"

  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/bang590/JSPatch.git", :tag => s.version }

  s.resources    = "JSPatch/*.js"
  s.frameworks   = "Foundation"
  s.weak_framework = "JavaScriptCore"
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = "JSPatch/*.{h,m}"
    ss.public_header_files = "JSPatch/*.h"
    ss.resources    = "JSPatch/*.js"
  end

  s.subspec 'Extensions' do |ss|
    ss.source_files = "Extensions/**/*.{h,m}"
    ss.public_header_files = "Extensions/**/*.h"
	ss.dependency 'JSPatch/Core'
  end
end
