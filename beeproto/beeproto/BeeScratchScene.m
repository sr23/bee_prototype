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
        [self setupParallax];

        float xPos = self.frame.size.width / 6;
        float yPos = CGRectGetMidY(self.frame);

        _container = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(40.0, 40.0)];
        [self addChild:_container];
        _container.name = @"container";
        _container.hidden = YES;
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

-(void)setupParallax {
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;

    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.01 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];

    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
        // Create the sprite
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        [sprite setScale:2.0];
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 12);
        [sprite runAction:moveGroundSpritesForever];
        [self addChild:sprite];
    }

    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;

    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.05 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];

    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale:2.0];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size.height);
        [sprite runAction:moveSkylineSpritesForever];
        [self addChild:sprite];
    }
}

-(void)initBoidsWithStartX:(float)xpos AndStartY:(float)ypos {
    SKTexture* beeTexture1 = [SKTexture textureWithImageNamed:@"bee1"];
    SKTexture* beeTexture2 = [SKTexture textureWithImageNamed:@"bee2"];

    SKAction* flyAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:@[beeTexture1, beeTexture2] timePerFrame:0.05]];

    CGPoint startPositions[] = {CGPointMake(xpos, ypos), CGPointMake(xpos + 20.0, ypos), CGPointMake(xpos + 20.0, ypos + 20.0),
        CGPointMake(xpos + 20.0, ypos - 20.0), CGPointMake(xpos, ypos + 20.0), CGPointMake(xpos, ypos - 20.0),
        CGPointMake(xpos - 20.0, ypos), CGPointMake(xpos - 20.0, ypos + 20.0), CGPointMake(xpos - 20.0, ypos - 20.0),
        CGPointMake(xpos, ypos + 40.0), CGPointMake(xpos, ypos - 40.0), CGPointMake(xpos + 40.0, ypos),
        CGPointMake(xpos - 40.0, ypos)};
    for (int i = 0; i < 13; i++) {
        BeeBoid* beeBoid = [BeeBoid spriteNodeWithTexture:beeTexture1];
        beeBoid.position = startPositions[i];
        beeBoid.name = @"beeBoid";
        beeBoid.scale = 0.4;
        [beeBoid runAction:flyAnimation];
        [self addChild:beeBoid];
    }
}

-(void)setupSceneAttributes {
    self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
    self.physicsWorld.contactDelegate = self;

    self.backgroundColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];

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
        [boids addObject:(BeeBoid*)node];
    }];

    CGVector v1, v2, v3, v4, v5, bv; //v1 = move to position of container physics body, v2 = keep away from other boids, v3 = match velocity with other boids, v4 = speed limit, v5 =
    CGPoint containerPos = [self childNodeWithName:@"container"].position;
    for (int i = 0; i < [boids count]; i++) {
        BeeBoid* boid = boids[i];
        bv = [boid getVelocity];

        v1 = [self rule1Boids:boids currentBoidIndex:i currentBoid:boid];
        v2 = [self rule2Boids:boids currentBoidIndex:i currentBoid:boid];
        v3 = [self rule3Boids:boids currentBoidIndex:i currentBoid:boid];
        v4 = [self boundPosition:boid];
        v5 = [self moveBoid:boid TowardContainer:containerPos];

        [boid setVelocity:CGVectorMake(bv.dx + v1.dx + v2.dx + v3.dx + v4.dx + v5.dx, bv.dy + v1.dy + v2.dy + v3.dy + v4.dy + v5.dy)];
        [self rule4Boid:boid];
        boid.position = CGPointMake(boid.position.x + [boid getVelocity].dx, boid.position.y + [boid getVelocity].dy);
    }
}

//Move centre of mass
-(CGVector)rule1Boids:(NSMutableArray*)boids currentBoidIndex:(int)boidIndex currentBoid:(BeeBoid*)bj {
    CGVector pcj;

    for (int i = 0; i < [boids count]; i++) {
        if (i != boidIndex) {
            BeeBoid* b = boids[i];
            pcj = CGVectorMake(pcj.dx + b.position.x, pcj.dy + b.position.y);
        }
    }

    long num = [boids count] - 1;
    pcj = CGVectorMake(pcj.dx / num, pcj.dy / num);

    return CGVectorMake((pcj.dx - bj.position.x) / 100, (pcj.dy - bj.position.y) / 100);
}

//Keep away from other boids
-(CGVector)rule2Boids:(NSMutableArray*)boids currentBoidIndex:(int)boidIndex currentBoid:(BeeBoid*)bj {
    CGVector c = CGVectorMake(0.0, 0.0);

    for (int i = 0; i < [boids count]; i++) {
        if (i != boidIndex) {
            BeeBoid* b = boids[i];
            CGVector diff = CGVectorMake(b.position.x - bj.position.x, b.position.y - bj.position.y);
            float magnitude = sqrtf((diff.dx * diff.dx) + (diff.dy * diff.dy));
            if (magnitude < 20) {
                c = CGVectorMake(c.dx - (b.position.x - bj.position.x), c.dy - (b.position.y - bj.position.y));
            }

        }
    }

    return c;
}

//Match velocity with other boids
-(CGVector)rule3Boids:(NSMutableArray*)boids currentBoidIndex:(int)boidIndex currentBoid:(BeeBoid*)bj {
    CGVector pvj;

    for (int i = 0; i < [boids count]; i++) {
        if (i != boidIndex) {
            BeeBoid* b = boids[i];
            pvj = CGVectorMake(pvj.dx + [b getVelocity].dx, pvj.dy + [b getVelocity].dy);
        }
    }

    long num = [boids count] - 1;
    pvj = CGVectorMake(pvj.dx / num, pvj.dy / num);

    return CGVectorMake((pvj.dx - [bj getVelocity].dx) / 8, (pvj.dy - [bj getVelocity].dy) / 8);
    
    return pvj;
}

//Limit speed
-(void)rule4Boid:(BeeBoid*)boid {
    float speedLimit = 3.0;

    float magnitude = sqrtf(([boid getVelocity].dx * [boid getVelocity].dx) + ([boid getVelocity].dy * [boid getVelocity].dy));
    if (magnitude > speedLimit) {
        float vx = ([boid getVelocity].dx / magnitude) * speedLimit;
        float vy = ([boid getVelocity].dy / magnitude) * speedLimit;
        [boid setVelocity:CGVectorMake(vx, vy)];
    }
}

//Bound positions
-(CGVector)boundPosition:(BeeBoid*)boid {
    int xMin = self.frame.size.width / 12;
    int xMax = self.frame.size.width / 12 * 3;
    int yMin = 0;
    int yMax = self.frame.size.height;
    CGVector v = CGVectorMake(0.0, 0.0);

    if (boid.position.x < xMin) {
        v.dx = 10.0;
    } else if (boid.position.x > xMax) {
        v.dx = -10.0;
    }
    if (boid.position.y < yMin) {
        v.dy = 10.0;
    } else if (boid.position.y > yMax) {
        v.dy = -10.0;
    }
    return v;
}

-(CGVector)moveBoid:(BeeBoid*)boid TowardContainer:(CGPoint)containerPos {
    return CGVectorMake((containerPos.x - boid.position.x) / 100, (containerPos.y - boid.position.y) / 100);
}


@end
