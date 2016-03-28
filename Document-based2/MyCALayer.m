//
//  MyCALayer.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/28.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "MyCALayer.h"

@implementation MyCALayer

- (void)layoutSublayers{
    for (CALayer *subLayer in self.sublayers) {
        subLayer.frame = self.superlayer.bounds;
    }
}

@end
