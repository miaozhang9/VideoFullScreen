Pod::Spec.new do |spec|
  spec.ios.deployment_target = '8.0'
  spec.name         = 'MovieousPlayer'
  spec.version      = `sh utils.sh get-version`
  spec.homepage     = 'https://bitbucket.org/movieous-team/movieousplayer-cocoa-release'
  spec.authors      = { 'movieous' => 'cloudop@movieous.video' }
  spec.summary      = 'Movieous Player for iOS.'
  spec.source       = { :git => 'https://movieous-team@bitbucket.org/movieous-team/movieousplayer-cocoa-release.git', :tag => "v#{spec.version}" }
  spec.static_framework = true
  spec.vendored_frameworks = 'MovieousPlayer.framework'
  spec.libraries    = 'c++', 'z'
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 x86_64' }
end