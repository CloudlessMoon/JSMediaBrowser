
Pod::Spec.new do |s|
  s.name         = "JSMediaBrowser"
  s.version      = "2.0.6"
  s.summary      = "图片、视频浏览器"
  s.homepage     = "https://github.com/CloudlessMoon/JSMediaBrowser"
  s.author       = "CloudlessMoon"
  s.platform     = :ios, "13.0"
  s.swift_versions = ["5.1"]
  s.requires_arc = true
  s.source       = { :git => "https://github.com/CloudlessMoon/JSMediaBrowser.git", :tag => "#{s.version}" }
  s.frameworks   = "UIKit"
  s.license      = "MIT"
  
  s.dependency "JSCoreKit", "~> 1.0"
  
  s.default_subspec = "Core"
  s.subspec "Core" do |ss|
    ss.source_files = "Sources/Core/*.{swift,h,m}"
  end

  s.subspec "MediaView" do |ss|
    ss.source_files = "Sources/MediaView/Basis/*.{swift,h,m}"
  end

  s.subspec "MediaZoomView" do |ss|
    ss.source_files = "Sources/MediaView/ZoomView/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaView"
  end

  s.subspec "Business" do |ss|
    ss.source_files = "Sources/Business/**/*.{swift,h,m}"
    ss.exclude_files = [
      "Sources/Business/Photo/PHLivePhoto/*.{swift,h,m}", 
      "Sources/Business/Photo/SDWebImage/*.{swift,h,m}"
    ]
    ss.dependency "JSMediaBrowser/Core"
    ss.dependency "JSMediaBrowser/MediaZoomView"
  end

  s.subspec "BusinessForPHLivePhoto" do |ss|
    ss.source_files = "Sources/Business/Photo/PHLivePhoto/*.{swift,h,m}"
    ss.frameworks   = "PhotosUI"
    ss.dependency "JSMediaBrowser/Business"
  end

  s.subspec "BusinessForSDWebImage" do |ss|
    ss.source_files = "Sources/Business/Photo/SDWebImage/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/Business"
    ss.dependency "SDWebImage", "~> 5.0"
  end
end
