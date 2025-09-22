Class {
	#name : #GtOsmCanvassableMap,
	#superclass : #BlCanvassableElement,
	#instVars : [
		'topLeftCoordinate',
		'bottomRightCoordinate',
		'zoom',
		'centerCoordinate',
		'centerTileOffset',
		'tilesContainer'
	],
	#category : #'GToolkit-Mapper-Osm'
}

{ #category : #accessing }
GtOsmCanvassableMap >> addChildren [
	tilesContainer := self buildTilesContainer.
	
	self enqueueTask: [ self focusViewOnCoordinate: self centerCoordinate ] asBlTask.
	
	self
		size: (self tileDimensions x * 256) @ (self tileDimensions y * 256);
		addChild: tilesContainer.
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> additionalNumberOfTilesAroundCenter [
	"This is the default value of number of tiles above/below/left/right the center tile"
	^ 1
]

{ #category : #accessing }
GtOsmCanvassableMap >> bottomRightCoordinate [
	^ bottomRightCoordinate
]

{ #category : #accessing }
GtOsmCanvassableMap >> bottomRightCoordinate: aNumber [
	bottomRightCoordinate := aNumber
]

{ #category : #accessing }
GtOsmCanvassableMap >> bottomRightTileNumber [

	^ GtOpenStreetMapTiles new getTileNumberLat: bottomRightCoordinate y long: bottomRightCoordinate x zoom: zoom
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> buildTilesContainer [
	| osm tileDimensions rowContainer centerNumber tiles |

	tileDimensions := self tileDimensions.
	centerNumber := self centerTileNumber.
	osm := GtOpenStreetMapTiles new.
	tiles := BlElement new
			size: (tileDimensions x * 256) @ (tileDimensions y * 256);
			layout: BlGridLayout vertical.

	1 to: tileDimensions y
		do: [ :y | 
			rowContainer := BlElement new
					size: (tileDimensions x * 256) @ 256;
					layout: BlGridLayout horizontal.
			1 to: tileDimensions x
				do: [ :x | 
					| point file image |
					point := (centerNumber x + x - self additionalNumberOfTilesAroundCenter - 1)
							@ (centerNumber y + y - self additionalNumberOfTilesAroundCenter - 1) + self centerTileOffset.
					file := osm filenameForTileNumber: point zoom: zoom.
					image := (SkiaImage fromFile: file) asElement
							constraintsDo: [ :c | 
								c horizontal matchParent.
								c vertical matchParent ].
					rowContainer addChild: image ].
			tiles addChild: rowContainer ].

	^ tiles
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerCoordinate [
	^ centerCoordinate
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerCoordinate: aPoint [
	centerCoordinate := aPoint
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerTileNumber [

	^ GtOpenStreetMapTiles new getTileNumberLat: centerCoordinate y long: centerCoordinate x zoom: zoom
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerTileOffset [
	^ centerTileOffset
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerTileOffset: aPoint [
	centerTileOffset := aPoint
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> focusViewOnCoordinate: aPoint [
	| tileNumber osmTiles tileOffset mx my mapOffset resultTransformation canvasMarginOffset canvasSize tilesExtent additionalTilesOffset |

	osmTiles := GtOpenStreetMapTiles new.
	tileNumber := self centerTileNumber.
	tileOffset := osmTiles
			pixelPointAt: aPoint x @ aPoint y
			tile: tileNumber
			zoom: self zoom.
	mx := self additionalNumberOfTilesAroundCenter * 256.
	my := self additionalNumberOfTilesAroundCenter * 256.
	
	additionalTilesOffset := mx@my.

	canvasMarginOffset := 20@20.
	canvasSize := (self parent parent measuredBounds extent x)@(self parent parent measuredBounds extent y).
	tilesExtent := (self measuredBounds extent x)@(self measuredBounds extent y).
	mapOffset := (tilesExtent / 2) - additionalTilesOffset - tileOffset.

	resultTransformation := (canvasSize / 2) - (tilesExtent / 2) - canvasMarginOffset + mapOffset.

	self childrenTranslationFactor: resultTransformation
]

{ #category : #accessing }
GtOsmCanvassableMap >> gtSummaryFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Summary';
		priority: 20;
		items: [ {
			'Top Left Coordinate' -> self topLeftCoordinate.
			'Bottom Right Coordinate' -> self bottomRightCoordinate.
			'Top Left Tile Number' -> self topLeftTileNumber.
			'Bottom Right' -> self bottomRightTileNumber. } ];
		column: 'Attribute' text:
			[ :item | item key ];
		column: 'Value' text:
			[ :item | item value ];
		actionUpdateButton
]

{ #category : #accessing }
GtOsmCanvassableMap >> includeCoordinate: aPoint [

	aPoint x < topLeftCoordinate x ifTrue:
		[ topLeftCoordinate := aPoint x @ topLeftCoordinate y ].
	aPoint y > topLeftCoordinate y ifTrue:
		[ topLeftCoordinate := topLeftCoordinate x @ aPoint y ].
	aPoint x > bottomRightCoordinate x ifTrue:
		[ bottomRightCoordinate := aPoint x @ bottomRightCoordinate y ].
	aPoint y < bottomRightCoordinate y ifTrue:
		[ bottomRightCoordinate := bottomRightCoordinate x @ aPoint y ].

]

{ #category : #accessing }
GtOsmCanvassableMap >> initialize [

	super initialize.
	topLeftCoordinate := 1000 @ -1000.
	bottomRightCoordinate := -1000 @ 1000.
	centerTileOffset := 0@0.
	tilesContainer := BlElement new.
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> scrollTiles: aPoint [

	self centerTileOffset: self centerTileOffset + aPoint.
	tilesContainer := self buildTilesContainer.

	self
		size: (self tileDimensions x * 256) @ (self tileDimensions y * 256);
		removeChildAt: 1;
		addChild: tilesContainer.
]

{ #category : #accessing }
GtOsmCanvassableMap >> tileDimensions [
	| dim |
	
	dim := self additionalNumberOfTilesAroundCenter * 2 + 1.
	^ dim@dim
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> tilesContainer [
	^ tilesContainer
]

{ #category : #accessing }
GtOsmCanvassableMap >> topLeftCoordinate [
	^ topLeftCoordinate
]

{ #category : #accessing }
GtOsmCanvassableMap >> topLeftCoordinate: aNumber [
	topLeftCoordinate := aNumber
]

{ #category : #accessing }
GtOsmCanvassableMap >> topLeftTileNumber [

	^ GtOpenStreetMapTiles new getTileNumberLat: topLeftCoordinate y long: topLeftCoordinate x zoom: zoom
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> updateZoom: aNumber [
	self zoom: aNumber.
]

{ #category : #accessing }
GtOsmCanvassableMap >> zoom [
	^ zoom
]

{ #category : #accessing }
GtOsmCanvassableMap >> zoom: anObject [
	zoom := anObject
]
