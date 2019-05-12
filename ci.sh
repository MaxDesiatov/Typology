#/bin/sh

swift test --enable-code-coverage
xcrun llvm-cov show \
  .build/debug/TypologyPackageTests.xctest/Contents/MacOS/TypologyPackageTests \
  -instr-profile=.build/debug/codecov/default.profdata > coverage.txt
bash <(curl -s https://codecov.io/bash)
