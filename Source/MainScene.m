//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Tran MinhTuan on 5/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "OALSimpleAudio.h"

static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

#define SFX_SWING @"sfx_wing.mp3"
#define SFX_HIT @"sfx_hit.mp3"
#define SFX_POINT @"sfx_point.mp3"

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderClouds,
    DrawingOrderGround,
    DrawingOrdeHero
};

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    CCNode *_cloud1;
    CCNode *_cloud2;
    NSArray *_clouds;
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    
    CGFloat _scrollSpeed;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    
    OALSimpleAudio *audio;
}


- (void)didLoadFromCCB {
    _scrollSpeed = 80.f;
    self.userInteractionEnabled = TRUE;
    
    _grounds = @[_ground1, _ground2];
    
    _clouds = @[_cloud1, _cloud2];
    
    for (CCNode *ground in _grounds) {
        // set collision type
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    for (CCNode *cloud in _clouds) {
        cloud.zOrder = DrawingOrderClouds;
    }
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    // set collision txpe
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    // access audio object
    audio = [OALSimpleAudio sharedInstance];
    // play sound effect
    [audio preloadEffect:SFX_HIT];
    [audio preloadEffect:SFX_POINT];
}

#pragma mark - Touch Handling

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
        [_hero.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
}

#pragma mark - CCPhysicsCollisionDelegate

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {

    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    [audio playEffect:SFX_POINT];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    return TRUE;
}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        [audio playEffect:SFX_HIT];
//         NSLog(SFX_HIT);
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.02f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderPipes;
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

#pragma mark - Update

- (void)update:(CCTime)delta {
    // clamp velocity
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    
    _sinceTouch += delta;
    
    _hero.rotation = clampf(_hero.rotation, -30.f, 90.f);
    
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f)) {
        [_hero.physicsBody applyAngularImpulse:-40000.f * delta * 0.1];
    }
    
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    // loop the ground
    for (CCNode *cloud in _clouds) {
        // get the world position of the cloud
        CGPoint cloudWorldPosition = [_physicsNode convertToWorldSpace:cloud.position];
        // get the screen position of the cloud
        CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (cloudScreenPosition.x <= (-1 * cloud.contentSize.width)) {
            cloud.position = ccp(cloud.position.x + 2 * cloud.contentSize.width, cloud.position.y);
        }
    }

    
    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
}

@end