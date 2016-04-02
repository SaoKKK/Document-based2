//
//  DocTextPanel.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/16.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocTextPanel.h"

@interface DocTextPanel ()

@end

@implementation DocTextPanel{
    IBOutlet NSTextView *_txtView;
    IBOutlet NSTextField *txtPgRange;
    IBOutlet NSPopUpButton *popTarget;
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification{
    [_txtView setString:@""];
}
- (IBAction)popTarget:(id)sender {
}

- (IBAction)getTxt:(id)sender {
    
}

- (IBAction)export:(id)sender {
    
}

- (IBAction)exportAsPlainTxt:(id)sender {
    
}

@end
