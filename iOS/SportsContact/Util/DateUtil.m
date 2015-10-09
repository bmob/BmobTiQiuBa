//
//  DateUtil.m
//  SportsContact
//
//  Created by bobo on 14-7-19.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import "DateUtil.h"
#import <BmobSDK/Bmob.h>
#import "TimeManager.h"
// Thanks, AshFurrow
static const unsigned componentFlags = (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit);

@implementation DateUtil


+ (UIDatePicker *)datePicker
{
    UIDatePicker *dataPicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    
    // 日期模式
    [dataPicker setDatePickerMode:UIDatePickerModeDate];
    
    // 中文显示
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dataPicker setLocale:locale];
    
    //定义最小最大日期
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents* compMin = [calendar components:unitFlags fromDate:[NSDate date]];
    [compMin setYear:compMin.year-60];
    NSDate *minDate =[calendar dateFromComponents:compMin];
    [dataPicker setMinimumDate:minDate];
    
    NSDateComponents* compMax = [calendar components:unitFlags fromDate:[NSDate date]];
    [compMax setYear:compMax.year-18];
    NSDate *maxDate =[calendar dateFromComponents:compMax];
    [dataPicker setMaximumDate:maxDate];
    
    // 默认日期
    [compMax setMonth:1];
    [compMax setDay:1];
    NSDate *defaultDate = [calendar dateFromComponents:compMax];
    [dataPicker setDate:defaultDate];
    
    return dataPicker;
}

+ (NSString *)formatedChatDate:(NSDate *)date
{
    NSString *dateString = nil;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* curComp = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents* comp = [calendar components:unitFlags|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
    
    if (curComp.year == comp.year)
    {
        if (curComp.month == comp.month && curComp.day - comp.day < 3)
        {
            if (curComp.day == comp.day)
            {
                dateString = [NSString stringWithFormat:@"%02ld:%02ld",(long)comp.hour,(long)comp.minute];
            }
            else if (curComp.day - comp.day == 1)
            {
                dateString = [NSString stringWithFormat:@"昨天 %@",[self _timeOfhour:comp.hour]];
            }
            else if (curComp.day - comp.day == 2)
            {
                dateString = [NSString stringWithFormat:@"前天 %@",[self _timeOfhour:comp.hour]];
            }
        }
        else
        {
            dateString = [NSString stringWithFormat:@"%ld月%ld日",(long) comp.month, (long)comp.day];
        }
    }
    else
    {
        dateString = [NSString stringWithFormat:@"%ld年%ld月%ld日", (long)comp.year,(long) comp.month,(long) comp.day];
    }
    
    return dateString;
}

+ (NSString *)formatedValidityDate:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%ld年%ld月%ld日",(long)comp.year, (long)comp.month,(long) comp.day];
}

+ (NSString *)formatedTimeInMillisecond:(long long)aTime bySeparate:(NSString *)aSeparate
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:aTime/1000];
    return [self formatedDate:date bySeparate:aSeparate];
}

+ (NSString *)formatedDate:(NSDate *)date byDateFormat:(NSString *)aDateFormat
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:aDateFormat];
    formater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_GMT"];
    return [formater stringFromDate:date];
}

+ (NSDate *)formatedString:(NSString *)string byDateFormat:(NSString *)aDateFormat
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:aDateFormat];
    formater.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    return [formater dateFromString:string];
}

+ (NSString *)formatedDate:(NSDate *)date bySeparate:(NSString *)aSeparate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%ld%@%02ld%@%02ld",(long)comp.year,aSeparate, (long)comp.month,aSeparate,(long) comp.day];
}

+ (NSString *)_timeOfhour:(NSInteger)aHour
{
    if (aHour < 7)
    {
        return @"凌晨";
    }
    else if (aHour < 12)
    {
        return @"上午";
    }
    else if(aHour < 19)
    {
        return @"下午";
    }else{
        return @"晚上";
    }
}

+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSDateComponents *components = [self.class componetsWithTimeInterval:timeInterval];
    NSInteger roundedSeconds = lround(timeInterval - (components.hour * 60 * 60) - (components.minute * 60));
    
    if (components.hour > 0)
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)roundedSeconds];
    
    else
        return [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)roundedSeconds];
}

+ (NSDateComponents *)componetsWithTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:date1];
    
    unsigned int unitFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    return [calendar components:unitFlags
                       fromDate:date1
                         toDate:date2
                        options:0];
}

