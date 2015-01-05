//
//  AppDelegate.h
//  Brightness
//
//  Created by Charles Aroutiounian on 05/01/2015.
//  Copyright (c) 2015 Charles Aroutiounian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
 #import <IOKit/IOTypes.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    IBOutlet NSMenu *statusMenu;
    
    IBOutlet  NSSlider *mySlider;
    
    NSStatusItem *statusItem;


}

@property (nonatomic, strong)  IBOutlet  NSSlider *mySlider;

@property (nonatomic, strong)  IBOutlet NSMenu *statusMenu;

-(void) set_brightness:(float)new_brightness;
-(IBAction)setBrightness:(id)sender;
-(void)setBrightnessBackground:(double)val;

@end

