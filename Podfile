# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!

target 'SAT Prep' do
  # Pods for SAT Prep
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'iosMath'
  pod 'UICountingLabel'
  pod 'lottie-ios'
  pod 'FirebaseUI'
  pod 'FLAnimatedImage'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings.delete('CODE_SIGNING_ALLOWED')
    config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end

