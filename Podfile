# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

target 'Video Player' do
  # Pods for Video Player
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Cache'
  pod 'lottie-ios'
  pod 'Imaginary'
  pod 'SwiftyGif'
  pod 'SJFluidSegmentedControl', '~> 1.0'
  pod 'GoogleSignIn'
  pod 'TouchVisualizer'
  pod 'FacebookLogin'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end

