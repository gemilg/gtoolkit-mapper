Class {
	#name : 'GtMapperObjectGeometryChanged',
	#superclass : 'BrChangeEvent',
	#instVars : [
		'geometry'
	],
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'accessing' }
GtMapperObjectGeometryChanged >> geometry [
	^ geometry
]

{ #category : 'accessing' }
GtMapperObjectGeometryChanged >> geometry: anObject [
	geometry := anObject
]
