//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <CoreML/CoreML.h>

// export non-documented setProfilingOptions:
@interface MLModelConfiguration (helper)
- (id) setProfilingOptions:(long long) p;
@end

// export non-documented program:
@interface MLModel (helper)
- (id) program;
@end

// export MLE5Engine and programLibrary
@interface MLE5Engine
- (id) programLibrary;
@end

// hack: becasue we cannot access MLE5ProgramLibrary
@interface NSObject()
- (NSDictionary *) segmentationAnalyticsAndReturnError:(id *) error;
@end
