Class {
	#name : 'GtMapperWorldCenterChanged',
	#superclass : 'BrChangeEvent',
	#instVars : [
		'center'
	],
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'accessing' }
GtMapperWorldCenterChanged >> center [
	^ center
]

{ #category : 'accessing' }
GtMapperWorldCenterChanged >> center: anObject [
	center := anObject
]
