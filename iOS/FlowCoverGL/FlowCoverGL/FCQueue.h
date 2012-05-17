/**
 * @brief Header file of the DataCache interface.
 * @author Jackey Cheung
 */
#import <Foundation/Foundation.h>


/**
 * @brief Implementing a basic FIFO queue of objects.
 */
@interface FCQueue : NSObject
{
  /**
   * The backing array to store data.
   */
  NSMutableArray *queue;  
}

/**
 * @brief Initialize the queue to the specified size.
 * @param[in] size Size to initialize to.
 * @returns @c id to the newly created object.
 */
- (id)initWithSize:(int)size;

/**
 * @brief Initialize the queue to the specified size.
 * @param[in] size Size to initialize to.
 * @returns @c id to the newly created object.
 */
- (id)initWithSize:(int)size;

/**
 * @brief Adds the given object to the end of queue.
 * @param[in] object The object to be added to the queue.
 */
- (void)enqueue:(id)object;
/**
 * @brief Returns the first object in the queue, and remove it from the queue.
 */
- (id)dequeue;
/**
 * @brief Check whether the queue has any data.
 * @returns Returns true if the queue contains nothing, otherwise false.
 */
- (BOOL)isEmpty;
/**
 * @brief Remove everything from the queue.
 */
- (void)clear;


@end
