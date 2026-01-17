Class {
	#name : 'GtMapperWorldScaleRequest',
	#superclass : 'BrRequest',
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'initialization' }
GtMapperWorldScaleRequest >> responseClass [
	^ GtMapperWorldScaleChanged
]
