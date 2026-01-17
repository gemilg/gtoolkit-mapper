Class {
	#name : 'GtOsmMarker',
	#superclass : 'GtOsmWidget',
	#category : 'GToolkit-Mapper-Osm',
	#package : 'GToolkit-Mapper',
	#tag : 'Osm'
}

{ #category : 'as yet unclassified' }
GtOsmMarker >> attachPointOffset [
	^ (-2.5)@(-2.5)
]

{ #category : 'as yet unclassified' }
GtOsmMarker >> drawWidget [
	^ BlElement new
		size: 5@5;
		geometry: BlCircleGeometry new;
		background: Color red.
]
