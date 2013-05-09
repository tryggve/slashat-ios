//
//  SlashatCountdownViewController.m
//  Slashat
//
//  Created by Johan Larsson on 2013-03-26.
//  Copyright (c) 2013 Johan Larsson. All rights reserved.
//

#import "SlashatCountdownViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface SlashatCountdownViewController ()

@end

@implementation SlashatCountdownViewController

NSDate *laterDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    laterDate = [self getNextSlashatDate];
    [self setCountdownStartValue:laterDate];
    
    // __attributes__((unused)) is to get rid of the "unused variable" warning in xcode
    NSTimer *timer __attribute__((unused)) = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountdown:) userInfo:nil repeats:YES];
}

- (NSDate *)getNextSlashatDate
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    
    [nowComponents setWeekday:3]; //Tuesday
    [nowComponents setWeek: [nowComponents week] + 1]; //Next week
    [nowComponents setHour:19]; //19.30
    [nowComponents setMinute:30];
    [nowComponents setSecond:0];
    
    NSDate *comingTuesday = [gregorian dateFromComponents:nowComponents];
    return comingTuesday;
}

- (void)updateCountdown:(NSTimer *)timer
{
    [self setCountdownStartValue:laterDate];
}

- (void)setCountdownStartValue:(NSDate *)destinationDate
{
    int differenceInSeconds = (int)[destinationDate timeIntervalSinceNow];
    
    int days = (int)((double)differenceInSeconds/(3600.0*24.00));
    int diffDay=differenceInSeconds-(days*3600*24);
    int hours=(int)((double)diffDay/3600.00);
    int diffMin=diffDay-(hours*3600);
    int minutes=(int)(diffMin/60.0);
    int seconds=diffMin-(minutes*60);
        
    [self setCountdownValuesWithDays:days hours:hours minutes:minutes seconds:seconds];
}

- (void)setCountdownValuesWithDays:(int)days hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
    [self setCountdownItem:days tag1:1 tag2:2];
    [self setCountdownItem:hours tag1:3 tag2:4];
    [self setCountdownItem:minutes tag1:5 tag2:6];
    [self setCountdownItem:seconds tag1:7 tag2:8];
}

- (void)setCountdownItem:(int)value tag1:(int)tag1 tag2:(int)tag2
{
    NSString *valueString = [NSString stringWithFormat:@"%02d", value];
    UILabel *valueLabel1 = (UILabel *)[self.view viewWithTag:tag1];
    UILabel *valueLabel2 = (UILabel *)[self.view viewWithTag:tag2];
    
    NSString *oldValueLabelString1 = valueLabel1.text;
    NSString *oldValueLabelString2 = valueLabel2.text;
    
    valueLabel1.text = [valueString substringToIndex:1];
    valueLabel2.text = [valueString substringFromIndex:1];
    
    if (![oldValueLabelString1 isEqualToString:[valueString substringToIndex:1]]) {
        [self animateLabel:valueLabel1];
    }
    
    if (![oldValueLabelString2 isEqualToString:[valueString substringFromIndex:1]]) {
        [self animateLabel:valueLabel2];
    }
}

- (void)animateLabel:(UILabel *)label
{
    [CATransaction begin];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.removedOnCompletion = YES;
    animationGroup.duration = 0.85;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2.70];
    
    animationGroup.animations = [NSArray arrayWithObjects:fadeAnimation, scaleAnimation, nil];
    
    UILabel *duplicateLabel = [self duplicateLabel:label];
    [self.view addSubview:duplicateLabel];
    
    [CATransaction setCompletionBlock:^{[duplicateLabel removeFromSuperview];}];
    
    duplicateLabel.layer.bounds = duplicateLabel.frame;
    
    duplicateLabel.layer.anchorPoint = CGPointMake(.42,.5);
    duplicateLabel.layer.contentsGravity = @"center";
    duplicateLabel.layer.opacity = 0.5;
    duplicateLabel.backgroundColor = [UIColor clearColor];
        
    [duplicateLabel.layer addAnimation:animationGroup forKey:@"fadeAnimation"];
    
    [CATransaction commit];
}

- (UILabel *)duplicateLabel:(UILabel *)label
{
    UILabel *duplicate = [[UILabel alloc] initWithFrame:label.frame];
    duplicate.text = label.text;
    duplicate.textColor = label.textColor;
    duplicate.backgroundColor = label.backgroundColor;
    duplicate.font = label.font;
    return duplicate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end