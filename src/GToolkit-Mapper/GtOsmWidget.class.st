Class {
	#name : #GtOsmWidget,
	#superclass : #Object,
	#instVars : [
		'coordinate'
	],
	#category : #'GToolkit-Mapper-Osm'
}

{ #category : #'as yet unclassified' }
GtOsmWidget >> removeFromMap: aGtOsmMap [
	aGtOsmMap removeWidget: self.
]
