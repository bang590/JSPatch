Pod::Spec.new do |s|
  s.name         = "JSPatch"
  s.version      = "0.0.3"
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

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/bang590/JSPatch.git", :tag => s.version }

  s.source_files = "JSPatch/*.{h,m}"
  s.public_header_files = "JSPatch/*.h"

  s.resources    = "JSPatch/*.js"
  s.frameworks   = "JavaScriptCore", "Foundation"

end
