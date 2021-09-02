//
//  ConnectionTest.m
//  NYCSchoolsTests
//
//  Created by Hanz Meyer on 9/1/21.
//

#import <XCTest/XCTest.h>

@interface HealthyLifestyleTests : XCTestCase

@end

@implementation HealthyLifestyleTests


- (void)testExample
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    /*
     NOTE:
     A NSURLSession object need not have a delegate.
     If no delegate is assigned, when you create tasks in that session, you must provide a completion handler block to obtain the data.
     Completion handler blocks are primarily intended as an alternative to using a custom delegate.
     If you create a task using a method that takes a completion handler block, the delegate methods for response and data delivery are not called.
     */
    
    /* NOTE:
     Test is running on the main queue and request is running asynchronously: the test will not capture the events in the completion block.
     Use a semaphore or dispatch group to make the request synchronous
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSURL *url = [NSURL URLWithString:@"https://data.cityofnewyork.us/resource/s3k6-pzi2.json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse.statusCode;
        if(statusCode != 200)
        {
            NSLog(@" *** Error getting %@, HTTP status code %li", url, (long)statusCode);
            return;
        }
            
        NSLog(@" *** Data received:     %@", data);
        NSLog(@" *** Response received: %ld", (long)statusCode);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        //NSLog(@" *** JSON Data: %@", json);
        if (json.count > 0)
        {
            NSLog(@" *** JSON Data: %@", json);
//            NSLog(@" *** JSON Key-results count: %lu", (unsigned long)[[json objectForKey:@"results"] count]); // Log results  count.
//            NSLog(@"=============================");
//
//            for (int x = 0; x < [[[json objectForKey:@"results"] objectForKey:@"books"] count]; x++)
//            {
//                //NSLog(@" *** JSON Key-results: %@", [[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x]); // Log all books.
//                NSLog(@" *** JSON Key-results: Author:      %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"author"]);         // Log all Authors.
//                NSLog(@" *** JSON Key-results: Image:       %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"book_image"]);     // Log all Book Images.
//                NSLog(@" *** JSON Key-results: Contributor: %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"contributor"]);    // Log all Contributors.
//                NSLog(@" *** JSON Key-results: Description: %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"description"]);    // Log all Descriptions.
//                NSLog(@" *** JSON Key-results: Publisher:   %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"publisher"]);      // Log all Publishers.
//                NSLog(@" *** JSON Key-results: Rank:        %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"rank"]);           // Log all Ranks.
//                NSLog(@" *** JSON Key-results: Title:       %@", [[[[json objectForKey:@"results"] objectForKey:@"books"] objectAtIndex:x] objectForKey:@"title"]);          // Log all Titles.
//                NSLog(@"===\n\n\n===");
//                // Get Best Sellers Date & Convert to Date Format
//            }
        }
        

        // when all done, signal the semaphore
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];

    long rc = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 60.0 * NSEC_PER_SEC));
    XCTAssertEqual(rc, 0, @"network request timed out");
}

@end
