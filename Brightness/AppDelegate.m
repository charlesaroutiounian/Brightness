//
//  AppDelegate.m
//  Brightness
//
//  Created by Charles Aroutiounian on 05/01/2015.
//  Copyright (c) 2015 Charles Aroutiounian. All rights reserved.
//

#import "AppDelegate.h"
#include <IOKit/graphics/IOGraphicsLib.h>
#import <IOKit/IOTypes.h>

@interface AppDelegate ()


@end

@implementation AppDelegate

@synthesize statusMenu, mySlider;

const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
     NSImage *img = [NSImage imageNamed:@"brightness"];

    
    [img setTemplate:YES];
    
    statusItem.image = img;
    statusItem.target = self;
    statusItem.enabled = YES;
    statusItem.highlightMode = YES;
    [statusItem setMenu:statusMenu];

   [NSThread detachNewThreadSelector:@selector(bgThread:) toTarget:self withObject:nil];
    
    
    mySlider.maxValue =100;
    mySlider.minValue =0;
    
    NSLog(@"%f",[self get_brightness]);
    //Enables highlighting
    [statusItem setHighlightMode:YES];
    [mySlider setContinuous:NO];
    [mySlider becomeFirstResponder];
    
}

// background thread to update the slider based on current brightness level
// polls between every 0.1 seconds to 1.0 second depending on interactivity
const float INTERACTIVE = 0.1;
const float BACKGROUND = 1.0;


- (void)bgThread:(NSConnection *)connection
{
    // Do something CPU intensive or time-consuming here...
    float old_brightness = [self get_brightness];
    float wait_amount = INTERACTIVE;
    while (true) {
        // every 0.1 seconds poll for the current brightness and set the slider
        NSDate *future = [NSDate dateWithTimeIntervalSinceNow: wait_amount ];
        [NSThread sleepUntilDate:future];
        
        // only change the slider if brightness has changed
        float new_brightness = [self get_brightness];
        if(old_brightness != new_brightness){
            old_brightness = new_brightness;
            [mySlider setFloatValue:new_brightness*100];
            wait_amount = INTERACTIVE;
        }else{
            // slow down wait
            wait_amount = wait_amount*4 > BACKGROUND ? BACKGROUND : wait_amount*4;
        }
       // NSLog(@"got brightness");
    }
    
}


- (float) get_brightness {
    
    
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        NSLog(@"cannot get list of displays (error %d)\n",err);
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        
        CGDirectDisplayID dspy = display[i];
        
        CGDisplayModeRef originalMode = CGDisplayCopyDisplayMode(dspy);
        


            if (originalMode == NULL)
            continue;
      io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        

        
        err= IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                        &brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "failed to get brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        else{
          //  NSLog(@"%f", brightness);

        return brightness;

        }
    }
    return -1.0;//couldn't get brightness for any display
}


-(void)setBrightnessBackground:(double)val{
    
    double value =  val *1/100;
    [self set_brightness:value];
    NSLog(@"%f",val *1/100);
}

-(IBAction)setBrightness:(id)sender{
    
    double value =  [sender doubleValue] *1/100;
    [self set_brightness:value];
    NSLog(@"%f",[sender doubleValue]/100);

}

// almost completely from: http://mattdanger.net/2008/12/adjust-mac-os-x-display-brightness-from-the-terminal/
- (void) set_brightness:(float) new_brightness {
    
    
    CGDirectDisplayID display[kMaxDisplays];
    CGDisplayCount numDisplays;
    CGDisplayErr err;
    
    
    err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
    
    if (err != CGDisplayNoErr)
        printf("cannot get list of displays (error %d)\n",err);
    for (CGDisplayCount i = 0; i < numDisplays; ++i) {
        
        
        CGDirectDisplayID dspy = display[i];
    //    CFDictionaryRef originalMode = CGDisplayCurrentMode(dspy);
        CGDisplayModeRef originalMode = CGDisplayCopyDisplayMode(dspy);
        if (originalMode == NULL)
            continue;
        io_service_t service = CGDisplayIOServicePort(dspy);
        
        float brightness;
        err= IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                        &brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "failed to get brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        
        err = IODisplaySetFloatParameter(service, kNilOptions, kDisplayBrightness,
                                         new_brightness);
        if (err != kIOReturnSuccess) {
            fprintf(stderr,
                    "Failed to set brightness of display 0x%x (error %d)",
                    (unsigned int)dspy, err);
            continue;
        }
        
        if(brightness > 0.0){
            
            
        }else{
            
            
        }
    }		
    
}
-(IBAction)exit:(id)sender{
    exit(1);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
