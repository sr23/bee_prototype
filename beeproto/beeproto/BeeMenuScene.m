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

        self.backgroundColor = [SKColor colorWithRed:1.5 green:1.0 blue:0.5 alpha:0.0];
        
        SKLabelNode *startGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        startGameLabel.text = @"Start";
        startGameLabel.fontSize = 30;
        startGameLabel.fontColor = [SKColor blackColor];
        startGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + startGameLabel.self.frame.size.height);
        startGameLabel.name = @"start_button";
        [self addChild:startGameLabel];
        
        SKLabelNode *quitGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        quitGameLabel.text = @"Quit";
        quitGameLabel.fontSize = 30;
        quitGameLabel.fontColor = [SKColor blackColor];
        quitGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        quitGameLabel.name = @"quit_button";
        [self addChild:quitGameLabel];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"start_button"]) {
        SKTransition *reveal = [SKTransition fadeWithDuration:3];
        
        BeeMyScene *scene = [BeeMyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:reveal];
    } else if ([node.name isEqualToString:@"quit_button"]) {
        //Quit app
    }
}

@end
