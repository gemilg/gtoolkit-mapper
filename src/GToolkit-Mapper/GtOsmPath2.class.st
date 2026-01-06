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
		map coordinateToPxOnCanvas: each ].

	^ BlElement new
		outskirts: BlOutskirts centered;
		geometry: (BlPolyline vertices: mapPoints);
		border: (BlBorder builder
				width: 2;
				paint: Color red; build).
]
