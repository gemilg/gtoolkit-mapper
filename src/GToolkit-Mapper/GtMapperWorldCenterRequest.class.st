Class {
	#name : 'GtMapperWorldCenterRequest',
	#superclass : 'BrRequest',
	#category : 'GToolkit-Mapper-Widget - Events',
	#package : 'GToolkit-Mapper',
	#tag : 'Widget - Events'
}

{ #category : 'initialization' }
GtMapperWorldCenterRequest >> responseClass [
	^ GtMapperWorldCenterChanged
]
