#import "Gm5UtilsPlugin.h"
#if __has_include(<gm5_utils/gm5_utils-Swift.h>)
#import <gm5_utils/gm5_utils-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "gm5_utils-Swift.h"
#endif

@implementation Gm5UtilsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGm5UtilsPlugin registerWithRegistrar:registrar];
}
@end
