
project:=PotentCodables

build-test: clean build-test-macOS build-test-iOS build-test-tvOS

clean:
	rm -rf $(project).xcodeproj
	rm -rf Project
	rm -rf TestResults

define buildtest
	xcodebuild -scheme $(project) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -destination '$(2)' test
endef

build-test-macOS:
	$(call buildtest,macOS,platform=macOS)

build-test-iOS:
	$(call buildtest,iOS,name=iPhone 8)

build-test-tvOS:
	$(call buildtest,tvOS,name=Apple TV)
