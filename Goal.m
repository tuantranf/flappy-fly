//
//  Goal.m
//  FlappyFly
//
//  Created by Tran MinhTuan on 5/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
