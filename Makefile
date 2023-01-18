
project:=PotentCodables
comma:=,

build-test-all: clean build-test-macos build-test-ios build-test-watchos build-test-tvos

check-tools:
	@which findsimulator || (echo "findsimulator is required. run 'make install-tools'" && exit 1)
	@which xcbeautify || (echo "xcbeautify is required. run 'make install-tools'" && exit 1)

install-tools:
	brew tap a7ex/homebrew-formulae
	brew install xcbeautify findsimulator

clean:
	@rm -rf TestResults
	@rm -rf .derived-data

make-test-results-dir:
	mkdir -p TestResults

define buildtest
	set -o pipefail && xcodebuild -resolvePackageDependencies | xcbeautify
	set -o pipefail && \
		xcodebuild -scheme $(project) \
		-resultBundleVersion 3 -resultBundlePath ./TestResults/$(1) -derivedDataPath .derived-data/$(1) -destination '$(2)' \
		-enableCodeCoverage=YES -enableAddressSanitizer=YES -enableThreadSanitizer=YES -enableThreadSanitizer=YES -enableUndefinedBehaviorSanitizer=YES \
		test | xcbeautify
endef

build-test-macos: check-tools
	$(call buildtest,macOS,platform=macOS)

build-test-ios: check-tools
	$(call buildtest,iOS,$(shell findsimulator --os-type ios "iPhone"))

build-test-tvos: check-tools
	$(call buildtest,tvOS,$(shell findsimulator --os-type tvos "Apple TV"))

build-test-watchos: check-tools
	$(call buildtest,watchOS,$(shell findsimulator --os-type watchos "Apple Watch"))

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
