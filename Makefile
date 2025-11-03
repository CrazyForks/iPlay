PROJECT_ROOT 	= $(PWD)
BUILD_DIR 		= $(PROJECT_ROOT)/build
ANDROID_DIR 	= $(PROJECT_ROOT)/android
IOS_DIR 		= $(PROJECT_ROOT)/ios
APP_NAME 		= iPlay
VERSION			= v1.0
BUILD_ID 		= $(shell git rev-parse --short HEAD)
VERSION_NAME    = "$(VERSION) $(BUILD_ID)"
VERSION_CODE    = $(shell git rev-list --count HEAD)

all: apk aab aws-aab

version:
	@echo $(VERSION_NAME)

apk:
	@echo "📦 apk $(VERSION_NAME)"
	cd $(ANDROID_DIR) && ./gradlew assembleRelease -PversionName=$(VERSION_NAME) -PversionCode=$(VERSION_CODE)
	mkdir -p $(BUILD_DIR)
	cp $(ANDROID_DIR)/app/build/outputs/apk/release/app-arm64-v8a-release.apk $(BUILD_DIR)/$(APP_NAME)-arm64-v8a.apk
	cp $(ANDROID_DIR)/app/build/outputs/apk/release/app-armeabi-v7a-release.apk $(BUILD_DIR)/$(APP_NAME)-armeabi-v7a.apk
	cp $(ANDROID_DIR)/app/build/outputs/apk/release/app-x86_64-release.apk $(BUILD_DIR)/$(APP_NAME)-x86_64.apk

aab:
	@echo "📦 aab $(VERSION_NAME)"
	cd $(ANDROID_DIR) && ./gradlew bundleRelease -PversionName=$(VERSION_NAME) -PversionCode=$(VERSION_CODE)
	mkdir -p $(BUILD_DIR)
	cp $(ANDROID_DIR)/app/build/outputs/bundle/release/app-release.aab $(BUILD_DIR)/$(APP_NAME).aab

aws-aab:
	# replace `applicationId "top.ourfor.app.iplay"` in android/app/build.gradle to `applicationId "top.ourfor.app.iplayx"`
	sed -i '' 's/applicationId "top.ourfor.app.iplay"/applicationId "top.ourfor.app.iplayx"/' $(ANDROID_DIR)/app/build.gradle
	cd $(ANDROID_DIR) && ./gradlew bundleRelease -PversionName=$(VERSION_NAME) -PversionCode=$(VERSION_CODE)
	mkdir -p $(BUILD_DIR)
	cp $(ANDROID_DIR)/app/build/outputs/bundle/release/app-release.aab $(BUILD_DIR)/$(APP_NAME)-aws.aab


clean:
	@echo "🧹 clean"
	rm -rf $(BUILD_DIR)
	cd $(ANDROID_DIR) && ./gradlew clean