+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSTimeInterval)curTime
{
    return [[NSDate date] timeIntervalSince1970];
}

+ (long long)curTimeMillisecond
{
    return [self curTime] *1000;
}

+ (NSInteger)curHour
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comp = [calendar components:NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger hour = comp.hour;
    return hour;
}












@end


@implementation NSDate (Utilities)

// Courtesy of Lukasz Margielewski
// Updated via Holger Haenisch
+ (NSCalendar *) currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

#pragma mark - Relative Dates

+ (NSDate *)dateFromServer
{
//    //获取服务器时间
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    //设置时区
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
//    //时间格式
////    yyyy-MM-dd-HH:mm:ss
//    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    
    TimeManager *defaultManager = [TimeManager defaultTimeManger];
    
    if (defaultManager.distance == 0 && !defaultManager.askedServerTime ) {
        NSString *serverTimeString = [[Bmob getServerTimestamp] description];
        if (serverTimeString && serverTimeString.length != 0) {
            NSTimeInterval serverTime = [serverTimeString doubleValue];
            defaultManager.distance = serverTime - [[NSDate date] timeIntervalSince1970];
            defaultManager.askedServerTime = YES;
            NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:serverTime];
            return serverDate;
        }else{
            return [NSDate date];
        }
        
    }else{
        NSTimeInterval serverTime = defaultManager.distance + [[NSDate date] timeIntervalSince1970];
        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:serverTime];
        return serverDate;
    }
    
    
    
    //调用获取服务器时间接口，返回的是时间戳
//    NSString  *timeString = [Bmob getServerTimestamp];
    //时间戳转化成时间

    
}

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

#pragma mark - String Properties
- (NSString *) stringWithFormat: (NSString *) format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *) shortString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *) shortTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *) shortDateString
{
    return [self stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *) mediumString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *) mediumTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *) mediumDateString
{
    return [self stringWithDateStyle:NSDateFormatterMediumStyle  timeStyle:NSDateFormatterNoStyle];
}

- (NSString *) longString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *) longTimeString
{
    return [self stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *) longDateString
{
    return [self stringWithDateStyle:NSDateFormatterLongStyle  timeStyle:NSDateFormatterNoStyle];
}



#pragma mark - Comparing Dates

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	NSDateComponents *components2 = [[NSDate currentCalendar] components:componentFlags fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if (components1.week != components2.week) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (abs((int)[self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

// Thanks Marcin Krzyzanowski, also for adding/subtracting years and months
- (BOOL) isLastMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateBySubtractingMonths:1]];
}

- (BOOL) isNextMonth
{
    return [self isSameMonthAsDate:[[NSDate date] dateByAddingMonths:1]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [[NSDate currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
	
	return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}


#pragma mark - Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (NSDate *) dateByAddingYears: (NSInteger) dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingYears: (NSInteger) dYears
{
    return [self dateByAddingYears:-dYears];
}

- (NSDate *) dateByAddingMonths: (NSInteger) dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
	return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
	return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
	return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
	NSDateComponents *dTime = [[NSDate currentCalendar] components:componentFlags fromDate:aDate toDate:self options:0];
	return dTime;
}

#pragma mark - Extremes

- (NSDate *) dateAtStartOfDay
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [[NSDate currentCalendar] dateFromComponents:components];
}

// Thanks gsempe & mteece
- (NSDate *) dateAtEndOfDay
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	components.hour = 23; // Thanks Aleksey Kononov
	components.minute = 59;
	components.second = 59;
	return [[NSDate currentCalendar] dateFromComponents:components];
}

#pragma mark - Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) hoursAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:anotherDate options:0];
    return components.day;
}

#pragma mark - Decomposing Dates

- (NSInteger) nearestHour
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * 30;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	NSDateComponents *components = [[NSDate currentCalendar] components:NSHourCalendarUnit fromDate:newDate];
	return components.hour;
}

- (NSInteger) hour
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.hour;
}

- (NSInteger) minute
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.minute;
}

- (NSInteger) seconds
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.second;
}

- (NSInteger) day
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.day;
}

- (NSInteger) month
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.month;
}

- (NSInteger) week
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.week;
}

- (NSInteger) weekday
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.weekday;
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.weekdayOrdinal;
}

- (NSInteger) year
{
	NSDateComponents *components = [[NSDate currentCalendar] components:componentFlags fromDate:self];
	return components.year;
}









@end