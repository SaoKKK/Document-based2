//
//  HandleView.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/17.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface HandleView : NSView

@property (nonatomic) NSPoint startPoint;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end
