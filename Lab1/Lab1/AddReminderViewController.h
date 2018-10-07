//
//  AddReminderViewController.h
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderModel.h"

@protocol SaveRemiderInformationDelegate
    -(void)saveRemimderInformationInDatabaseAndUpdate:(ReminderModel *)reminderModel;
@end

@interface AddReminderViewController : UIViewController
@property (weak) id <SaveRemiderInformationDelegate> saveReminderDelegate;
@end
