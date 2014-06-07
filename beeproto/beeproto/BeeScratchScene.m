//
//  BeeScratchScene.m
//  beeproto
//
//  Created by Paul on 01/06/2014.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import "BeeScratchScene.h"
#import "BeeBoid.h"

@interface BeeScratchScene () <SKPhysicsContactDelegate> {
    float _containerVelocity;
    BOOL _shouldFly;
    SKSpriteNode* _container;
}
@end

@implementation BeeScratchScene

static const uint32_t containerCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;

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

        [self initBoidsWithStartX:xPos AndStartY:yPos];
    }
    return self;
}

-(void)initBoidsWithStartX:(float)xpos AndStartY:(float)ypos {
    for (int i = 0; i < 6; i++) {
        BeeBoid* beeBoid = [BeeBoid spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(5.0, 5.0)];
        beeBoid.position = CGPointMake(xpos, ypos);
        beeBoid.name = @"beeBoid";
        [self addChild:beeBoid];
    }
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
    [self moveAllBoidsToNewPositions];
}

-(void)moveAllBoidsToNewPositions {
    NSMutableArray* boids = [[NSMutableArray alloc] init];
    [self enumerateChildNodesWithName:@"beeBoid" usingBlock:^(SKNode* node, BOOL* stop) {
        NSLog(@"Updating boid position");
        [boids addObject:(BeeBoid*)node];
    }];

    CGVector v1, v2, v3, bv; //v1 = move to position of container physics body, v2 = keep away from other boids, v3 = match velocity with other boids
    CGPoint containerPos = [self childNodeWithName:@"container"].position;
    for (int i = 0; i < [boids count]; i++) {
        BeeBoid* boid = boids[i];
        bv = [boid getVelocity];

        v1 = CGVectorMake((containerPos.x - boid.position.x) / 100, (containerPos.y - boid.position.y) / 100);

        [boid setVelocity:CGVectorMake(bv.dx + v1.dx + v2.dx + v3.dx, bv.dy + v1.dy + v2.dy + v3.dy)];
        boid.position = CGPointMake(boid.position.x + [boid getVelocity].dx, boid.position.y + [boid getVelocity].dy);
    }
}

@end
