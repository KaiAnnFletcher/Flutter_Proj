# Safe-Zone

##Background:
Safe-Zone is currently a concept app we have designed with mock-up data that shows the busy and quiet hours for certain restaurants, covid-19 test centers, stores and churches in the city of New York which was very hard-hit by the covid-19 pandemic. 

##Real World Problem:
Considering the covid-19 pandemic, the idea of being in public itself is its on risk. This is due to how highly contagious the disease is. Being near other people automatically puts you at risk for contracting the virus, since there is no way of knowing who has it or not. It becomes a particularly more dangerous situation when crowding occurs. In a city like New York, where crowds are sometimes inevitable, the risk is more real compared to other places.

##Solution:
Our app provides users with the information they need to plan their trips according to busy and quiet hours for certain establishments (these establishments are already mentioned above in the Background section). By providing users with a list of the busy/quiet hours typical for specific locations, it will help them to better prepare and plan their visits. For example, they have the information at hand to select any of the quiet times to visit an establishment. Likewise, they will know beforehand if they are visiting an establishment during busy hours and will be able to better prepare (e.g. ensuring that they do not forget masks and hand sanitizers before leaving their homes). This app will help users to plan their trips or outings with more confidence. It eliminates the fear factor of not knowing what to expect when venturing out in public, especially in a city like New York.

##UX/UI Breakdown:

These are the location categories we are reporting busy/quiet times for. Each location category has 4 unique locations which are pinned on the map (hard-coded data from the JSON API):

![Church](/assets/images/church.png)

![Restaurant](/assets/images/restaurant.png)

![Store](/assets/images/store.png)

![Test Center](/assets/images/testCenter.png)

Details regarding busy/quiet hours pops up as a modal. For test centers, the details are different.

![Timings](/assets/images/timings.png)

![Testing Details](/assets/images/Testingdetails.png)

##Technology, Tools and Architecture

* JSON data API
* Google maps API  
* Firebase Firestore Database

General Directory Structure:

```
.
|- dart_tool
|   |- flutter_build
|       |- d88cd3bc7e79a8...
|
|-android
|   |-.gradle
|   |-.settings
|   |-app
|   |-gradle
|       |-wrapper
|
|-api
|
|-assets
|   |-icons
|   |-images
|
|-build
|   |-app
|   |-cloud_firestore
|   |-cloud_firestore_web
|   |-firebase_core
|   |-firebase_core_web
|   |-flutter_plugin_android_lifecycle
|   |-google_maps_flutter
|   |-kotlin
|       |-sessions
|
|-ios
|   |- Flutter
|   |-Runner
|   |-Runner.xcodeproj
|   |-Runner.xcworkspace
|
|-lib
|   |-constants
|   |-model
|   |-screens
|   |-widgets
|
|-test
```

##API Challenges

Difficulty sourcing an API that measures crowd data in Real Time so that we can show crowd statistics for any given location at any time.

One possible solution was found: Proximus Real Time Crowd Management API.

This API however is only available for use in Belgium. The API is also not free. A free plan only allows you to be able to measure crowd statistics in three predefined zones near Brussels tower.

The data also has time intervals for streaming which expires. This is also not ideal for the purpose of our app. Perhaps if used in future we can investigate automating scripts that can set the interval daily. 

At this time, a setup like this would be too extensive.

Eventually, two other promising possibilities were found but could not be used:

1) npm package “busy-hours”: This promising solution is a hacky scraper made for scraping Google's popular times data. Google does not provide poplar times in its API and so these developers sort to create it themselves. It violates Google's Terms of Service. Moreover, when we attempted to implement it, there were errors in its node-modules which is never a good sign for package libraries like these.

2) “BestTime” API: This was the best and most promising API we found. However, it was not free. It is a subscription-based service. As a result, we decided against using it. However, if this concept app were to be moved to production, we can implement this solution, thereby eliminating use of our extremely limited mock-up data.

##Improvements

Implement “BestTime” API when ready to move this app to production.

Currently, we have Firebase as a backend service. We can expand and store other collections in the database once the API is implemented.

Implement SignUp and Login methods (using Firebase OAuth) so that we can store unique data pertaining to our users. This will assist with future data analytics and insights into our app usage.
