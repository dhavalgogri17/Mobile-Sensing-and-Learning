//
//  ReminderModel.m
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "ReminderModel.h"
#import "DatabaseManager.h"


@interface ReminderModel ()
@property (strong,nonatomic) DatabaseManager * databaseInstance;

@property (nonatomic) NSInteger reminderId;
@property (strong,nonatomic) NSString* reminderTitle;
@property (strong,nonatomic) NSString* reminderDescription;
@property (strong,nonatomic) NSString* reminderTime;
@property (strong,nonatomic) NSString* reminderDate;
@property (strong,nonatomic) UIImage* reminderImage;
@property (strong,nonatomic) NSString* reminderIsDone;

@end

@implementation ReminderModel
-(void) setId:(NSInteger )rId{
    self.reminderId = rId;
}
-(void) setTitle:(NSString *)title{
    self.reminderTitle = title;
}
-(void) setDescription:(NSString *)description{
    self.reminderDescription = description;
}
-(void) setTime:(NSString *)time{
    self.reminderTime = time;
}
-(void) setDate:(NSString *)date{
    self.reminderDate = date;
}
-(void) setImage:(UIImage *)image{
    self.reminderImage = image;
}
-(void) setIsDone:(NSString *)isDone{
    self.reminderIsDone = isDone;
}


-(NSInteger) getID{return self.reminderId;
    
}
-(NSString*) getTitle{return _reminderTitle;
    
}
-(NSString*) getDescription{return _reminderDescription;
    
}
-(NSString*) getTime{return _reminderTime;
    
}
-(NSString*) getDate{return _reminderDate;
    
}
-(UIImage*) getImage{return _reminderImage;
    
}
-(NSString*) getIsDone{return _reminderIsDone;
    
}
@end
