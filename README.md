# FireTiles
iOS Geo Queries for Firebase Firestore 

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


## How to use it in your own project?

Just add the file "FireTile.swift" into your project.

Usage:

    /// On uploading a document which needs to be searched 
    let searchRegion = FireTile(precision: .p0_01).createSearchRegion(
      latitude: latRandom,
      longitude: longRandom
    )
  
    var document = [String: Any]()
    document["searchRegion"] = searchRegion
    // document["myField"] = "Some value" // add your field as needed
    ref.addDocument(data: document)
    
    ...
    ...
      
    // Searching for documents nearby
    let locationTile = FireTile(precision: .p0_01).location(coordinate: coordinate)
    db.collection("MyCollection")
       .whereField("searchRegion", arrayContains: locationTile)
       .getDocuments { snapshot, error in
          if let error = error {
            print(error)
          } else {
            for document in snapshot!.documents {
              // ...
            }
          }
        }
  
