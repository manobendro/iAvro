//
//  AvroKeyboard
//
//  Created by Rifat Nabi on 6/21/12.
//  Copyright (c) 2012 OmicronLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

#import "AvroParser.h"
#import "Suggestion.h"
#import "Candidates.h"

//let this be a global so our application controller delegate can access it easily
IMKServer* server;

static NSString *IMConnectionName(void) {
    // macOS 27 registers the input method on bundleID_Connection. A custom name
    // is rewritten and then fails to match the client lookup.
    NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"InputMethodConnectionName"];
    if (name.length == 0) {
        name = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"_Connection"];
    }
    return name;
}

static void RegisterFactoryDefaults(void) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"preferences" ofType:@"plist"];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:path];
    if (defaults.count > 0) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    }
}

int main(int argc, char *argv[]) {
    
    NSString* identifier;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    RegisterFactoryDefaults();
    [AvroParser sharedInstance];
    [Suggestion sharedInstance];
    
	//find the bundle identifier and then initialize the input method server
    identifier = [[NSBundle mainBundle] bundleIdentifier];
    server = [[IMKServer alloc] initWithName:IMConnectionName() bundleIdentifier:identifier];
	[Candidates allocateSharedInstanceWithServer:server];
    
    //load the bundle explicitly because in this case the input method is a background only application
    NSNib *mainNib = [[NSNib alloc] initWithNibNamed:@"MainMenu" bundle:[NSBundle mainBundle]];
    if (mainNib == nil || [mainNib instantiateWithOwner:[NSApplication sharedApplication] topLevelObjects:nil] == NO) {
        NSLog(@"Failed to load MainMenu nib");
    }
    [mainNib release];
	
	//finally run everything
	[[NSApplication sharedApplication] run];
	
    [Candidates deallocateSharedInstance];
    [server release];
    [pool release];
    return 0;
}
