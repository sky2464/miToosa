#import <Foundation/Foundation.h>

// Runs before main() so Analytics debug mode is active before any Firebase SDK +load.
#if DEBUG
__attribute__((constructor))
static void MitoosaFirebaseDebugBootstrap(void) {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setBool:YES forKey:@"/google/firebase/debug_mode"];
  [defaults setBool:YES forKey:@"/google/measurement/debug_mode"];
}
#endif
