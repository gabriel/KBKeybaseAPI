KBKeybase
=====

Keybase.io API client for iOS/OSX.

# Podfile

```ruby
platform :ios, "7.0"
pod "KBKeybase"
```

# Example

```objc
#import <KBKeybase/KBKeybase.h>

KBClient *client = [[KBClient alloc] initWithAPIHost:KBAPIKeybaseIOHost];
NSArray *userNames = @[@"gabrielh", @"chris", @"max"];
[_client usersPaginatedForKey:@"usernames" values:userNames fields:nil limit:10 success:^(NSArray *users, BOOL completed) {
  // The **users** var is an array of KBUser.
  // If paginating completed will be NO, and another callback will occur.
} failure:^(NSError *error) {
  // There was an error
}];
```

More docs coming soon!
