
project:=PotentCodables
comma:=,

clean:
	rm -rf TestResults

make-test-results-dir:
	mkdir -p TestResults

define buildtest
	xcodebuild -scheme $(project) -resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -destination '$(2)' -enableCodeCoverage=YES -enableAddressSanitizer=YES -enableThreadSanitizer=YES -enableThreadSanitizer=YES -enableUndefinedBehaviorSanitizer=YES test
endef

build-test-macos:
	swift test --enable-code-coverage

build-test-ios:
	$(call buildtest,iOS,platform=iOS Simulator$(comma)name=iPhone 12)

build-test-tvos:
	$(call buildtest,tvOS,platform=tvOS Simulator$(comma)name=Apple TV)

build-test-all: build-test-macos build-test-ios build-test-tvos

format:	
	swiftformat --config .swiftformat Sources/ Tests/

lint: make-test-results-dir
	swiftlint lint --reporter html > TestResults/lint.html

view_lint: lint
	open TestResults/lint.html

update-fyaml:
	rm -rf Sources/Cfyaml
	mkdir Sources/Cfyaml
	curl -L --output libfyaml-${FYAML_VER}.tar.gz --silent https://github.com/pantoniou/libfyaml/releases/download/v${FYAML_VER}/libfyaml-${FYAML_VER}.tar.gz
	tar -xf libfyaml-${FYAML_VER}.tar.gz -C Sources/Cfyaml --strip-components 1
	rm libfyaml-${FYAML_VER}.tar.gz
	cd Sources/Cfyaml && ./bootstrap.sh
	cd Sources/Cfyaml && ./configure
	cd Sources/Cfyaml && sed -i '' 's/HAVE_LIBYAML 1/HAVE_LIBYAML 0/g' config.h
