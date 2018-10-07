//
//  ViewController.m
//  AudioLab
//
//  Created by Eric Larson
//  Copyright © 2016 Eric Larson. All rights reserved.
//

#import "ViewController.h"
#import "SMUGraphHelper.h"
#import "Analyzer.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelFrequency1;
@property (weak, nonatomic) IBOutlet UILabel *labelFrequency2;
@property (weak, nonatomic) IBOutlet UISwitch *switchCaptureFreq;
@property (strong, nonatomic) SMUGraphHelper *graphHelper;
@property (strong, nonatomic) Analyzer *analyzer;
@end

@implementation ViewController

// lazy instantaiting the analyzer module
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
                                                       numGraphs:2
                                                       plotStyle:PlotStyleSeparated
                                               maxPointsPerGraph:[self.analyzer getBufferSize]];
    }
    return _graphHelper;
}

#pragma mark VC Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setting the capture frequency data switch to false
    [self.switchCaptureFreq setOn:false];

    // setting graph bounds
    [self.graphHelper setScreenBoundsBottomHalf];
    
    // initializing the inout stream I.E the microphone for getting the data input block
    [self.analyzer startAudioManagerAndInputBlock];
}

#pragma mark GLK Inherited Functions
//  override the GLKViewController update function, from OpenGLES
- (void)update{
    
    
    //send off for graphing raw sign wave
    [self.graphHelper setGraphData:[self.analyzer getFreshData]
                    withDataLength:[self.analyzer getBufferSize]
                     forGraphIndex:0];
    
    
    // graph the FFT Data
    [self.graphHelper setGraphData:[self.analyzer getFFTData]
                    withDataLength:([self.analyzer getBufferSize])/2
                     forGraphIndex:1
                 withNormalization:64.0
                     withZeroValue:-60];
    
    // getting the top 2 highest magnitudes FFTs and storing in it variables
    [self.analyzer getTopTwoFFTFrequencies];
    
    // locking max magnitude frequency value
    if(self.switchCaptureFreq.isOn){
        [self.labelFrequency1 setText:[self.analyzer getMaxPeak1]];
        [self.labelFrequency2 setText:[self.analyzer getMaxPeak2]];
    }
    // showing live frequencies
    else{
        [self.labelFrequency1 setText:[self.analyzer getPeak1]];
        [self.labelFrequency2 setText:[self.analyzer getPeak2]];
    }
    
    [self.graphHelper update]; // update the graph
    
}

//  override the GLKView draw function, from OpenGLES
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.graphHelper draw]; // draw the graph
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if ([self isMovingFromParentViewController])
    {
        // free the memmory
        NSLog(@"View controller was popped");
        [self.analyzer removeFromMemory];
    }
    else
    {
        NSLog(@"New view controller was pushed");
    }
}

- (IBAction)switchChanged:(UISwitch *)sender {
    if(sender.isOn){
        // lock the last frequencies.
        [self.analyzer lockFrequency];
    }
}


@end
