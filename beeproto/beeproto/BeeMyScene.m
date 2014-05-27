//
//  BeeMyScene.m
//  beeproto
//
//  Created by Qianqian Fu on 5/26/14.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import "BeeMyScene.h"

@interface BeeMyScene () <SKPhysicsContactDelegate> {
    SKSpriteNode* _bee;
    SKNode* _moving;

    float _beeVelocity;
    BOOL _beeShouldFly;

    SKLabelNode* _scoreLabelNode;
    NSInteger _score;

    SKLabelNode* _healthLabelNode;
    NSInteger _health;

    SKAction* _movePollenAndRemove;
    SKAction* _moveEnemyAndRemove;
}
@end

static const uint32_t beeCategory = 1 << 0;
static const uint32_t pollenCategory = 1 << 1;
static const uint32_t worldCategory = 1 << 2;
static const uint32_t enemyCategory = 1 << 3;

@implementation BeeMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        [self setupSceneAttributes];

        _moving = [SKNode node];
        [self addChild:_moving];

        [self createBee];
        [self addChild:_bee];

        [self setupParallax];

        [self setupSceneBoundaries];

        [self beginSpawningPollen];

        [self beginSpawningEnemies];

        [self setupScores];

    }
    return self;
}

-(void)setupSceneAttributes {
    self.physicsWorld.gravity = CGVectorMake(0.0, -2.5);
    self.physicsWorld.contactDelegate = self;

    self.backgroundColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
}

-(void)setupScores {
    _score = 0;
    _scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    _scoreLabelNode.fontSize = 16.0;
    _scoreLabelNode.position = CGPointMake(50.0, self.frame.size.height - 40.0);
    _scoreLabelNode.zPosition = 200;
    _scoreLabelNode.text = [NSString stringWithFormat:@"Pollen: %d", _score];
    [self addChild:_scoreLabelNode];

    _health = 100;
    _healthLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Verdana"];
    _healthLabelNode.fontSize = 16.0;
    _healthLabelNode.position = CGPointMake(200.0, self.frame.size.height - 40.0);
    _healthLabelNode.zPosition = 200;
    _healthLabelNode.text = [NSString stringWithFormat:@"Health: %d", _health];
    [self addChild:_healthLabelNode];
}

-(void)createBee {
    SKTexture* beeTexture1 = [SKTexture textureWithImageNamed:@"bee1"];
    SKTexture* beeTexture2 = [SKTexture textureWithImageNamed:@"bee2"];

    SKAction* flyAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:@[beeTexture1, beeTexture2] timePerFrame:0.05]];

    _bee = [SKSpriteNode spriteNodeWithTexture:beeTexture1];
    [_bee runAction:flyAnimation];

    _bee.position = CGPointMake(self.frame.size.width / 6, CGRectGetMidY(self.frame));
    _bee.zPosition = 100;
    _bee.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bee.size.height / 2];
    _bee.physicsBody.dynamic = YES;
    _bee.physicsBody.allowsRotation = NO;
    _bee.physicsBody.restitution = 0.0;
    _bee.physicsBody.categoryBitMask = beeCategory;
    _bee.physicsBody.collisionBitMask = worldCategory;
    _bee.physicsBody.contactTestBitMask = pollenCategory | enemyCategory;
}

-(void)setupParallax {
    _moving = [SKNode node];
    [self addChild:_moving];

    SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;

    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];

    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
        // Create the sprite
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        [sprite setScale:2.0];
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
        [sprite runAction:moveGroundSpritesForever];
        [_moving addChild:sprite];
    }

    SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
    skylineTexture.filteringMode = SKTextureFilteringNearest;

    SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 * skylineTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];

    for( int i = 0; i < 2 + self.frame.size.width / ( skylineTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
        [sprite setScale:2.0];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size.height * 2);
        [sprite runAction:moveSkylineSpritesForever];
        [_moving addChild:sprite];
    }

    SKNode* floor = [SKNode node];
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height * 2)];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.restitution = 0.0;
    floor.physicsBody.categoryBitMask = worldCategory;
    floor.position = CGPointMake(0, groundTexture.size.height);
    [self addChild:floor];
}

-(void)setupSceneBoundaries {
    SKNode* ceiling = [SKNode node];
    ceiling.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, 1)];
    ceiling.physicsBody.dynamic = NO;
    ceiling.physicsBody.restitution = 0.0;
    ceiling.physicsBody.categoryBitMask = worldCategory;
    ceiling.position = CGPointMake(0, self.frame.size.height - 1);
    [self addChild:ceiling];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    _beeVelocity = 0.5f;
    _beeShouldFly = YES;
}

