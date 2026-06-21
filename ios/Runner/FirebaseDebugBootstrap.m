#import "FirebaseDebugBootstrap.h"

#import <objc/message.h>

#if DEBUG
static void MitoosaSetAPMUserDefaultsDebugMode(void) {
  Class apmDefaultsClass = NSClassFromString(@"APMUserDefaults");
  if (apmDefaultsClass == nil) {
    return;
  }

  SEL sharedSelector = NSSelectorFromString(@"sharedUserDefaults");
  if (![apmDefaultsClass respondsToSelector:sharedSelector]) {
    return;
  }

  id apmDefaults = ((id (*)(Class, SEL))objc_msgSend)(apmDefaultsClass, sharedSelector);
  if (apmDefaults == nil) {
    return;
  }

  SEL setObjectSelector = @selector(setObject:forKey:);
  ((void (*)(id, SEL, id, id))objc_msgSend)(apmDefaults, setObjectSelector, @YES,
                                            @"/google/measurement/debug_mode");
  ((void (*)(id, SEL, id, id))objc_msgSend)(apmDefaults, setObjectSelector, @YES,
                                            @"/google/firebase/debug_mode");
}

static void MitoosaEnsureFirebaseDebugLaunchArguments(void) {
  NSArray<NSString *> *args = [[NSProcessInfo processInfo] arguments];
  NSLog(@"[MitoosaDebug] Initial process arguments: %@", args);
  NSMutableArray<NSString *> *arguments = [args mutableCopy];
  if (arguments == nil) {
    return;
  }

  if (![arguments containsObject:@"-FIRDebugEnabled"]) {
    [arguments addObject:@"-FIRDebugEnabled"];
  }
  if (![arguments containsObject:@"-FIRAnalyticsDebugEnabled"]) {
    [arguments addObject:@"-FIRAnalyticsDebugEnabled"];
  }

  [[NSProcessInfo processInfo] setValue:[arguments copy] forKey:@"arguments"];
}
#endif

void MitoosaEnableFirebaseAnalyticsDebugMode(void) {
#if DEBUG
  NSLog(@"[MitoosaDebug] MitoosaEnableFirebaseAnalyticsDebugMode called.");
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:@"/google/firebase/debug_mode"];
  [defaults setBool:YES forKey:@"/google/measurement/debug_mode"];
  [defaults synchronize];

  MitoosaSetAPMUserDefaultsDebugMode();
  MitoosaEnsureFirebaseDebugLaunchArguments();
#endif
}

#if DEBUG
__attribute__((constructor(0))) static void MitoosaFirebaseDebugBootstrap(void) {
  NSLog(@"[MitoosaDebug] MitoosaFirebaseDebugBootstrap constructor(0) executing.");
  MitoosaEnableFirebaseAnalyticsDebugMode();
}
#endif
