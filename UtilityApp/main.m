//
//  main.m
//  UtilityApp
//
//  Created by Matt Jacobson on 10/19/19.
//  Copyright © 2019 Matt Jacobson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppIPC/AppIPC.h>

@interface AppController : NSObject <NSApplicationDelegate>

@property (copy) NSColor *boxColor;
@property (weak) IBOutlet NSPopUpButton *colorPopUp;

@end

@implementation AppController {
    NSColor *_boxColor;
}

- (NSColor *)boxColor {
    return _boxColor;
}

- (void)setBoxColor:(NSColor *)boxColor {
    _boxColor = boxColor;

    NSPopUpButton *const colorPopUp = [self colorPopUp];
    const NSInteger itemIndex = [colorPopUp indexOfItemWithRepresentedObject:_boxColor];
    [colorPopUp selectItemAtIndex:itemIndex];

    [[[NSRunningApplication runningApplicationsWithBundleIdentifier:@"net.mjacobson.AppIPC-TestApp"] firstObject] sendMessage:@{
        @"SetColor" : [[colorPopUp itemAtIndex:itemIndex] title],
    }];
}

- (IBAction)popUpDidChange:(NSPopUpButton *)sender {
    [self setBoxColor:[[sender selectedItem] representedObject]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSDictionary<NSString *, NSColor *> *defaultColors = @{
        @"Red" : [NSColor systemRedColor],
        @"Green" : [NSColor systemGreenColor],
        @"Blue" : [NSColor systemBlueColor],
    };

    for (NSString *title in defaultColors) {
        NSColor *color = [defaultColors objectForKey:title];

        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTitle:title];
        [item setRepresentedObject:color];

        [[_colorPopUp menu] addItem:item];
    }

    [self setBoxColor:[NSColor systemRedColor]];
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        return NSApplicationMain(argc, argv);
    }
}
