//
//  DateUtil.h
//  SportsContact
//
//  Created by bobo on 14-7-19.
//  Copyright (c) 2014年 CAF. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926



@interface DateUtil : NSObject


// 日期选择器
+ (UIDatePicker *)datePicker;


/**
 *  格式化时间
 *  xx年xx月xx日
 *
 *  @param date 时间啊
 *
 *  @return 格式化之后的时间字符串
 */
+ (NSString *)formatedValidityDate:(NSDate *)date;

/**
 *  格式化时间
 *
 *  @param date      时间
 *  @param aSeparate 年月日的分隔符
 *
 *  @return 格式化之后的时间字符串
 */
+ (NSString *)formatedDate:(NSDate *)date bySeparate:(NSString *)aSeparate;

/**
 *  格式化时间  yyyy-MM-dd-HH:mm:ss
 *
 *  @param date        时间
 *  @param aDateFormat yyyy-MM-dd-HH:mm:ss
 *
 *  @return 格式化之后的时间字符串
 */
+ (NSString *)formatedDate:(NSDate *)date byDateFormat:(NSString *)aDateFormat;

/**
 *  格式化时间字符串  yyyy-MM-dd-HH:mm:ss
 *
 *  @param string      时间字符串
 *  @param aDateFormat yyyy-MM-dd-HH:mm:ss
 *
 *  @return 格式化之后的时间
 */
+ (NSDate *)formatedString:(NSString *)string byDateFormat:(NSString *)aDateFormat;

/**
 *  格式化时间
 *
 *  @param aTime     毫秒时间
 *  @param aSeparate 年月日的分隔符
 *
 *  @return 格式化之后的时间字符串
 */
+ (NSString *)formatedTimeInMillisecond:(long long)aTime bySeparate:(NSString *)aSeparate;

// 时长 %ld:%02ld:%02ld
+ (NSString *)timeDescriptionOfTimeInterval:(NSTimeInterval)timeInterval;

// 是否是同一天
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

// 当前时间
+ (NSTimeInterval)curTime;

// 当前时间毫秒级
+ (long long)curTimeMillisecond;

// 当前小时
+ (NSInteger)curHour;






@end

@interface NSDate (Utilities)
+ (NSCalendar *) currentCalendar; // avoid bottlenecks

// Relative dates from the current date
+ (NSDate *) dateFromServer;
+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;
+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours;
+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours;
+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes;
+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes;

// Short string utilities
- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle;
- (NSString *) stringWithFormat: (NSString *) format;
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;

- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;

- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;

- (BOOL) isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isNextMonth;
- (BOOL) isLastMonth;

- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;

- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;

- (BOOL) isInFuture;
- (BOOL) isInPast;

// Date roles
- (BOOL) isTypicallyWorkday;
- (BOOL) isTypicallyWeekend;

// Adjusting dates
- (NSDate *) dateByAddingYears: (NSInteger) dYears;
- (NSDate *) dateBySubtractingYears: (NSInteger) dYears;
- (NSDate *) dateByAddingMonths: (NSInteger) dMonths;
- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths;
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;

// Date extremes
- (NSDate *) dateAtStartOfDay;
- (NSDate *) dateAtEndOfDay;

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (NSInteger) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

// Decomposing dates
@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger week;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;








@end