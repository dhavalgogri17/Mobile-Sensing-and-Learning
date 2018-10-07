//
//  SettingsViewController.m
//  Lab1
//
//  Created by Dhaval Gogri on 9/3/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchView;
@property (weak, nonatomic) IBOutlet UILabel *labelViewListGrid;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@property (weak, nonatomic) IBOutlet UILabel *labelViewStepper;
@property (nonatomic) NSTimer *_timer;
- (void)_timerFired:(NSTimer *)timer;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *buttonDonate;
@property (nonatomic) float sliderValue;
@property (weak, nonatomic) IBOutlet UILabel *labelViewSlider;
@end

@implementation SettingsViewController

-(float)sliderValue{
    if(!_sliderValue)
        _sliderValue = 0;
    
    return _sliderValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelViewListGrid.text = @"if ON --> ListView \nif OFF --> GridView";
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *currentLevelKey = @"isListView";
    if ([preferences objectForKey:currentLevelKey] == nil)
    {
        [self.switchView setOn:true];
    }
    else
    {
        [self.switchView setOn:[preferences boolForKey:currentLevelKey]];
    }
    
    
    NSString *currentLevelKey2 = @"stepperValue";
    if ([preferences objectForKey:currentLevelKey2] == nil)
    {
        [self.stepper setValue:5];
    }
    else
    {
        [self.stepper setValue:[preferences doubleForKey:currentLevelKey2]];
    }
    
    
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:[self.stepper value]];
    NSString *text = [NSString stringWithFormat:@"Reminders will sync every %@ minute to the server",[myDoubleNumber stringValue]];
    self.labelViewStepper.text = text;
    
    self.labelViewSlider.text = [NSString stringWithFormat:@"You have selected $ %f to donate",self.sliderValue];
    
    
    
}

- (void)_timerFired:(NSTimer *)timer {
    NSLog(@"Timer Fired");
    [self showAlertBox:@"Reminders Synced in Server"];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// save change value of switch in preference
- (IBAction)onValueChanged:(UISwitch *)sender {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *currentLevelKey = @"isListView";
    BOOL currentLevel = true;
    if([sender isOn]){
        currentLevel = true;
    }
    else{
        currentLevel = false;
    }
    [preferences setBool:currentLevel forKey:currentLevelKey];
    const BOOL didSave = [preferences synchronize];
}

// save change value of stepper in preference
- (IBAction)onStepperValueChanged:(UIStepper *)sender {
    NSNumber *myDoubleNumber = [NSNumber numberWithDouble:[sender value]];
    NSString *text = [NSString stringWithFormat:@"Reminders will sync every %@ minute to the server",[myDoubleNumber stringValue]];
    self.labelViewStepper.text = text;
    float result = [myDoubleNumber floatValue];
    
    [self startTimer:result];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *currentLevelKey = @"stepperValue";
    BOOL currentLevel = true;
    [preferences setDouble:[sender value] forKey:currentLevelKey];
    const BOOL didSave = [preferences synchronize];
}

-(void) startTimer:(float)interval{
    if ([self._timer isValid]) {
        [self._timer invalidate];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self._timer = [NSTimer scheduledTimerWithTimeInterval:interval*60
                                                       target:self
                                                     selector:@selector(_timerFired:)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self._timer forMode:NSRunLoopCommonModes];
    });
    
}

// demonstarting working of timer, adn stepper
-(void)showAlertBox:(NSString*)message{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [alert dismissViewControllerAnimated:true completion:nil];
                               }];
    
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

// demomnstrating working of slider
- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.sliderValue = [sender value];
    self.labelViewSlider.text = [NSString stringWithFormat:@"You have selected $ %f to donate",self.sliderValue];
}


- (IBAction)donateMoney:(UIButton *)sender {
    NSString *message = [NSString stringWithFormat:@"Thank you for donating $ %f",self.sliderValue];
    [self showAlertBox:message];
}


@end
