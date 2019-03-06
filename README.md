# FireTiles
iOS Geo Queries for Firebase Firestore 

## How does it work?

FireTile uses a tile approach to enable geo searches in Firestore.
It pleaces tiles around a lat/long location:

     ___ ___ ___
    |   |   |   |
     --- --- ---
    |   | x |   |
     --- --- ---
    |   |   |   |
     --- --- --- 
(remark: the "x" marks the lat/long location of your document) 
 
Those tiles are marked with string identifiers which store infomations about:

- the search bounding box size
- the current location

FireTile creates 9 of those string identifiers for you to sourround your document,
You just have to add those identifiers on an array field of the document.

```swift
let searchRegions = FireTile(precision: .p0_01).createSearchRegion(coordinate: coordinate)
```

Then, on nearby search you just do this:

```swift
let location = FireTile(precision: .p0_01).location(coordinate: coordinate)
db.collection("MyCollection")
   .whereField("searchRegions", arrayContains: location)
```

## How to start the project?

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
// document["myField"] = "Some value" // add your field as needed
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
