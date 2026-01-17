Class {
	#name : 'GtOsmWidget',
	#superclass : 'Object',
	#instVars : [
		'coordinate',
		'map'
	],
	#category : 'GToolkit-Mapper-Osm',
	#package : 'GToolkit-Mapper',
	#tag : 'Osm'
}

{ #category : 'accessing' }
GtOsmWidget >> addToMap: aGtOsmMap [
	"Add the receiver to the supplied map"

	aGtOsmMap addWidget: self.
	map := aGtOsmMap.
]

{ #category : 'as yet unclassified' }
GtOsmWidget >> attachPointOffset [
	"Return px offset which points to actual widget coordinates."
	self subclassResponsibility.
]

{ #category : 'accessing' }
GtOsmWidget >> coordinate [
	<return: #Point>

	^ coordinate
]

{ #category : 'accessing' }
GtOsmWidget >> coordinate: aPoint [
	"Set the receiver's location to the supplied lon @ lat."

	coordinate := aPoint
]

{ #category : 'abstract' }
GtOsmWidget >> drawWidget [
	"Return BlElement which represents a widget"
	self subclassResponsibility.
]

{ #category : 'accessing' }
GtOsmWidget >> osmUrl [
	"Answer an OSM URL at the receiver's location"

	^ String streamContents: [ :stream |
		stream
			<< 'https://www.openstreetmap.org/#map=15/';
			<< self coordinate y asString;
			<< '/';
			<< self coordinate x asString ]
]

{ #category : 'as yet unclassified' }
GtOsmWidget >> removeFromMap: aGtOsmMap [
	aGtOsmMap removeWidget: self.
]
