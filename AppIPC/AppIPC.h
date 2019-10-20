//
//  AppIPC.h
//  AppIPC
//
//  Created by Matt Jacobson on 10/19/19.
//  Copyright © 2019 Matt Jacobson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

//! Project version number for AppIPC.
FOUNDATION_EXPORT double AppIPCVersionNumber;

//! Project version string for AppIPC.
FOUNDATION_EXPORT const unsigned char AppIPCVersionString[];

@interface NSApplication (AppIPC)

- (void)receiveMessagesWithHandler:(void (^)(NSDictionary *))handler;

@end

@interface NSRunningApplication (AppIPC)

- (void)sendMessage:(NSDictionary *)message;

@end
