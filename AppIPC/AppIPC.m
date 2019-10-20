//
//  AppIPC.m
//  AppIPC
//
//  Created by Matt Jacobson on 10/19/19.
//  Copyright © 2019 Matt Jacobson. All rights reserved.
//

#import <AppIPC/AppIPC.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

static const AEEventClass eventClassAppIPC = 'AIPC';
static const AEEventID eventIDMessage = 'MESG';
static const AEKeyword keywordArguments = 'args';

static void (^messageHandler)(NSDictionary *);

static NSAppleEventDescriptor *descriptorForObject(id object) {
    if ([object isKindOfClass:[NSString self]]) {
        return [NSAppleEventDescriptor descriptorWithString:(NSString *)object];
    } else {
        return nil;
    }
}

static id objectForDescriptor(NSAppleEventDescriptor *descriptor) {
    switch ([descriptor descriptorType]) {
        case typeUnicodeText:
            return [descriptor stringValue];
        default:
            return nil;
    }
}

@implementation NSApplication (AppIPC)

- (void)receiveMessagesWithHandler:(void (^)(NSDictionary *))handler {
    assert(messageHandler == NULL);

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:eventClassAppIPC andEventID:eventIDMessage];

    messageHandler = Block_copy(handler);
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSMutableDictionary *const message = [NSMutableDictionary dictionary];

    NSAppleEventDescriptor *const argumentListDescriptor = [event paramDescriptorForKeyword:keywordArguments];
    const NSInteger numberOfItems = [argumentListDescriptor numberOfItems];

    assert((numberOfItems & 1) == 0);

    for (NSInteger i = 1; i < numberOfItems; i += 2) {
        NSAppleEventDescriptor *const keyDescriptor = [argumentListDescriptor descriptorAtIndex:i];
        NSAppleEventDescriptor *const valueDescriptor = [argumentListDescriptor descriptorAtIndex:(i + 1)];

        NSString *const key = objectForDescriptor(keyDescriptor);
        NSString *const value = objectForDescriptor(valueDescriptor);

        if (key != nil && value != nil) {
            [message setObject:value forKey:key];
        }
    }

    messageHandler([message copyWithZone:NULL]);
}

@end

@implementation NSRunningApplication (AppIPC)

- (NSAppleEventDescriptor *)addressAppleEventDescriptor {
    if ([self isEqual:[NSRunningApplication currentApplication]]) {
        return [NSAppleEventDescriptor currentProcessDescriptor];
    } else {
//        return [NSAppleEventDescriptor descriptorWithApplicationURL:[self bundleURL]];
        return [NSAppleEventDescriptor descriptorWithProcessIdentifier:[self processIdentifier]];
//        return [NSAppleEventDescriptor descriptorWithBundleIdentifier:[self bundleIdentifier]];
    }
}

- (void)sendMessage:(NSDictionary *)message {
    NSAppleEventDescriptor *const addressDescriptor = [self addressAppleEventDescriptor];

    NSAppleEventDescriptor *const descriptor = [[NSAppleEventDescriptor alloc] initWithEventClass:eventClassAppIPC eventID:eventIDMessage targetDescriptor:addressDescriptor returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];

    NSAppleEventDescriptor *const argumentListDescriptor = [[NSAppleEventDescriptor alloc] initListDescriptor];
    NSInteger index = 0;

    for (id key in message) {
        const id value = [message objectForKey:key];

        NSAppleEventDescriptor *const keyDescriptor = descriptorForObject(key);
        NSAppleEventDescriptor *const valueDescriptor = descriptorForObject(value);

        assert(keyDescriptor != nil);
        assert(valueDescriptor != nil);

        index++;
        [argumentListDescriptor insertDescriptor:keyDescriptor atIndex:index];

        index++;
        [argumentListDescriptor insertDescriptor:valueDescriptor atIndex:index];
    }

    [descriptor setParamDescriptor:argumentListDescriptor forKeyword:keywordArguments];
    [argumentListDescriptor release];

    NSError *error = nil;
    [descriptor sendEventWithOptions:NSAppleEventSendNoReply timeout:0. error:&error];

    if (error) {
        NSLog(@"Got error when sending message: %@", error);
    }

    [descriptor release];
}

@end
