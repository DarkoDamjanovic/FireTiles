# FireTiles
iOS Geo Queries for [Firebase Firestore](https://firebase.google.com/docs/firestore/) 

Currently (March 6th, 2019) Firebase Firestore still does not support geo location queries like "give me all documents near by this location". *FireTiles* trys to add this missing feature in a really simple and straightforward way.

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/sf.png" width="250">

Table of Contents
=================

   * [FireTiles](#firetiles)
      * [How does it work?](#how-does-it-work)
      * [Bounding box sizes](#bounding-box-sizes)
      * [How to start the sample project?](#how-to-start-the-sample-project)
      * [How to use it in your own project?](#how-to-use-it-in-your-own-project)
      * [Comparison to GeoFirestore](#comparison-to-geofirestore)
      * [Android / JavaScript version](#android--javascript-version)
      * [Discussion](#discussion)

## How does it work?

FireTile uses a tile approach to enable geo searches in Firestore.
It places tiles around the lat/long coordinate of your documents:

     ____ ____ ____
    |    |    |    |
     ---- ---- ----
    |    | x  |    |
     ---- ---- ----
    |    |    |    |
     ---- ---- ---- 
(remark: the "x" marks the lat/long location of your document) 
 
Those tiles are marked with string identifiers which store infomations about:

- the search bounding box size
- the current location

FireTile creates 9 of those string identifiers for you to "sourround" your document. You just have to add those identifiers on an array field to all the documents you want to include in your geo query.

```swift
let searchRegions = FireTile(precision: .p0_01).createSearchRegion(coordinate: coordinate)
document["searchRegions"] = searchRegions
```

Then, on nearby search you just do this:

```swift
let location = FireTile(precision: .p0_01).location(coordinate: coordinate)
db.collection("MyCollection")
   .whereField("searchRegions", arrayContains: location)
```
And you will get all the documents which you have "tagged" before with the identifiers.

## Bounding box sizes

Currently three sizes are implemented, which are configured with the precision parameter:

        /// precision 0.01 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 2.5km x 3.3km
        case p0_01
        
        /// precision 0.10 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 8.5km x 11km
        case p0_10
        
        /// precision 1.00 decimal degrees for latitude and longitude
        /// this roughly translates to a search region of 85km x 111km
        case p1_00

But theoretically any precision/bounding box size is possible, the code is quite simple. The precision refers to the size of one tile. So p0_01 means one tile is 0.01 decimal degrees big for lat and long. Because three times three tiles are used to specify the bounding box this translates to roughly 2.5km x 3.3km for p0_01. (and so on...)

You will see something like this in the Firestore dashboard if you have uploaded only the p0_01 precision: (multiple precisions are possible)

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/tiles.png" width="250">

- "p0_01" indicates the precision and therefore the resulting bounding box size.
- e.g. "35.97/-115.42" indicates the upper left (north-west) lat/long coordinate of each tile.
- Currently 9 tiles will be stored per bounding box size.

## How to start the sample project?

- clone the project 
- create a free Firebase Project and generate the "GoogleService-Info.plist"
- add the "GoogleService-Info.plist" into the "Resources" folder
- add the correct bundle identifier into the App
- run the project in Xcode, the App is now connected with your Firestore

**Handling:**

- press the button "Add places" to generate random places in the current visible map view region
- press the button "Bounding Box" to select the size for the nearby-search 
- tap in the map to start a nearby search. Green pins are within the search bounding box, red pins are outside the search bounding box

**ATTENTION: creating and reading documents counts towards your Firestore Quota!**

Bounding box precision 0.01 decimal degrees, roughly 2.5km x 3.3km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/0_01.png" width="250">

Bounding box precision 0.10 decimal degrees, roughly 8.5km x 11km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/0_10.png" width="250">

Bounding box precision 1.00 decimal degrees, roughly 85km x 111km:

<img src="https://raw.githubusercontent.com/DarkoDamjanovic/FireTiles/master/Screenshots/1_00.png" width="250">


## How to use it in your own project?

Just add the file "FireTile.swift" into your project.

Usage:

```swift
/// On uploading a document which needs to be searched 
let searchRegions = FireTile(precision: .p0_01).createSearchRegion(coordinate: coordinate)
  
var document = [String: Any]()
document["searchRegions"] = searchRegions
// document["myField"] = "Some value" // add your fields as needed
ref.addDocument(data: document)
    
...
...
      
// Searching for documents nearby
let location = FireTile(precision: .p0_01).location(coordinate: coordinate)
db.collection("MyCollection")
   .whereField("searchRegions", arrayContains: location)
   .getDocuments { snapshot, error in
      if let error = error {
         print(error)
      } else {
        for document in snapshot!.documents {
          // ...
        }
      }
    }
  ```

It is also possible to add multiple bounding box sizes for searching:

```swift
/// On uploading a document which needs to be searched 
var allRegions = [String]()
let searchRegions_p0_01 = FireTile(precision: .p0_01).createSearchRegion(coordinate: coordinate)
let searchRegions_p0_10 = FireTile(precision: .p0_10).createSearchRegion(coordinate: coordinate)  
let searchRegions_p1_00 = FireTile(precision: .p1_00).createSearchRegion(coordinate: coordinate)

allRegions.append(contentsOf: searchRegions_p0_01)
allRegions.append(contentsOf: searchRegions_p0_10)
allRegions.append(contentsOf: searchRegions_p1_00)

var document = [String: Any]()
document["searchRegions"] = allRegions
// document["myField"] = "Some value" // add your fields as needed
ref.addDocument(data: document)
```

## Comparison to GeoFirestore

See: https://github.com/imperiumlabs/GeoFirestore-iOS/blob/master/README.md

GeoFirestore uses geo hashes to implement geo queries. 
Both the tile based approach and the geo hash approach have advantages and disadvantages:

Geo hashes:
- needs multiple queries (afaik: 4 queries, even if a query returns 0 documents it counts as 1 read and will be charged)
- does overquery afaik - which means more documents are read then needed (which will be charged)
- consumes the range operator - Firestore allows range search only on one field, so you cant use any other ranges in the query
- complex logic - GeoFirestore depends on the older (huge) GeoFire library for generating geo hashes and geo queries 
- it is possible to query for every possible search bounding box without specifying it in advance
- radius search is implemented on client side, not server side

Tiles:
- needs just one query
- does not overquery
- consumes the arrayContains search - Firestore allows arrayContains only once in a query, so you cant use it on another field
- really simple logic (currently less then 100 lines of code for three bounding box sizes)
- needs to specify the possible search bounding boxes in advance
- radius search has to be implemented by you manually on client side

Geo hashes are more flexible, but more complex and expensive.
Tiles are less flexible but simple, cheap and fast.
You have to decide for yourself which approach fit's your needs better.

The main problem I have with Geo hashes is - it is really complex. There is so much "magic" going on and I feel out of control. Considering that the number of reads on Firestore directly creates cost I feel much better if I know exactly what is happening. 

## Android / JavaScript version

The whole logic is contained in the FireTiles.swift file, which is currently approx. 100 lines of really simple and easy to understand Swift code. I leave this exercise to the experienced Android and Web Developers. :) 

Please inform me if you translate this to Android or JavaScript, then I will link your repo here. Thanks in advance.

## Discussion

This is just a first draft of a tile-based approach for geo queries on Firestore.
It is possible to optimize and enhance this in many ways.
I am open for any discussion and pull requests!

:-)
