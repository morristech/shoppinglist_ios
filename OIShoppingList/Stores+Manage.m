//
//  Stores+Manage.m
//  OIShoppingList
//
//  Created by Tian Hongyu on 13/7/12.
//  Copyright (c) 2012 OpenIntents. All rights reserved.
//
/**************
 This category adds methods to the generated class"Store", so that these methods won't be "erased" when regenarating the class
 *************/

#import "Stores+Manage.h"

@implementation Stores (Manage)

+(Stores*)getStoreWithName:(NSString*)name 
                    inList:(Lists*)list
    inManagedObjectContext:(NSManagedObjectContext*)context
{
    Stores* store = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Stores"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@ AND list_id = %@", name, list];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *storeArray = [context executeFetchRequest:request error:&error];
    
    if (!storeArray || ([storeArray count] > 1)) {
        // handle error
        NSLog(@"error occur");
    } else if (![storeArray count]) {
        store = [NSEntityDescription insertNewObjectForEntityForName:@"Stores"
                                             inManagedObjectContext:context];
        store.name = name;
        store.list_id = list;    
        store.created= [NSDate date];
        store.modified = [NSDate date];
        NSLog(@"added new Store =====%@", [store description]);
    } else {
        store  = [storeArray lastObject];
        NSLog(@"existed Store:===>\nR%@", [store description]);
        
    }
    
    return store;
    
}
-(NSNumber*)priceForItem:(Items*)item
{
    Itemsstores * itemsstore = nil;
    for (itemsstore in self.itemstores_id) {
        if (itemsstore.item_id == item) {
            return itemsstore.price;
        }
    }
    return nil;
}

-(NSDictionary*) subtotalForItemsAndCalculatedItemsWithinStore
{
    double subtotal=0;
    int availablePrice = 0;
    int count =0;
    for (Itemsstores*itemsstore in self.itemstores_id) {
        Contains* contain = nil;
        for (contain in itemsstore.item_id.contains_id) {
            if ([contain.item_id isEqual:itemsstore.item_id]) {
                count = [contain.quantity intValue];
            }
            if ([contain isChecked]) {
                count = 0;
            }
        }
        
        if(itemsstore.price)
        {
            subtotal = subtotal + (count* [itemsstore.price doubleValue]);
            availablePrice++;
        }
    }
    NSArray* resultToAdd = [[NSArray alloc]initWithObjects:
                        [NSNumber numberWithDouble:subtotal],
                        [NSNumber numberWithInt:availablePrice],
                            self.name,nil ];
    NSArray* keysForResults = [[NSArray alloc] initWithObjects: @"subtotal",@"availablePrice",@"name" ,nil ];
    return [[NSDictionary alloc]initWithObjects:resultToAdd forKeys:keysForResults];
}

@end
