
project:=PotentCodables

build-test: clean build-test-macOS build-test-iOS build-test-tvOS

clean:
	rm -rf $(project)Test.xcodeproj
	rm -rf Project
	rm -rf TestResults

define buildtestpkg
	xcodebuild -scheme $(project) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -destination '$(2)' test
endef

define buildtestprj
	xcodebuild -scheme $(project)Wrap_$(1) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -destination '$(2)' test
endef

generate-project:
	xcodegen

build-test-macOS:
	$(call buildtestpkg,macOS,platform=macOS)

build-test-iOS: generate-project
	$(call buildtestprj,iOS,name=iPhone 8)

build-test-tvOS: generate-project
	$(call buildtestprj,tvOS,name=Apple TV)
