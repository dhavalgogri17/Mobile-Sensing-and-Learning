//
//  Analyzer.m
//  AudioLab
//
//  Created by Dhaval Gogri on 9/19/18.
//  Copyright © 2018 Eric Larson. All rights reserved.
//

#import "Analyzer.h"
#import "Novocaine.h"
#import "CircularBuffer.h"
#import "FFTHelper.h"

#define BUFFER_SIZE 4096
#define DELTA_OF_FREQUENCY 44100.0/BUFFER_SIZE/2

@interface Analyzer ()
    @property (strong, nonatomic) Novocaine *audioManager;
    @property (strong, nonatomic) CircularBuffer *buffer;
    @property (strong, nonatomic) FFTHelper *fftHelper;

    // array for input data
    @property (nonatomic) float* arrayData;
    @property (nonatomic) float* fftMagnitude;
    @property (nonatomic) float phaseIncrement;

    // stores current frequency from the slider value
    @property (nonatomic) float frequency;

    // stores highest magnitude frequency value
    @property (nonatomic) float fPeak1;

    // stores highest magnitude frequency index value
    @property (nonatomic) int maxIndex;

    // stores second highest magnitude frequency value
    @property (nonatomic) float fPeak2;

    // stores average of 100 fft values from right of max
    @property (nonatomic) float rightAvg;

    // stores average of 100 fft values from left of max
    @property (nonatomic) float leftAvg;

@end

@implementation Analyzer
float maxFreq1 = 0;
float maxFreq2 = 0;

float lockFreq1 = 0;
float lockFreq2 = 0;

-(Novocaine*)audioManager{
    if(!_audioManager){
        _audioManager = [Novocaine audioManager];
    }
    return _audioManager;
}

-(CircularBuffer*)buffer{
    if(!_buffer){
        _buffer = [[CircularBuffer alloc]initWithNumChannels:1 andBufferSize:BUFFER_SIZE];
    }
    return _buffer;
}

-(FFTHelper*)fftHelper{
    if(!_fftHelper){
        _fftHelper = [[FFTHelper alloc]initWithFFTSize:BUFFER_SIZE];
    }
    
    return _fftHelper;
}

-(float*)arrayData{
    if(!_arrayData){
        _arrayData = malloc(sizeof(float)*BUFFER_SIZE);
    }
    return _arrayData;
}

-(float*)fftMagnitude{
    if(!_fftMagnitude){
        _fftMagnitude = malloc(sizeof(float)*BUFFER_SIZE/2);
    }
    return _fftMagnitude;
}

-(float)rightAvg{
    if(!_rightAvg){
        _rightAvg = 0;
    }
    return _rightAvg;
}

-(float)leftAvg{
    if(!_leftAvg){
        _leftAvg = 0;
    }
    return _leftAvg;
}


-(int) getBufferSize{
    return BUFFER_SIZE;
}

// setting up input block and initializing audio manager
-(void) startAudioManagerAndInputBlock{
    __block Analyzer * __weak  weakSelf = self;
    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels){
        [weakSelf.buffer addNewFloatData:data withNumSamples:numFrames];
    }];
    
     [self.audioManager play];
}

// setting up output block for module B
-(void) startOutputBlockForModuleB{
    
    // initial frequency
    self.frequency = 15000;
    
    // calculating phase increment
    self.phaseIncrement = 2*M_PI*self.frequency/[self.audioManager samplingRate];
    __block float phase;
    __block Analyzer * __weak  weakSelf = self;
    
    [self.audioManager setOutputBlock:^(float* data, UInt32 numFrames, UInt32 numChannels){
        phase = 0.0;
        for (int n=0; n<numFrames; n++) {
            data[n] = sin(phase);
            phase += self.phaseIncrement;
        }
        
    }];
}

// updating frequency and phase increment
-(void) updateFrequencyAndPhaseIncrementModuleB:(float)freqInKHz{
    self.frequency = freqInKHz*1000.0;
    self.phaseIncrement = 2*M_PI*self.frequency/[self.audioManager samplingRate];
    
}

// update input data array using fresh data from microphone
-(float*) getFreshData{

    [self.buffer fetchFreshData:self.arrayData withNumSamples:BUFFER_SIZE];
    return self.arrayData;
}

// gesture detection
-(NSString*) checkForMotion{

    // stores sum of 100 fft values from left of max
    int leftSum = 0;
    
    // stores sum of 100 fft values from right of max
    int rightSum = 0;
    
    // stores average of 100 fft values from left & right of max
    float leftAvg = 0,rightAvg = 0;
    
    // update the peak frequency
    [self getTopTwoFFTFrequencies];
    
    // count only the frequencies of magnitude greater than 20 decibels
    float thresholdMagnitute = 20;
    
    // only if current average is greater than previous average by 3, we should detect the gesture.
    float thresholdMagnitute1 = 3;
    
    // to count left & right 100 values
    for (int i= self.maxIndex-100; i< self.maxIndex+99; i++) {

        if (i < self.maxIndex - 1 && fabsf(self.fftMagnitude[i]) > thresholdMagnitute){
            leftSum = leftSum + fabsf(self.fftMagnitude[i]);
        }
        if (i > self.maxIndex + 1 && fabsf(self.fftMagnitude[i]) > thresholdMagnitute){
            rightSum = rightSum + fabsf(self.fftMagnitude[i]);
        }
    }

    // taking average
    leftAvg = leftSum/100;
    rightAvg = rightSum/100;

    // "Gesturing towards and away"
    if(rightAvg - self.rightAvg > thresholdMagnitute1 &&  leftAvg - self.leftAvg > thresholdMagnitute1){
        self.leftAvg = leftAvg;
        self.rightAvg = rightAvg;

        return @"Gesturing Towards and Away";
    }
    // "Gesturing Towards"
    if(rightAvg - self.rightAvg > thresholdMagnitute1){

        self.leftAvg = leftAvg;
        self.rightAvg = rightAvg;

        return @"Gesturing Towards";
    // "Gesturing Away"
    } else if(leftAvg - self.leftAvg > thresholdMagnitute1){

        self.leftAvg = leftAvg;
        self.rightAvg = rightAvg;

        return @"Gesturing Away";
    // "No Gesturing"
    }else{

        self.leftAvg = leftAvg;
        self.rightAvg = rightAvg;

        return @"No Gesturing";
    }
}

