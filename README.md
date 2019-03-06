# FireTiles
Geo Queries for Firebase Firestore

How-To:

- clone the project 
- create a free Firebase Project and generate the "GoogleService-Info.plist"
- add the "GoogleService-Info.plist" into the "Resources" folder
- add the correct bundle identifier into the App
- run the project in Xcode, the App is now connected with your Firestore

Handling:

- press the button "Add places" to generate random places in the current visible map view region
- press the button "Bounding Box" to select the size for the nearby-search 
- tap in the map to start a nearby search. Green pins are within the search bounding box, red pins are outside the search bounding box

ATTENTION: creating and reading documents counts towards your Firestore Quota!

Bounding box precision 0.01 decimal degrees, roughly 2.5km x 3.3km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/0_01.png" width="250">

Bounding box precision 0.10 decimal degrees, roughly 8.5km x 11km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/0_10.png" width="250">

Bounding box precision 1.00 decimal degrees, roughly 85km x 111km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/1_00.png" width="250">
