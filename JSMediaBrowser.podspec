
Pod::Spec.new do |s|
  s.name         = "JSMediaBrowser"
  s.version      = "2.0.0"
  s.summary      = "图片、视频浏览器"
  s.homepage     = "https://github.com/CloudlessMoon/JSMediaBrowser"
  s.author       = { "CloudlessMoon" => "593908937@qq.com" }
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
    ss.dependency "JSMediaBrowser/Core"
  end

  s.subspec "MediaPhoto" do |ss|
    ss.source_files = "Sources/MediaView/Photo/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaView"
  end

  s.subspec "MediaPhotoForPHLivePhoto" do |ss|
    ss.source_files = "Sources/MediaView/Photo/PHLivePhoto/*.{swift,h,m}"
    ss.frameworks   = "PhotosUI"
    ss.dependency "JSMediaBrowser/MediaPhoto"
  end

  s.subspec "MediaPhotoForSDWebImage" do |ss|
    ss.source_files = "Sources/MediaView/Photo/SDWebImage/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaPhoto"
    ss.dependency "SDWebImage", "~> 5.0"
  end

  # 后续支持Kingfisher
  # s.subspec "MediaPhotoForKingfisher" do |ss|
  #   ss.source_files = "Sources/MediaView/Photo/Kingfisher/*.{swift,h,m}"
  #   ss.dependency "JSMediaBrowser/MediaPhoto"
  #   ss.dependency "Kingfisher", "~> 8.0"
  # end

  # 后续支持Video
  # s.subspec "MediaVideo" do |ss|
  #   ss.source_files = "Sources/MediaView/Video/*.{swift,h,m}"
  #   ss.frameworks   = "AVKit"
  #   ss.dependency "JSMediaBrowser/MediaView"
  # end

  s.subspec "Business" do |ss|
    ss.source_files = "Sources/Business/**/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/Core"
    ss.dependency "JSMediaBrowser/MediaPhoto"
  end

end
