Class {
	#name : 'GtMapperWorldZoomRequest',
	#superclass : 'BrRequest',
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'initialization' }
GtMapperWorldZoomRequest >> responseClass [
	^ GtMapperWorldZoomChanged
]
