//
//  nnCALayer.m
//  string
//
//  Created by cat on 2013/09/15.
//  Copyright (c) 2013年 Ryou Inoue. All rights reserved.
//

#import "nnCALayer.h"

@implementation CALayer (nnCALayer)

-(void)pauseAnimation:(BOOL)aPause
{
    if(aPause)
    {
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0.0;
        self.timeOffset = pausedTime;
    }
    else
    {
        CFTimeInterval pausedTime = [self timeOffset];
        self.speed = 1.0;
        self.timeOffset = 0.0;
        self.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
}

@end
