//
//  DisplayReminderInformationViewController.m
//  Lab1
//
//  Created by Dhaval Gogri on 9/6/18.
//  Copyright © 2018 Dhaval Gogri. All rights reserved.
//

#import "DisplayReminderInformationViewController.h"

@interface DisplayReminderInformationViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UILabel *labelViewTitle;
@property (strong, nonatomic) UILabel *labelViewDescription;
@property (strong, nonatomic) UILabel *labelViewDate;
@property (strong, nonatomic) UILabel *labelViewTime;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end


@implementation DisplayReminderInformationViewController


-(UILabel*)labelViewTitle{
    
    if(!_labelViewTitle)
        _labelViewTitle = [[UILabel alloc] init];
    return _labelViewTitle;
}

-(UILabel*)labelViewDescription{
    
    if(!_labelViewDescription)
        _labelViewDescription = [[UILabel alloc] init];
    return _labelViewDescription;
}

-(UILabel*)labelViewDate{
    
    if(!_labelViewDate)
        _labelViewDate = [[UILabel alloc] init];
    return _labelViewDate;
}

-(UILabel*)labelViewTime{
    
    if(!_labelViewTime)
        _labelViewTime = [[UILabel alloc] init];
    return _labelViewTime;
}

-(UIImageView*)imageView{
    
    if(!_imageView)
        _imageView = [[UIImageView alloc] init];
    return _imageView;
}


// created the whole view programmatically
- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.labelViewTitle.frame = CGRectMake(16,16,screenWidth - 32,40);
    self.labelViewTitle.numberOfLines = 0;
    self.labelViewTitle.text = [self.reminderModel getTitle];
    [self.labelViewTitle sizeToFit];
    [self.scrollView addSubview:self.labelViewTitle];
    
    
    
    self.labelViewDescription.frame = CGRectMake(16,self.labelViewTitle.frame.origin.y + self.labelViewTitle.frame.size.height + 20,screenWidth - 32, 44);
    self.labelViewDescription.numberOfLines = 0;
    self.labelViewDescription.text = [self.reminderModel getDescription];
    [self.labelViewDescription sizeToFit];
    [self.scrollView addSubview:self.labelViewDescription];
    
    
    self.labelViewDate.frame = CGRectMake(16,self.labelViewDescription.frame.origin.y + self.labelViewDescription.frame.size.height + 20,screenWidth - 32, 44);
    self.labelViewDate.numberOfLines = 0;
    self.labelViewDate.text = [self.reminderModel getDate];
    [self.labelViewDate sizeToFit];
    [self.scrollView addSubview:self.labelViewDate];

    
    
    self.labelViewTime.frame = CGRectMake(16,self.labelViewDate.frame.origin.y + self.labelViewDate.frame.size.height + 20,screenWidth - 32, 44);
    self.labelViewTime.numberOfLines = 0;
    self.labelViewTime.text = [self.reminderModel getTime];
    [self.labelViewTime sizeToFit];
    [self.scrollView addSubview:self.labelViewTime];
    
    
    
    self.imageView.frame = CGRectMake(16,self.labelViewTime.frame.origin.y + self.labelViewTime.frame.size.height + 20,screenWidth - 32, screenWidth - 32);
    self.imageView.image = [self.reminderModel getImage];
    [self.scrollView addSubview:self.imageView];
    
    int heightScroll = self.labelViewTitle.frame.size.height + self.labelViewDescription.frame.size.height + self.labelViewDate.frame.size.height + self.labelViewTime.frame.size.height + self.imageView.frame.size.height + 100;
    self.scrollView.contentSize = CGSizeMake(screenWidth, heightScroll);
    self.scrollView.delegate = self;
    
}
@end
