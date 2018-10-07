//
//  Analyzer.h
//  AudioLab
//
//  Created by Dhaval Gogri on 9/19/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Novocaine.h"

NS_ASSUME_NONNULL_BEGIN

@interface Analyzer : NSObject
-(int) getBufferSize;
-(void) startAudioManagerAndInputBlock;
-(void) startOutputBlockForModuleB;
-(void) updateFrequencyAndPhaseIncrementModuleB:(float)freqInKHz;
-(NSString*) checkForMotion;
-(float*) getFreshData;
-(float*) getFFTData;
-(void) freeAllData;
-(void) getTopTwoFFTFrequencies;
- (Novocaine*) getAudioManager;
- (NSString*) getPeak1;
- (NSString*) getPeak2;
- (NSString*) getMaxPeak1;
- (NSString*) getMaxPeak2;
-(void) removeFromMemory;
-(void) lockFrequency;
@end

NS_ASSUME_NONNULL_END
