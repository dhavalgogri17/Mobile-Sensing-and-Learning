//
//  ViewControllerModuleB.m
//  AudioLab
//
//  Created by Dhaval Gogri on 9/20/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "ViewControllerModuleB.h"
#import "SMUGraphHelper.h"
#import "Analyzer.h"
#import "Novocaine.h"


@interface ViewControllerModuleB ()
    @property (weak, nonatomic) IBOutlet UILabel *labelViewGestureInformation;
    @property (weak, nonatomic) IBOutlet UILabel *labelMaxMagnitude;
    @property (nonatomic) float frequency;
    @property (nonatomic) float phaseIncrement;
    @property (strong, nonatomic) SMUGraphHelper *graphHelper;
    @property (strong, nonatomic) Analyzer *analyzer;

@end

@implementation ViewControllerModuleB

-(Analyzer*)analyzer{
    if(!_analyzer){
        _analyzer = [[Analyzer alloc] init];
    }
    return _analyzer;
}


#pragma mark Lazy Instantiation
-(SMUGraphHelper*)graphHelper{
    if(!_graphHelper){
        _graphHelper = [[SMUGraphHelper alloc]initWithController:self
                                        preferredFramesPerSecond:15
                                                       numGraphs:1
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:[self.analyzer getBufferSize]];
    }
    return _graphHelper;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View DID Load");
    
    // setting graph bounds
    [self.graphHelper setScreenBoundsBottomHalf];
    
    // initializng input block
    [self.analyzer startAudioManagerAndInputBlock];
    
    // initializing output block
    [self.analyzer startOutputBlockForModuleB];
    
    [[self.analyzer getAudioManager] play];
}

// when slider value is changed
- (IBAction)frequencyChanged:(UISlider *)sender {
    [self.analyzer updateFrequencyAndPhaseIncrementModuleB:sender.value];
    
}

-(void) update{
    
    // update input from microphone
    [self.analyzer getFreshData];
    
    // update label for gesture & check for gesture
    [self.labelViewGestureInformation setText:[self.analyzer checkForMotion]];
    
    // plot graph of FFT of input
    [self.graphHelper setGraphData:[self.analyzer getFFTData]
                    withDataLength:([self.analyzer getBufferSize])/2
                     forGraphIndex:0
                 withNormalization:512.0
                     withZeroValue:0];
    
    
    [self.graphHelper update]; // update the graph
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self isMovingFromParentViewController])
    {
        NSLog(@"View controller was popped");
        [[self.analyzer getAudioManager] pause];
        [self.analyzer removeFromMemory];
        
    }
    else
    {
        NSLog(@"New view controller was pushed");
    }
}

@end
