Class {
	#name : #GtOsmPath2,
	#superclass : #GtOsmWidget,
	#instVars : [
		'coordinates'
	],
	#category : #'GToolkit-Mapper-Osm'
}

{ #category : #'as yet unclassified' }
GtOsmPath2 >> attachPointOffset [
	^ (-1)@(-1)
]

{ #category : #accessing }
GtOsmPath2 >> coordinateToMap: aPoint map: aGtOsmMap [
	| osmTiles tileNumber tileOffset mx my initialTileNumber |
	osmTiles := GtOpenStreetMapTiles new.

	"TODO, this can be calculated only once."
	initialTileNumber := osmTiles
			getTileNumberLat: coordinate y
			long: coordinate x
			zoom: aGtOsmMap zoom.
	tileNumber := osmTiles
			getTileNumberLat: aPoint y
			long: aPoint x
			zoom: aGtOsmMap zoom.
	tileOffset := osmTiles
			pixelPointAt: aPoint
			tile: tileNumber
			zoom: aGtOsmMap zoom.

	^ tileOffset + ((tileNumber - initialTileNumber) * 256).
]

{ #category : #accessing }
GtOsmPath2 >> coordinates [
	<return: #Array of: #Point>

	^ coordinates
]

{ #category : #accessing }
GtOsmPath2 >> coordinates: anObject [
	coordinates := anObject.
	coordinate := coordinates at: 1.
]

{ #category : #'as yet unclassified' }
GtOsmPath2 >> drawWidget [
	| mapPoints |
	mapPoints := coordinates collect: [ :each |
		self coordinateToMap: each map: map ].

	^ BlElement new
		outskirts: BlOutskirts centered;
		geometry: (BlPolyline vertices: mapPoints);
		border: (BlBorder builder
				width: 2;
				paint: Color red; build).
]
