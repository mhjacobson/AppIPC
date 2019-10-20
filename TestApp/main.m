//
//  main.m
//  AppIPC
//
//  Created by Matt Jacobson on 10/19/19.
//  Copyright © 2019 Matt Jacobson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppIPC/AppIPC.h>

@interface AppController : NSObject <NSApplicationDelegate>

@property (copy) NSColor *boxColor;

@property (weak) IBOutlet NSPopUpButton *colorPopUp;
@property (weak) IBOutlet NSBox *colorBox;

@end

@implementation AppController {
    NSColor *_boxColor;
}

- (NSColor *)boxColor {
    return _boxColor;
}

- (void)setBoxColor:(NSColor *)boxColor {
    _boxColor = boxColor;

    [[self colorBox] setFillColor:_boxColor];

    NSPopUpButton *const colorPopUp = [self colorPopUp];
    [colorPopUp selectItemAtIndex:[colorPopUp indexOfItemWithRepresentedObject:_boxColor]];
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

    [NSApp receiveMessagesWithHandler:^(NSDictionary *message) {
        NSLog(@"did receive message %@", message);
        NSString *colorName = [message objectForKey:@"SetColor"];
        NSColor *color = [defaultColors objectForKey:colorName];
        [self setBoxColor:color];
    }];
}

@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        return NSApplicationMain(argc, argv);
    }
}
