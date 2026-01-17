Class {
	#name : 'GtMapperObjectGeometryRequest',
	#superclass : 'BrRequest',
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'initialization' }
GtMapperObjectGeometryRequest >> responseClass [
	^ GtMapperObjectGeometryChanged
]
