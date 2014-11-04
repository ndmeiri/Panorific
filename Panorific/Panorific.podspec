Pod::Spec.new do |s|
  s.name         = "Panorific"
  s.version      = "0.0.1"
  s.summary      = "An immersive, intuitive, motion-based way to explore high quality panoramas and photos on an iOS device. Panorific is implemented in Swift."
  s.homepage     = "https://github.com/ndmeiri/Panorific"
  s.license      = "MIT"
  s.author       = "Naji Dmeiri"
  s.platform     = :ios, "8.0"
  s.source       = {:git => "https://github.com/ndmeiri/Panorific.git", :tag => '0.0.1'}
  s.source_files = "Panorific"
  s.frameworks   = "CoreMotion", "CoreGraphics", "QuartzCore"
  s.requires_arc = true
end