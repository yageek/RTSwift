# RTSwift

An open-source swift library to query the API from the RTS. More informations about the differents APIs can be found at this URL: https://developer.srgssr.ch.

## Example

```swift
import RTSwift

    // KEY and SECRET can be found on your application page
    let client = RTSClient(key: "KEY", secret: "SECRET")

   client.searchTVShows(bu: .rts, query: "russie", success: { (result: SRGSSRVideo.TVShowsSearchResult) in

        print("List of TVShows:")
        for element in result.list {
            print("ID: \(element.id)")
            print("Title: \(element.title)")
            print("Transmission: \(element.transmission)")
        }

    }) { (error) in
        print("Error: \(error.localizedDescription)")
    }
```

## Dependencies
 - CwlMutex.swift -  Matt Gallagher
