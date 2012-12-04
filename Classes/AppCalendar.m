//
//  AppCalendar.m
//  GoodTimesTVGuide
//
//  Created by Ray Wenderlich on 10/5/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "AppCalendar.h"

static EKEventStore* eStore = NULL;
static EKReminder* eReminder = NULL;

@implementation AppCalendar

+(EKEventStore*)eventStore
{
    //keep a static instance of eventStore
    if (!eStore) {
        eStore = [[EKEventStore alloc] init];
    }
    return eStore;
}

+(EKCalendar*)createAppCalendar
{
    EKEventStore *store = [self eventStore];
    
    //1 fetch the local event store source
    EKSource* localSource = nil;    
    for (EKSource* src in store.sources) {
        if (src.sourceType == EKSourceTypeCalDAV) {
            localSource = src;
        }
        if (src.sourceType == EKSourceTypeLocal && localSource==nil) {
            localSource = src;
        }
    }    
    if (!localSource) return nil;
    
    //2 create a new calendar
    EKCalendar* newCalendar = [EKCalendar calendarWithEventStore: store];
    newCalendar.title = kAppCalendarTitle;
    newCalendar.source = localSource;
    newCalendar.CGColor = [[UIColor colorWithRed:0.8 green:0.251 blue:0.6 alpha:1] /*#cc4099*/ CGColor];
    
    //3 save the calendar in the event store
    NSError* error = nil;
    [store saveCalendar: newCalendar commit:YES error:&error];
    if (!error) {
        return nil;
    }
    
    //4 store the calendar id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:newCalendar.calendarIdentifier forKey:@"appCalendar"];
    [prefs synchronize];
    
    return newCalendar;
}

+(EKCalendar*)calendar
{
    //1
    EKCalendar* result = nil;
    EKEventStore *store = [self eventStore];
    
    //2 check for a persisted calendar id
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *calendarId = [prefs stringForKey:@"appCalendar"];
	
    //3
    if (calendarId && (result = [store calendarWithIdentifier: calendarId]) ) {
        return result;
    }
    
    //4 check for a calendar with the same name
    for (EKCalendar* cal in store.calendars) {
        if ([cal.title compare: kAppCalendarTitle]==NSOrderedSame) {
            if (cal.immutable == NO) {
                [prefs setValue:cal.calendarIdentifier forKey:@"appCalendar"];
                [prefs synchronize];
                return cal;
            }
        }
    }
    
    //5 if no calendar is found whatsoever, create one
    result = [self createAppCalendar];
    
    //6
    return result;
}

+(EKReminder *)reminder
{
    
    if (!eReminder) {
        eReminder = [EKReminder
                     reminderWithEventStore:[self eventStore]];
    }
    
    return eReminder;
    
        
//    reminder.title = _locationText.text;
    
    
    
//    EKStructuredLocation *location = [EKStructuredLocation
//                                      locationWithTitle:@"Current Location"];
//    
//    location.geoLocation = [locations lastObject];
    
//    EKAlarm *alarm = [[EKAlarm alloc]init];
    
//    alarm.structuredLocation = location;
    
//    alarm.proximity = EKAlarmProximityLeave;
    
//    [reminder addAlarm:alarm];
    
//    NSError *error = nil;
//    
//    [[self eventStore] saveReminder:reminder commit:YES error:&error];
//    
//    if (error)
//        NSLog(@"Failed to set reminder: %@", error);
    
    

}
@end
