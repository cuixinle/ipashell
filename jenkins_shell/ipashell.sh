# 工程名
APP_NAME="GJOfficeBuild"  #替换成你的工程名

#---------------进入项目工程根目录----------------------------
cd $HOME/.jenkins/workspace/${JOB_NAME}/${APP_NAME}
#---------------auto change versionNumber------------------
#/usr/bin/xcrun agvtool next-marketing-version -all
#---------------auto change buildNumber--------------------
/usr/bin/xcrun agvtool new-version -all $BUILD_NUMBER

# 证书
CODE_SIGN_DISTRIBUTION="iPhone Developer: haiyang cai (SG44DC55TV)"  # 打包所用签名证书
# info.plist路径
project_infoplist_path="$HOME/.jenkins/workspace/${JOB_NAME}/${APP_NAME}/${APP_NAME}/Info.plist"
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#获取日期
#DATE="$(date +%Y%m%d)"
ADHOC_PLIST_PATH="$HOME/.jenkins/workspace/${JOB_NAME}/${APP_NAME}/${APP_NAME}/ExportOptions.plist"
#要上传的ipa文件路径
IPA_PATH="$HOME/.jenkins/workspace/output/${JOB_NAME}/${bundleShortVersion}(${BUILD_ID})"
#创建IPA路径文件夹
mkdir -p $IPA_PATH
#archive文件路径
ARCHIVE_PATH="${IPA_PATH}/${APP_NAME}_${BUILD_ID}.xcarchive"

#进入工程目录
cd $HOME/.jenkins/workspace/${JOB_NAME}/${APP_NAME}
# xcodebuild -list命令可以查看 工程的：Targets、Configurations、Schemes

echo "=================清理工程================="
xcodebuild clean -target "${APP_NAME}" -configuration 'Debug'

echo "=================解锁钥匙串================="
#解决：codesign"seckey api returned: -25308,(null)"
# *** 是一般为电脑登录密码
security unlock-keychain -p "cui" "${HOME}/Library/Keychains/login.keychain"

echo "=================生成xcarchive文件================="
# 在xcode中设置scheme为shared，否则可能出现工程无scheme的错误
# 还可以添加其他参数，不设置的都是默认使用项目Build Settings里面的配置，包括 CODE_SIGN_IDENTITY 和 PROVISIONING_PROFILE
xcodebuild archive -project "${APP_NAME}.xcodeproj" -scheme "${APP_NAME}" -sdk iphoneos -configuration "Debug" -archivePath "${ARCHIVE_PATH}"

echo "=================打包IPA================="
xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportPath "${IPA_PATH}" -exportOptionsPlist "${ADHOC_PLIST_PATH}"