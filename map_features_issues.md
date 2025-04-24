# Cork City Property Analysis App - Map Feature Issues

## Overview

The Cork City Property Analysis app provides interactive visualizations of property sales and Airbnb listings in Cork City, Ireland. While the app offers powerful map-based features, we've encountered several technical issues during implementation, particularly related to the map visualizations.

## Issues Identified

### 1. C Stack Usage Error

**Symptoms:**
- The app crashes when applying filters to large datasets
- Error message: `Error in : C stack usage is too close to the limit`
- The error consistently occurs when switching visualization types

**Root Causes:**
- Complex reactive dependencies creating circular reference chains
- Large spatial datasets being processed simultaneously
- Multiple visualization types requiring heavy computation
- Recursive function calls in map rendering components

**Reproduction Steps:**
1. Select "Both" as the data source
2. Apply filters with wide price ranges that include many records
3. Switch between visualization types (points, heatmap, hexbin)

### 2. Memory Management Issues

**Symptoms:**
- High memory usage when rendering maps with many data points
- Slow performance when displaying clustered markers
- Plotting lag when switching between visualization types

**Root Causes:**
- Leaflet maps maintaining references to removed layers
- Inefficient clearing of previous visualizations
- Large spatial datasets being processed without sampling

### 3. Reactive Graph Complexity

**Symptoms:**
- Cascading reactivity triggering multiple updates
- Excessive re-rendering when filters are applied
- Value boxes updating unnecessarily when map visualizations change

**Root Causes:**
- Interdependent reactive elements
- Lack of isolation between different reactive contexts
- Complex conditional logic in observer functions

## Attempted Solutions

### Solution 1: Split Map Observers

We split the large, complex map visualization observer into multiple smaller, focused observers:
- One observer for clearing previous visualizations
- Separate observers for each visualization type (points, heatmap, hexbin)
- Added explicit requirements (`req()`) to control observer execution

**Outcome:** Only partially effective. Reduced complexity but didn't fully resolve stack usage errors.

### Solution 2: Isolate Reactive Dependencies

We implemented isolation to break circular dependencies:
- Used `isolate()` around filter logic
- Added explicit requirements with `req()`
- Removed auto-initialization of reactive expressions

**Outcome:** Improved stability but didn't completely resolve the issue.

### Solution 3: Data Sampling

We added data sampling to reduce dataset size:
- Limited datasets to a maximum of 2,000 points
- Implemented more efficient filtering operations

**Outcome:** Helped with performance but stack errors still occurred in certain scenarios.

## Recommendations for Further Improvement

1. **Optimize Data Loading and Filtering:**
   - Implement server-side filtering before loading into the app
   - Use spatial indices to improve query performance
   - Pre-compute aggregates for heatmap and hexbin visualizations

2. **Improve Memory Management:**
   - Implement garbage collection after large map operations
   - Reduce precision of coordinates for visualization purposes
   - Use more efficient data structures for spatial data

3. **Refactor Reactive Architecture:**
   - Implement a more modular design with clearer separation of concerns
   - Use reactive values instead of reactive expressions where appropriate
   - Consider a state management approach to reduce reactive complexity

4. **Technical Debt Reduction:**
   - Profile application to identify specific bottlenecks
   - Optimize R memory usage with more efficient data structures
   - Consider incremental loading of map features

## Conclusion

The enhanced map features in the Cork City Property Analysis app provide valuable insights but face technical challenges when dealing with large spatial datasets. The C stack usage error is the most critical issue, likely stemming from complex reactive dependencies and inefficient memory management.

While we've implemented several improvements that have reduced the severity and frequency of these issues, further optimization is required for a fully stable application. The recommendations outlined above should provide a roadmap for addressing the remaining technical challenges. 