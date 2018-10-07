//
//  ReminderModel.h
//  Lab1
//
//  Created by Dhaval Gogri on 9/5/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ReminderModel : NSObject
-(void) setId:(NSInteger)reminderId;
-(void) setTitle:(NSString*)title;
-(void) setDescription:(NSString*)description;
-(void) setTime:(NSString*)time;
-(void) setDate:(NSString*)date;
-(void) setImage:(UIImage*)image;
-(void) setIsDone:(NSString*)isDone;
-(NSInteger) getId;
-(NSString*) getTitle;
-(NSString*) getDescription;
-(NSString*) getTime;
-(NSString*) getDate;
-(UIImage*) getImage;
-(NSString*) getIsDone;
@end
