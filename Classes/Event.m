
/*
     File: Event.m
 Abstract: A Core Data managed object class to represent an event containing geographical coordinates and a time stamp.
 An event has a to-many relationship to Tag which represents tags associated with the event.
  Version: 1.1
 
 
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "Event.h"
#import "Tag.h"

@implementation Event 

@dynamic name;
@dynamic creationDate;
@dynamic latitude;
@dynamic longitude;
@dynamic tags;
@dynamic when;
@dynamic where;
@dynamic how;
@dynamic what;
@dynamic expired;
@dynamic geoFencingPreference;
@dynamic frequency;
@dynamic inAdvance;
@dynamic priority;


@end
