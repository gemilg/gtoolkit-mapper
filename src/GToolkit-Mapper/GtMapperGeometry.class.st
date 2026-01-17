"
I represent a multipoligonal geometry of an area on the map, for example a country, a city or a district


"
Class {
	#name : 'GtMapperGeometry',
	#superclass : 'Object',
	#category : 'GToolkit-Mapper-Geometries',
	#package : 'GToolkit-Mapper',
	#tag : 'Geometries'
}

{ #category : 'converting' }
GtMapperGeometry >> asBlocGeometry [
	<return: #BlElementGeometry>

	^ self subclassResponsibility
]