-(void)cancelBeeFly {
    _beeShouldFly = NO;
    _beeVelocity = 0.0f;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelBeeFly];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelBeeFly];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_beeShouldFly) {
        [_bee.physicsBody applyImpulse:CGVectorMake(0, _beeVelocity)];
        _beeVelocity += 0.005f;
        if (_beeVelocity > 1.5f) {
            _beeVelocity = 1.5f;
        }
    }
}

-(void)beginSpawningPollen {
    CGFloat distanceToMove = self.frame.size.width + 2 * 30;
    SKAction* movePollen = [SKAction moveByX:-distanceToMove y:0 duration:5];
    SKAction* removePollen = [SKAction removeFromParent];
    _movePollenAndRemove = [SKAction sequence:@[movePollen, removePollen]];

    SKAction* spawn = [SKAction performSelector:@selector(spawnPollen) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:3.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

-(void)beginSpawningEnemies {
    CGFloat distanceToMove = self.frame.size.width + 2 * 30;
    SKAction* moveEnemy = [SKAction moveByX:-distanceToMove y:0 duration:5];
    SKAction* removeEnemy = [SKAction removeFromParent];
    _moveEnemyAndRemove = [SKAction sequence:@[moveEnemy, removeEnemy]];

    SKAction* spawn = [SKAction performSelector:@selector(spawnEnemy) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:2.5];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
}

-(void)spawnPollen {
    CGFloat randomPos = arc4random() % ((NSInteger)(self.frame.size.height) - 15 - 111 + 1) + 111;

    SKTexture* texture1 = [SKTexture textureWithImageNamed:@"coin1"];
    SKTexture* texture2 = [SKTexture textureWithImageNamed:@"coin2"];
    SKTexture* texture3 = [SKTexture textureWithImageNamed:@"coin3"];
    SKTexture* texture4 = [SKTexture textureWithImageNamed:@"coin4"];
    SKTexture* texture5 = [SKTexture textureWithImageNamed:@"coin5"];
    SKTexture* texture6 = [SKTexture textureWithImageNamed:@"coin6"];
    SKTexture* texture7 = [SKTexture textureWithImageNamed:@"coin7"];
    SKTexture* texture8 = [SKTexture textureWithImageNamed:@"coin8"];

    SKAction* coinAnimation = [SKAction repeatActionForever:[SKAction animateWithTextures:@[texture1, texture2, texture3, texture4, texture5, texture6, texture7, texture8] timePerFrame:0.05]];

    SKSpriteNode* pollen = [SKSpriteNode spriteNodeWithTexture:texture1];
    [pollen runAction:coinAnimation];
    pollen.position = CGPointMake(self.frame.size.width + 20, randomPos);
    pollen.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pollen.size];
    pollen.physicsBody.dynamic = NO;
    pollen.physicsBody.categoryBitMask = pollenCategory;
    pollen.physicsBody.contactTestBitMask = beeCategory;

    [pollen runAction:_movePollenAndRemove];
    [self addChild:pollen];
}

-(void)spawnEnemy {
    CGFloat randomPos = arc4random() % ((NSInteger)(self.frame.size.height) - 15 - 111 + 1) + 111;

    SKSpriteNode* enemy = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(15, 15)];
    enemy.position = CGPointMake(self.frame.size.width + 30, randomPos);
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = NO;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = beeCategory;

    [enemy runAction:_moveEnemyAndRemove];
    [self addChild:enemy];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;

    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }

    BOOL animateAndRemove = NO;
    if (secondBody.categoryBitMask == pollenCategory) {
        [self incrementScore];
        animateAndRemove = YES;
    } else if (secondBody.categoryBitMask == enemyCategory) {
        [self decrementHealth];
        animateAndRemove = YES;
    }

    if (animateAndRemove) {
        SKSpriteNode* node = (SKSpriteNode *) secondBody.node;
        node.physicsBody = nil; //To prevent duplicate collisions

        [node runAction:[SKAction sequence:@[[SKAction scaleBy:2.0 duration:0.2], [SKAction fadeAlphaTo:0.0 duration:0.1], [SKAction removeFromParent]]]];
    }
}

-(void)incrementScore {
    _score++;
    _scoreLabelNode.text = [NSString stringWithFormat:@"Pollen: %d", _score];
}

-(void)decrementHealth {
    _health -= 5;
    _healthLabelNode.text = [NSString stringWithFormat:@"Health: %d", _health];
}

@end
