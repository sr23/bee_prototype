//
//  BeeMenuScene.m
//  beeproto
//
//  Created by Paul on 31/05/2014.
//  Copyright (c) 2014 SR23. All rights reserved.
//

#import "BeeMenuScene.h"

@implementation BeeMenuScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        self.backgroundColor = [SKColor yellowColor];
        
        SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        startGameLabel.text = @"Start";
        startGameLabel.fontSize = 50;
        startGameLabel.fontColor = [SKColor blackColor];
        startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        startGameLabel.name = @"start_button";
        [self addChild:startGameLabel];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start_button"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:1];
        
        BeeMyScene *scene = [BeeMyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
    }
}

@end
