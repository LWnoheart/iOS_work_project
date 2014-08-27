//
//  NSObject+fanshe.m
//  ios 类反射
//
//  Created by 李巍 on 13-3-15.
//  Copyright (c) 2013年 李巍. All rights reserved.
//

#import "NSObject+fanshe.h"
#import <objc/runtime.h>
@implementation NSObject (fanshe)

- (NSArray *)getPropertyList: (Class)clazz{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        
        [propertyArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertyArray;
}
//this method can get property's name to array and property's type to array
//the array of return have two array.
-(NSArray *)getPropertyListAndPropertyType:(Class)clazz
{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *propertyType = [NSMutableArray arrayWithCapacity:count];
    NSMutableDictionary *propertyForKey = [NSMutableDictionary dictionaryWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        
//        const char* propertyName1 = property_getName(properties[i]);
        const char *charStr = property_getAttributes(properties[i]);
        NSString *property = [NSString stringWithUTF8String:charStr];
        NSString *propertyName = [property substringFromIndex:[property rangeOfString:@"N,V"].location+3];
        [propertyNames addObject:propertyName];
        if ([[property substringFromIndex:1]hasPrefix:@"@"]) {
            [propertyType addObject:[[property substringFromIndex:3]substringToIndex:[property rangeOfString:@",&,N,V"].location-4]];
            [propertyForKey setValue:[[property substringFromIndex:3]substringToIndex:[property rangeOfString:@",&,N,V"].location-4] forKey:propertyName];
        }else if ([[property substringWithRange:NSMakeRange(1, 1)]isEqualToString:@"i"]){
            [propertyType addObject:@"int"];
            [propertyForKey setValue:@"int" forKey:propertyName];
        }else if ([[property substringWithRange:NSMakeRange(1, 1)]isEqualToString:@"d"]){
            [propertyType addObject:@"double"];
            [propertyForKey setValue:@"double" forKey:propertyName];
        }else{
            [propertyType addObject:@"error"];
            [propertyForKey setValue:@"error" forKey:propertyName];
        }
    }
    NSArray *array = [NSArray arrayWithObjects:propertyNames,propertyType,propertyForKey, nil];
    free(properties);
    return array;
}


-(NSArray *)getMethodList:(Class)clazz{
    u_int count;
    Method *method = class_copyMethodList(clazz, &count);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        SEL methodName = method_getName(method[i]);
        //const char *name = sel_getName(methodName);
        //[methodArray addObject:[NSString stringWithUTF8String:name]];
        [methodArray addObject:NSStringFromSelector(methodName)];
    }
    return methodArray;
}

//- (void)interceptClass:(Class)aClass beforeExecutingSelectorLooklikeName:(NSString *)seletorStr usingBlock:(aspect_block_t)block
//{
//    NSArray *array = [self getMethodList:aClass];
//    for (NSString *str in array) {
//        if ([str rangeOfString:seletorStr].length != 0 ) {
////            SEL seletor = sel_registerName([str UTF8String]);
//            SEL seletor = NSSelectorFromString(str);
//            [[AOPAspect instance] interceptClass:aClass beforeExecutingSelector:seletor usingBlock:block];
//        }
//    }
//}



//- (NSMutableDictionary *)serializeObject:(id)theObject
//{
//    NSString *className = NSStringFromClass([theObject class]);
//    
//    const char *cClassName = [className UTF8String];
//    
//    id theClass = objc_getClass(cClassName);
//    
//    unsigned int outCount, i;
//    
//    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
//    
//    NSMutableArray *propertyNames = [[NSMutableArray alloc] initWithCapacity:1];
//    
//    for (i = 0; i < outCount; i++) {
//        
//        objc_property_t property = properties[i];
//        
//        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
//        
//        [propertyNames addObject:propertyNameString];
//        
//        [propertyNameString release];
//        
//        NSLog(@"%s %s\n", property_getName(property), property_getAttributes(property));
//        
//    }
//    
//    NSMutableDictionary *finalDict = [[NSMutableDictionary alloc] initWithCapacity:1];
//    
//    for(NSString *key in propertyNames)
//    {
//        SEL selector = NSSelectorFromString(key);
//        id value = [theObject performSelector:selector];
//        
//        if (value == nil)
//        {
//            value = [NSNull null];
//        }
//        
//        [finalDict setObject:value forKey:key];
//    }
//    
//    [propertyNames release];
//    
////    NSString *retString = [[CJSONSerializer serializer] serializeDictionary:finalDict];
////    
////    [finalDict release];
//    
//    return finalDict;
//    
//}

@end
/*
 
 
 
 
 
 
 
 
 属性类型和相关函数
 属性（Property）类型定义了对描述属性的结构体objc_property的不透明的句柄。
 
 typedef struct objc_property *Property;
 您可以使用函数class_copyPropertyList和protocol_copyPropertyList来获得类（包括范畴类）或者协议类中的属性列表：
 
 objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
 objc_property_t *protocol_copyPropertyList(Protocol *proto, unsigned int *outCount)
 例如，有如下的类声明：
 
 @interface Lender : NSObject {
 float alone;
 }
 @property float alone;
 @end
 您可以象这样获得它的属性：
 
 id LenderClass = objc_getClass("Lender");
 unsigned int outCount;
 objc_property_t *properties = class_copyPropertyList(LenderClass, &outCount);
 您还可以通过property_getName函数获得属性的名字：
 
 const char *property_getName(objc_property_t property)
 函数class_getProperty和protocol_getProperty则在类或者协议类中返回具有给定名字的属性的引用：
 
 objc_property_t class_getProperty(Class cls, const char *name)
 objc_property_t protocol_getProperty(Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty)
 通过property_getAttributes函数可以获得属性的名字和@encode编码。关于类型编码的更多细节，参考“类型编码“一节；关于属性的类型编码，见“属性类型编码”及“属性特征的描述范例”。
 
 const char *property_getAttributes(objc_property_t property)
 综合起来，您可以通过下面的代码得到一个类中所有的属性。
 
 id LenderClass = objc_getClass("Lender");
 unsigned int outCount, i;
 objc_property_t *properties = class_copyPropertyList(LenderClass, &outCount);
 for (i = 0; i < outCount; i++) {
 objc_property_t property = properties;
 fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
 }
 
 
 
 
 
 
 
 
 //可能出现点击UIButton的时候被UITapGestureRecognizer识别,解决方案如下
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
 {
 if (touch.view == self.signatureBtn) return NO;
 if (touch.view == self.resignBtn) return NO;
 
 
 return YES;
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 */