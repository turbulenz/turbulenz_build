
    setenv PATH "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"

DBEUG:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
  -x objective-c++ -arch i386 -fmessage-length=0 -Wno-trigraphs -fpascal-strings
  -O0
  -Wno-missing-field-initializers -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak \
  -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-shorten-64-to-32 -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations -Wno-arc-abi -Wno-c++11-extensions \
  -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk \
  -fexceptions -fasm-blocks -Wprotocol -Wdeprecated-declarations -Winvalid-offsetof \
  -g \
  -fvisibility=hidden -fvisibility-inlines-hidden \
  -Wno-sign-conversion -fobjc-abi-version=2 -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" "-DIBAction=void)__attribute__((ibaction)" \
  -mios-simulator-version-min=5.0 \
  <includes>
  -DDEBUG
  -MMD -MT dependencies
  -MF /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Debug-iphonesimulator/Ejecta.build/Objects-normal/i386/EJFont.d
  --serialize-diagnostics /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Debug-iphonesimulator/Ejecta.build/Objects-normal/i386/EJFont.dia
  -c /Users/dtebbs/tmp/ejecta/Source/Ejecta/EJCanvas/2D/EJFont.mm
  -o /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Debug-iphonesimulator/Ejecta.build/Objects-normal/i386/EJFont.o

RELEASE:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
  -x objective-c -arch i386 -fmessage-length=0 -std=c99 -Wno-trigraphs -fpascal-strings
  -Os \
  -Wno-missing-field-initializers -Wno-missing-prototypes -Wreturn-type -Wno-implicit-atomic-properties -Wno-receiver-is-weak \
  -Wformat -Wno-missing-braces -Wparentheses -Wswitch -Wno-unused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wno-empty-body -Wno-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wno-shorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wno-undeclared-selector -Wno-deprecated-implementations \
  -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator6.0.sdk
  -fexceptions -fasm-blocks -Wprotocol -Wdeprecated-declarations \
  -g \
  -fvisibility=hidden \
  -Wno-sign-conversion -fobjc-abi-version=2 -fobjc-legacy-dispatch "-DIBOutlet=__attribute__((iboutlet))" "-DIBOutletCollection(ClassName)=__attribute__((iboutletcollection(ClassName)))" "-DIBAction=void)__attribute__((ibaction)" \
  -mios-simulator-version-min=5.0 \
  <includes>
  -DNS_BLOCK_ASSERTIONS=1 \
  -MMD -MT dependencies \
  -MF /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphonesimulator/Ejecta.build/Objects-normal/i386/EJBindingEjectaCore.d \
  --serialize-diagnostics /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphonesimulator/Ejecta.build/Objects-normal/i386/EJBindingEjectaCore.dia \
  -c /Users/dtebbs/tmp/ejecta/Source/Ejecta/EJBindingEjectaCore.m
  -o /Users/dtebbs/Library/Developer/Xcode/DerivedData/Ejecta-abjzkyrhuxnmjffqvnaarumhzwrh/Build/Intermediates/Ejecta.build/Release-iphonesimulator/Ejecta.build/Objects-normal/i386/EJBindingEjectaCore.o
