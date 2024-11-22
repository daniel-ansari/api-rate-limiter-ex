# Rate Limiter Implementations in Elixir  

This project demonstrates three rate-limiting algorithms: **Fixed Window**, **Sliding Window**, and **Token Bucket**. Each algorithm enforces a limit on API requests per user within a specified time window.  

## Algorithms Overview  

### 1. Fixed Window Algorithm  
**Description**:  
- The time is divided into fixed intervals or "windows."  
- Each user can make a maximum of `N` requests per window.  
- Once the limit is reached, all requests are blocked until the next window starts.  

**Pros**:  
- Simple to implement.  
- Efficient in memory and computation.  

**Cons**:  
- Users can send requests in bursts at the boundary of two windows.  

---

### 2. Sliding Window Algorithm  
**Description**:  
- Improves upon the Fixed Window by tracking requests with finer granularity.  
- Instead of resetting the count entirely after a window, it considers recent requests in a "sliding" time frame.  

**Pros**:  
- Smooths out request patterns.  
- Avoids bursts at window boundaries.  

**Cons**:  
- More complex to implement and requires additional computation.  

---

### 3. Token Bucket Algorithm  
**Description**:  
- Tokens are generated at a fixed rate and stored in a "bucket."  
- A user can make a request only if tokens are available.  
- If no tokens are left, the request is blocked. Tokens refill over time.  

**Pros**:  
- Allows burst traffic up to the bucket capacity.  
- Flexible for smoothing traffic flow.  

**Cons**:  
- Slightly more complex than Fixed Window.  

**Implementation**: This repository's **Token Bucket Rate Limiter** demonstrates this algorithm.  

---

## Setup  

1. Clone the repository:  
   ```bash  
   git clone https://github.com/daniel-ansari/api-rate-limiter-ex.git  
   cd rate-limiter  
   ```

3. run tests:
  ```bash
  mix test
  ```

## Fixed Window Rate Limiter

```elixir
FixedWindowRateLimiter.start()  
IO.inspect(FixedWindowRateLimiter.check_request("user1", 5, 60))  
```

## Sliding Window Rate Limiter
```elixir
SlidingWindowRateLimiter.start()  
IO.inspect(SlidingWindowRateLimiter.check_request("user1", 5, 60))  
```

## Token Bucket Rate Limiter
```elixir
TokenBucketRateLimiter.start()  
IO.inspect(TokenBucketRateLimiter.check_request("user1", 5, 1))  
```

Choosing the Right Algorithm
- Use Fixed Window for simple use cases where burst traffic isn't a concern.
- Use Sliding Window for smoother rate limiting with less abrupt blocking.
- Use Token Bucket when you need to allow bursts of traffic while maintaining an average rate.
- Token Bucket Algorithm is implemented in the TokenBucketRateLimiter module.
