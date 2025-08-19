Class {
	#name : #GtOsmCanvassableMap,
	#superclass : #BlCanvassableElement,
	#instVars : [
		'topLeftCoordinate',
		'bottomRightCoordinate',
		'zoom'
	],
	#category : #'GToolkit-Mapper-Osm'
}

{ #category : #accessing }
GtOsmCanvassableMap >> addChildren [
	| tilesContainer tileDimensions topLeftNumber osm rowContainer |

	tileDimensions := self tileDimensions.
	topLeftNumber := self topLeftTileNumber.
	osm := GtOpenStreetMapTiles new.
	tilesContainer := BlElement new
		size: (tileDimensions x * 256) @ (tileDimensions y * 256);
		layout: BlGridLayout vertical.
	1 to: tileDimensions y do: [ :y |
		rowContainer := BlElement new
			size: (tileDimensions x * 256) @ 256;
			layout: BlGridLayout horizontal.
		1 to: tileDimensions x do: [ :x | | point file image |
			point := (topLeftNumber x + x - 1) @ (topLeftNumber y + y - 1).
			file := osm filenameForTileNumber: point zoom: zoom.
			image := (SkiaImage fromFile: file) asElement
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical matchParent ].
			rowContainer addChild: image ].
		tilesContainer addChild: rowContainer ].
	self
		size: (tileDimensions x * 256) @ (tileDimensions y * 256);
		addChild: tilesContainer.
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
GtOsmCanvassableMap >> focusViewOnCoordinate: aPoint [
	| tileNumber osmTiles tileOffset mx my mapOffset resultTransformation canvasMarginOffset canvasSize tilesSize additionalTilesOffset |

	osmTiles := GtOpenStreetMapTiles new.
	tileNumber := self topLeftTileNumber.
	tileOffset := osmTiles
			pixelPointAt: aPoint x @ aPoint y
			tile: tileNumber
			zoom: self zoom.
	mx := (tileNumber x - self topLeftTileNumber x) * 256.
	my := (tileNumber y - self topLeftTileNumber y) * 256.
	additionalTilesOffset := mx@my.

	canvasMarginOffset := 20@20.
	canvasSize := (self parent parent measuredBounds extent x)@(self parent parent measuredBounds extent y).
	tilesSize := (self measuredBounds extent x)@(self measuredBounds extent y).
	mapOffset := (tilesSize / 2) - additionalTilesOffset - tileOffset.

	resultTransformation := (canvasSize / 2) - (tilesSize / 2) - canvasMarginOffset + mapOffset.

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
]

{ #category : #accessing }
GtOsmCanvassableMap >> tileDimensions [
	| topLeftTileNumber bottomRightTileNumber |
	
	topLeftTileNumber := self topLeftTileNumber.
	bottomRightTileNumber := self bottomRightTileNumber.

	^ ((topLeftTileNumber x - bottomRightTileNumber x) abs + 1) @
		((topLeftTileNumber y - bottomRightTileNumber y) abs + 1)
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
