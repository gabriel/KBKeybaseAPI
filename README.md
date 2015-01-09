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
KBClient *client = [[KBClient alloc] initWithAPIHost:KBAPIKeybaseIOHost];
NSArray *userNames = @[@"gabrielh", @"chris", @"max"];
[_client usersPaginatedForKey:@"usernames" values:userNames fields:nil limit:10 success:^(NSArray *users, BOOL completed) {

  // users is an array of KBUser

} failure:^(NSError *error) {
  // There was an error
}];
```

More docs coming soon!