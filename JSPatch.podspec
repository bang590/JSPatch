Pod::Spec.new do |s|
  s.name         = "JSPatch"
  s.version      = "1.1"
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

  s.ios.deployment_target = '6.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'
  s.source       = { :git => "https://github.com/bang590/JSPatch.git", :tag => s.version }

  s.frameworks   = "Foundation"
  s.weak_framework = "JavaScriptCore"
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.ios.source_files = "JSPatch/*.{h,m}"
    ss.tvos.source_files = "JSPatch/*.{h,m}"
    ss.osx.source_files = "JSPatch/*.{h,m}"
    ss.public_header_files = "JSPatch/*.h"
    ss.resources    = "JSPatch/*.js"
  end

  s.subspec 'Extensions' do |ss|
    ss.ios.source_files = "Extensions/**/*.*" 
    ss.tvos.source_files = "Extensions/**/*.*"
    ss.ios.public_header_files = "Extensions/**/*.h"
    ss.tvos.public_header_files = "Extensions/**/*.h"
    ss.dependency 'JSPatch/Core'
  end

  s.subspec 'Loader' do |ss|
    ss.ios.source_files = "Loader/**/*.{h,m,c}"
    ss.tvos.source_files = "Loader/**/*.{h,m,c}"
    ss.ios.public_header_files = "Loader/*.h"
    ss.tvos.public_header_files = "Loader/*.h"
    ss.dependency 'JSPatch/Core'
    ss.library = 'z'
  end
end
