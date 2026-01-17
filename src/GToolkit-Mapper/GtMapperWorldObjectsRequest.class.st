Class {
	#name : 'GtMapperWorldObjectsRequest',
	#superclass : 'BrRequest',
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'initialization' }
GtMapperWorldObjectsRequest >> responseClass [
	^ GtMapperWorldObjectsChanged
]
