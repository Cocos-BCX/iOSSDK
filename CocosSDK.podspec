Pod::Spec.new do |s|
    s.name             = 'CocosSDK'
    s.version          = '0.1.0'
    s.summary          = 'CocosSDK.'
#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC
    s.homepage         = 'http://cocosbcx.io/'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'SYLing' => '534585931@qq.com' }
    s.source           = { :git => 'https://github.com/SYLing/CocosSDK.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '8.0'
    s.source_files = 'CocosSDK/Classes/**/*'

# s.resource_bundles = {
#   'CocosSDK' => ['CocosSDK/Assets/*.png']
# }

    s.public_header_files = 'Pod/Classes/**/*.h'
#  s.frameworks = 'UIKit'
    s.dependency 'SocketRocket'
    s.dependency 'AFNetworking'
    s.dependency 'Secp256k1_A' ,'0.1.2'
    s.dependency 'FMDB'
end


#s.version：版本号
#s.ios.deployment_target:支持的pod最低版本
#s.summary: 简介
#s.homepage:项目主页地址
#s.license:开源协议(创建github库的时候选择的)
#s.author:作者信息(这里随便谢谢也可以通过)
#s.social_media_url:社交网址
#s.source:项目的地址
#s.source_files:需要包含的源文件
#s.resource:资源文件,单个
#s.resources: 资源文件(含bundle)
#s.requires_arc: 是否支持ARC
#s.dependency：依赖库，不能依赖未发布的库.如AFNetWorking
#s.vendored_frameworks:包含的framework,也就是我们自己制作的pod
#s.description:描述,字数要比#s.summary长
#s.screenshots:截图
#s.exclude_files:隐藏的文件
#s.public_header_files:公开的头文件
#s.framework:所需的framework,单个
#s.frameworks:所需的framework,多个用逗号隔开
