//
//  Obstacle.h
//  FlappyFly
//
//  Created by Tran MinhTuan on 5/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"


#define ARC4RANDOM_MAX      0x100000000

// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopPipe = 128.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomPipe = 440.f;
// distance between top and bottom pipe
static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;

@interface Obstacle : CCNode
- (void)setupRandomPosition;
@end
