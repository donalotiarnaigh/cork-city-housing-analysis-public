# Cork City Property Analysis App - Snag List

This document catalogs bugs and issues identified during testing of the Cork City Property Analysis application. Issues are categorized by severity to help prioritize fixes.

## Critical Issues
These issues cause app crashes or prevent core functionality from working.

1. **Empty Filter Results Crash** ✅ FIXED
   - **Description**: App crashes when filters return zero results
   - **Reproduction Steps**: 
     - Set price range to values with no matching records
     - Set Airbnb price filter to max on both ends
   - **Error Message**: `Error in cut.default: 'breaks' are not unique`
   - **Location**: Filter handling code in app.R
   - **Priority**: High - Prevents basic filtering operations
   - **Fix Applied**: Added robust error handling for empty datasets:
     - Added `clearControls()` to prevent multiple legends
     - Added specific handling for empty result sets (0 records)
     - Added special case handling for single record result sets (1 record)
     - Added checks for unique price values to prevent breaks errors
     - Added user feedback with notifications when no data matches filters
     - Implemented clear error messages on the map itself

2. **Room Type Filter Crash** ✅ FIXED
   - **Description**: App crashes when selecting "Shared room" filter
   - **Reproduction Steps**: Select "Airbnb Listings" as data source, select "Shared room" option, click Apply Filters
   - **Error Message**: `Error in cut.default: 'breaks' are not unique`
   - **Location**: Room type filtering code in app.R (line 936)
   - **Priority**: High - Prevents filtering by a specific room type
   - **Fix Applied**: Fixed by the same comprehensive error handling implementation that addressed issue #1, specifically:
     - Added checks for unique price values to prevent breaks errors
     - Added special handling for empty or single-record result sets

3. **Maximum Reviews Filter Crash** ✅ FIXED
   - **Description**: App crashes when "Minimum reviews" is set to max value
   - **Reproduction Steps**: Set "Minimum reviews" slider to maximum value, click Apply Filters
   - **Error Message**: Not specified in test notes
   - **Location**: Minimum reviews filter handling in app.R
   - **Priority**: High - Prevents filtering by maximum review threshold
   - **Fix Applied**: Fixed by the same error handling implementation that addressed issues #1 and #2:
     - Added robust handling for empty result sets from any filter combination
     - Added special case handling for all filter scenarios that return few or no results

## Major Issues
These issues significantly impact usability but don't crash the app.

1. **No Default Display of Markers** ✅ FIXED
   - **Description**: Markers do not appear until filters are applied
   - **Expected Behavior**: All markers should appear by default when a data source is selected
   - **Actual Behavior**: Map shows no markers until the user applies a filter
   - **Impact**: Users may think the app is not working properly
   - **Priority**: Medium - Affects initial user experience
   - **Fix Applied**: Implemented automatic display of all markers when app loads and when data source changes:
     - Created reactive expressions for unfiltered datasets 
     - Added a new observer that triggers on data source changes
     - Refactored marker display code into a reusable function
     - Maintained existing filter functionality while showing all records by default

2. **Multiple Legends Added** ✅ FIXED
   - **Description**: Each time "Apply Filters" is clicked, a new legend is added to the map
   - **Expected Behavior**: Only one legend of each type should exist (max of 2 total - one for PPR, one for Airbnb)
   - **Actual Behavior**: Multiple duplicate legends accumulate on the map
   - **Impact**: Clutters the map interface and confuses users
   - **Priority**: Medium - Affects map readability and appearance
   - **Fix Applied**: Added `clearControls()` to remove existing legends before adding new ones

3. **No Filter Reset Button** ✅ FIXED
   - **Description**: No way to reset filters to default values
   - **Expected Behavior**: A reset button should be available to return all filters to default settings
   - **Impact**: Users must manually reset each filter
   - **Priority**: Medium - Impacts usability for frequent filter changes
   - **Fix Applied**: Implemented a more intuitive solution:
     - Modified app to show all records by default (full data range)
     - Made filters automatically reset when switching data sources
     - Changed filtering approach to be reactive (not requiring button press)
     - Updated UI text to indicate that all records are shown by default
     - Renamed button to "Apply Custom Filters" for clarity

4. **Incorrectly Geocoded Property** ✅ FIXED
   - **Description**: The most expensive property in the dataset is geocoded outside Cork City boundaries
   - **Impact**: Skews price statistics and visualizations for the dataset
   - **Affected Data**: PPR dataset - highest priced property
   - **Priority**: High - Affects data accuracy and analysis results
   - **Fix Applied**: 
     - Created a list of 119 properties that were incorrectly filtered out
     - Wrote scripts to identify and restore these properties to the dataset
     - Added these properties back to both CSV and GPKG versions of the dataset
     - Created backups of the original files before making changes

## Minor Issues
These issues affect certain functionality but have workarounds.

1. **No Toggle for Marker Clustering** ✅ FIXED
   - **Description**: Marker clustering works, but cannot be toggled on/off
   - **Requested Enhancement**: Add an option to enable/disable marker clustering
   - **Impact**: User has no control over clustering behavior
   - **Priority**: Low - Functionality works but lacks customization
   - **Fix Applied**:
     - Added a checkbox in the UI sidebar to toggle marker clustering on/off
     - Created a `getClusterOptions()` function that returns either clustering options or NULL
     - Updated all marker creation code to use this function
     - Set the default value to enabled (TRUE) to maintain original behavior

## Cosmetic Issues
These issues affect appearance but not functionality.

1. **RColorBrewer Warning**
   - **Description**: Console warning about color brewer palette
   - **Warning Message**: `Warning in RColorBrewer::brewer.pal(N, "Set2") : minimal value for n is 3, returning requested palette with 3 different levels`
   - **Impact**: No visible impact to users, but appears in server logs
   - **Priority**: Very Low - Debug warning only

## Summary of Issues

- **Critical Issues**: 3 (3 fixed, 0 remaining)
- **Major Issues**: 4 (4 fixed, 0 remaining)
- **Minor Issues**: 1 (1 fixed, 0 remaining)
- **Cosmetic Issues**: 1 (0 fixed, 1 remaining)

## Next Steps

1. Consider addressing the remaining cosmetic issue:
   - Fix RColorBrewer warning to clean up server logs

## Fixed Issues Log

| Issue | Fixed Date | Commit | Fix Description |
|-------|------------|--------|----------------|
| Empty Filter Results Crash | April 30, 2025 | 1c36ef3 | Added robust error handling for empty/single result datasets |
| Multiple Legends Added | April 30, 2025 | 1c36ef3 | Added clearControls() to prevent legend duplication |
| Room Type Filter Crash | April 30, 2025 | 1c36ef3 | Fixed with same error handling as empty filter results |
| Maximum Reviews Filter Crash | April 30, 2025 | 1c36ef3 | Fixed with same error handling as empty filter results |
| No Default Display of Markers | April 30, 2025 | 5811436 | Implemented automatic display of all markers on app start and data source changes | 
| No Filter Reset Button | May 1, 2025 | 4a2023b | Implemented automatic filter reset and default to showing all records | 
| Incorrectly Geocoded Property | May 3, 2025 | 35d2e43 | Restored 119 incorrectly filtered properties to the dataset |
| No Toggle for Marker Clustering | May 3, 2025 | c01f0dd | Added checkbox toggle for marker clustering with default enabled | 