// getter of FFT data Magnitude, updates & sends
-(float*) getFFTData{
    
    [self.fftHelper performForwardFFTWithData:self.arrayData
               andCopydBMagnitudeToBuffer:self.fftMagnitude];
    
    return self.fftMagnitude;
}

// free the memmory
-(void) freeAllData{
    free(self.arrayData);
}

// get 2 largest magnitude FFT frequencies
-(void) getTopTwoFFTFrequencies{

    // to not detect frequencies within 50 hz, since delta frequency was around 5
    int window_size = 9;
    
    float maxMagnitude1=0,maxMagnitude2=0, windowMax=0;
    int maxFrequencyIndex1 = 0, maxFrequencyIndex2 = 0, windowMaxIndex=0;

    // search for largest frequency
    for(int i = 0; (i+window_size) < BUFFER_SIZE/2; i++){

        // calculating max value within the window & storing index
        windowMax = 0;
        for(int j=0;j<window_size;j++)
        {
            float currentFFTMagnetude = self.fftMagnitude[i+j];
            if(currentFFTMagnetude > windowMax){
                windowMax = currentFFTMagnetude;
                windowMaxIndex = i+j;
            }
        }
        
        // checking if max is in middle of the window
        if(i+window_size/2==windowMaxIndex)
        {
            // swap if window max is greater than max
            if(windowMax>maxMagnitude1)
            {
                maxMagnitude2 = maxMagnitude1;
                maxFrequencyIndex2 = maxFrequencyIndex1;

                maxMagnitude1 = windowMax;
                maxFrequencyIndex1 = windowMaxIndex;

            }
            // swap if window max is greater than second max
            else if(windowMax > maxMagnitude2 && windowMax <= maxMagnitude1){
                maxMagnitude2 = windowMax;
                maxFrequencyIndex2 = windowMaxIndex;
            }
        }
    }

    float f2 =  (maxFrequencyIndex1*DELTA_OF_FREQUENCY*2);
    float m2 = self.fftMagnitude[maxFrequencyIndex1];
    float m3=0,m1=0;
    if (!(maxFrequencyIndex1+1>BUFFER_SIZE/2))
    {
        m3 = self.fftMagnitude[maxFrequencyIndex1+1];
    }
    if (!(maxFrequencyIndex1-1<0)){
        m1 = self.fftMagnitude[maxFrequencyIndex1-1];
    }

    // using the formula to find peak
    self.fPeak1 = f2 + ((m3-m1)/( m3 - 2*m2 +m1)) * DELTA_OF_FREQUENCY/2;
    
    // storing max f index
    self.maxIndex = maxFrequencyIndex1;
    
    // to calculate second max frequency.

    f2 =  (maxFrequencyIndex2*DELTA_OF_FREQUENCY*2);
    m2 = self.fftMagnitude[maxFrequencyIndex2];


    m3=0,m1=0;
    if (!(maxFrequencyIndex2+1>BUFFER_SIZE/2))
    {
        m3 = self.fftMagnitude[maxFrequencyIndex2+1];
    }
    if (!(maxFrequencyIndex2-1<0)){
        m1 = self.fftMagnitude[maxFrequencyIndex2-1];
    }

    self.fPeak2 = f2 + ((m3-m1)/( m3 - 2*m2 +m1)) * DELTA_OF_FREQUENCY/2;
    
    // stores all time max frequency values
        if(self.fPeak1 > maxFreq1){
            maxFreq1 = self.fPeak1;
        }
        if(self.fPeak2 > maxFreq2){
            maxFreq2 = self.fPeak2;
        }
}

- (Novocaine*) getAudioManager{
    return self.audioManager;
}

- (NSString*) getPeak1{
    return [NSString stringWithFormat:@"Frequency 1 : %f", self.fPeak1];
}

-(NSString*) getPeak2{
    return [NSString stringWithFormat:@"Frequency 2 : %f", self.fPeak2];
}

- (NSString*) getMaxPeak1{
    return [NSString stringWithFormat:@"Frequency 1 : %f  |  %f", self.fPeak1, lockFreq1];
}

-(NSString*) getMaxPeak2{
    return [NSString stringWithFormat:@"Frequency 2 : %f  |  %f", self.fPeak2, lockFreq2];
}

// free the memory
-(void) removeFromMemory{
    
    free(self.arrayData);
    free(self.fftMagnitude);
    
    self.audioManager = nil;
    self.buffer = nil;
    self.fftHelper = nil;
    self.arrayData = nil;
    self.fftMagnitude = nil;
    
    self.phaseIncrement = 0;
    self.frequency = 0;
    self.fPeak1 = 0;
    self.fPeak2 = 0;
    
    maxFreq1 = 0.0;
    maxFreq2 = 0;
}

-(void) lockFrequency{
    lockFreq1 = self.fPeak1;
    lockFreq2 = self.fPeak2;
}

@end
