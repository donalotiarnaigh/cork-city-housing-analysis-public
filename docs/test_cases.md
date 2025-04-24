# Cork City Property Analysis App - Test Cases

This document contains a checklist of test cases for the Cork City Property Analysis App. Use it to track which tests have been completed and document any issues encountered.

## How to use this document
- [ ] Unchecked box indicates a test that needs to be performed
- [x] Checked box indicates a completed test
- Add notes about any issues, observations, or inconsistencies under each test case

## 1. Basic Functionality Tests

### 1.1. Data Loading
- [x] **App Launch**: Launch app and verify both PPR and Airbnb datasets load without errors
  > *Notes*:
- [x] **Map Boundary**: Check that Cork City boundary appears correctly on map
  > *Notes*:

### 1.2. Data Source Selection
- [ ] **Property Sales**: Select "Property Sales" option and verify appropriate markers appear
  > *Notes*: Markers do not appear until filter is applied; should ALL markers appear by default (property sales loaded upon server start?)?
- [ ] **Airbnb Listings**: Select "Airbnb Listings" option and verify appropriate markers appear
  > *Notes*: Markers do not appear until filter is applied; should ALL markers appear by default as soon as airbnb listings is selected?
- [ ] **Both Sources**: Select "Both" option and verify all markers appear
  > *Notes*: Markers do not appear until filter is applied; should ALL markers from both datasets appear by default as soon as 'Both' is selected?
- [x] **Filter Updates**: Confirm sidebar filters change appropriately for each data source selection
  > *Notes*:
### 1.3. Price Filtering
- [ ] **PPR Price Filter**: Adjust property price range slider and click "Apply Filters"
  > *Notes*: Each time Apply Filters is clicked, a new legend is added to the map. A maximum of 1 of each type of legend should be added (1 PPR and 1 airbnb for a max of 2 total at once). Additionally, when I selected a range with no properties in it, the app crashed:
  
  ```
  Warning: Error in cut.default: 'breaks' are not unique
    55: stop
    54: cut.default
    52: pal
    51: addLegend
    50: %>%
    49: observe [/Users/danieltierney/Documents/Cloud_FinalProject/app/app.R#864]
    48: <observer>
     1: shiny::runApp
  ```

- [x] **Airbnb Price Filter**: Adjust price per night slider and click "Apply Filters"
  > *Notes*: Same as above, new legend added to map with each filter application
- [x] **Filter Verification**: Verify markers on map update to reflect filter settings
  > *Notes*:
- [x] **Statistics Update**: Confirm statistics boxes update to reflect filtered data
  > *Notes*:

### 1.4. Property Type Filtering
- [x] **Select Specific Type**: Select different property types from dropdown and apply filters
  > *Notes*:
- [x] **All Types**: Test "All" option to confirm all property types are shown
  > *Notes*:
- [x] **Marker Verification**: Verify only selected property types appear on map
  > *Notes*:

### 1.5. Room Type Filtering (Airbnb)
- [ ] **Select Room Type**: Select different room types and apply filters
  > *Notes*: Selecting `Shared room` caused the app to crash and we need to determine why. Are there no shared room records?

```
Warning: Error in cut.default: 'breaks' are not unique
  55: stop
  54: cut.default
  52: pal
  51: addLegend
  50: %>%
  49: observe [/Users/danieltierney/Documents/Cloud_FinalProject/app/app.R#936]
  48: <observer>
   1: shiny::runApp
```

- [x] **All Room Types**: Test "All" option to confirm all room types are shown
  > *Notes*:
- [x] **Marker Verification**: Verify only listings of selected room type appear on map
  > *Notes*:
1
## 2. Visualization Tests

### 2.1. Map Interaction
- [x] **Pan and Zoom**: Test map panning and zooming functionality
  > *Notes*:
- [x] **Marker Popups**: Click on markers to verify popup content is correct and formatted properly
  > *Notes*:
- [x] **Marker Clustering**: Test marker clustering behavior at different zoom levels
  > *Notes*: Works as intended, I would like t a toggle for it however
- [x] **Layer Controls**: Test layer control panel for base map selection
  > *Notes*:

### 2.2. Chart Tab Tests
- [x] **Tab Navigation**: Switch to Charts tab and verify all visualizations load
  > *Notes*:
- [x] **Price Distribution**: Test price distribution histogram with different data sources
  > *Notes*:
- [x] **Time Analysis**: Verify time analysis chart shows proper date-based data
  > *Notes*:
- [x] **Correlation Viz**: Check correlation visualization works when "Both" data source is selected
  > *Notes*:
- [x] **Chart Responsiveness**: Verify charts update when filters are applied
  > *Notes*:

### 2.3. Value Boxes
- [x] **Statistics Display**: Verify statistics in value boxes (total records, median price, price range)
  > *Notes*:
- [x] **Updates with Filters**: Confirm values update when filters are applied
  > *Notes*:

## 3. Edge Case Tests

### 3.1. Filter Combinations
- [ ] **Multiple Filters**: Apply multiple filters simultaneously (price + property type)
  > *Notes*: App crashes when `Minimum reviews` is set to the max value
- [ ] **Extreme Values**: Test extreme filter values (min/max prices)
  > *Notes*: App crashes when Airbnb price filter is set to max on both ends (nothing within range)
- [ ] **Zero Results**: Select filters that would return zero results and verify empty map handling
  > *Notes*: This is a big issue across the filters. When price range is set to zero (0-0) no records are selected as expected. When they're set to the max and no results are expected, the app crashes

### 3.2. Large Dataset Performance
- [ ] **Maximum Points**: Disable all filters to show maximum number of points
  > *Notes*: No records are shown when no filters are applied. When all records are shown on the map however, it remains responsive
- [ ] **Map Responsiveness**: Test responsiveness of map with large dataset
  > *Notes*:
- [ ] **Error Monitoring**: Watch for C stack usage errors or slowdowns
  > *Notes*:

### 3.3. Browser Compatibility
- [ ] **Chrome**: Test app in Chrome browser
  > *Notes*:
- [ ] **Firefox**: Test app in Firefox browser
  > *Notes*:
- [ ] **Safari**: Test app in Safari browser
  > *Notes*:

## 4. Error Handling Tests

### 4.1. Filter Reset
- [ ] **Reset to Default**: Apply filters then reset to default values
  > *Notes*: There is currently no buytton to reset to default values
- [ ] **Map/Stats Update**: Verify map and statistics update correctly after reset
  > *Notes*:

### 4.2. Rapid Interactions
- [ ] **Tab Switching**: Quickly change tabs multiple times
  > *Notes*:
- [ ] **Rapid Filtering**: Rapidly change filters and apply in succession
  > *Notes*:
- [ ] **Stability Check**: Test for stability under fast user interactions
  > *Notes*:

## 5. Date-Related Tests

### 5.1. Time Analysis
- [x] **Date Ranges**: Verify time-based charts show correct date ranges
  > *Notes*:
- [x] **Data Source Impact**: Check time analysis chart updates with different data source selections
  > *Notes*:

## 6. Additional Observations

*Document any other issues or observations not covered by the specific test cases above:*

Warning in RColorBrewer::brewer.pal(N, "Set2") :
  minimal value for n is 3, returning requested palette with 3 different levels



---

## Test Summary

**Date tested**: _________________

**Tester**: _________________

**App version/commit**: _________________

**Total tests passed**: ______ / ______

**Critical issues found**: ______

**Major issues found**: ______

**Minor issues found**: ______

**Cosmetic issues found**: ______ 