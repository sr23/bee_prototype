//
//  BeeScratchScene.m
//  beeproto
//
//  Created by Paul on 01/06/2014.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import "BeeScratchScene.h"

@interface BeeScratchScene () <SKPhysicsContactDelegate> {
    float _containerVelocity;
    BOOL _shouldFly;
    SKSpriteNode* _container;
}
@end

@implementation BeeScratchScene

static const uint32_t childCategory = 1 << 0;
static const uint32_t containerCategory = 1 << 1;
static const uint32_t worldCategory = 1 << 2;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self setupSceneAttributes];

        float xPos = self.frame.size.width / 6;
        float yPos = CGRectGetMidY(self.frame);

        _container = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(40.0, 40.0)];
        [self addChild:_container];
        _container.name = @"container";
        _container.position = CGPointMake(xPos, yPos);
        _container.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:20.0];
        _container.physicsBody.dynamic = YES;
        _container.physicsBody.allowsRotation = NO;
        _container.physicsBody.restitution = 0.0;
        _container.physicsBody.categoryBitMask = containerCategory;
        _container.physicsBody.collisionBitMask = worldCategory;

        SKSpriteNode* child1 = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(5.0, 5.0)];
        child1.position = CGPointMake(5.0, 0.0);
        child1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:2.5];
        child1.physicsBody.dynamic = NO;
        child1.physicsBody.categoryBitMask = childCategory;
        [_container addChild:child1];

        SKSpriteNode* child2 = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(5.0, 5.0)];
        child2.position = CGPointMake(-5.0, 0.0);
        child2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:2.5];
        child2.physicsBody.dynamic = NO;
        child2.physicsBody.categoryBitMask = childCategory;
        [_container addChild:child2];


        [_container runAction:[SKAction moveByX:self.frame.size.width y:0.0 duration:120.0]];
    }
    return self;
}

-(void)setupSceneAttributes {
    self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
    self.physicsWorld.contactDelegate = self;

    self.backgroundColor = [SKColor whiteColor];

    SKNode* ceiling = [SKNode node];
    ceiling.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    ceiling.physicsBody.dynamic = NO;
    ceiling.physicsBody.restitution = 0.0;
    ceiling.physicsBody.categoryBitMask = worldCategory;
    ceiling.position = CGPointMake(0, self.frame.size.height - 1);
    [self addChild:ceiling];

    SKNode* floor = [SKNode node];
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width * 2, 1)];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.restitution = 0.0;
    floor.physicsBody.categoryBitMask = worldCategory;
    floor.position = CGPointMake(0, 1);
    [self addChild:floor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _containerVelocity = 1.0f;
    _shouldFly = YES;


}

-(void)cancelFly {
    _shouldFly = NO;
    _containerVelocity = 0.0f;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelFly];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelFly];
}

-(void)update:(CFTimeInterval)currentTime {
    if (_shouldFly) {
        [_container.physicsBody applyImpulse:CGVectorMake(0, _containerVelocity)];
        if (_containerVelocity < 2.0f) {
            _containerVelocity += 0.05f;
        }
    }
}

-(void)didSimulatePhysics {
//    SKNode* container = [self childNodeWithName:@"container"];
//    SKNode* child = [container.children objectAtIndex:0];
//    child.position = CGPointMake(0.0, 0.0);
}


@end
