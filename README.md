# AppIPC

An imagining of what a nicer Apple Events API for Cocoa might have looked like in, say, the late 2000s.  And some demo apps that show it off.

```objective-c
@interface NSApplication (AppIPC)

- (void)receiveMessagesWithHandler:(void (^)(NSDictionary *))handler;

@end

@interface NSRunningApplication (AppIPC)

- (void)sendMessage:(NSDictionary *)message;

@end
```
