Class {
	#name : #GtOsmCanvassableMap,
	#superclass : #BlCanvassableElement,
	#instVars : [
		'topLeftCoordinate',
		'bottomRightCoordinate',
		'zoom',
		'centerCoordinate',
		'tilesContainer',
		'widgets',
		'widgetsLayer'
	],
	#category : #'GToolkit-Mapper-Osm'
}

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> addCenterMarker [
	| marker horizontal vertical |
	horizontal := BlElement new
			geometry: (BlLineGeometry from: 0 @ 10 to: 20 @ 10);
			border: (BlBorder paint: Color red).
	vertical := BlElement new
			geometry: (BlLineGeometry from: 10 @ 0 to: 10 @ 20);
			border: (BlBorder paint: Color red).
	marker := BlElement new 
		relocate: (self centerPointCanvassOffset - (10@10));
		addChild: horizontal;
		addChild: vertical.
		
	self parent addChild: marker
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> addWidget: aWidget [
	widgets add: aWidget
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> additionalNumberOfTilesAroundCenter [
	"This is the default value of number of tiles above/below/left/right the center tile"
	^ 3
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

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> buildTilesContainer [
	| osm tileDimensions rowContainer centerNumber tiles |
	tileDimensions := self tilesContainerDimensions.
	centerNumber := self centerTileNumber.
	osm := GtOpenStreetMapTiles new.
	tiles := BlElement new
			size: (tileDimensions x * 256) @ (tileDimensions y * 256);
			layout: BlGridLayout vertical.

	1
		to: tileDimensions y
		do: [ :y | 
			rowContainer := BlElement new
					size: (tileDimensions x * 256) @ 256;
					layout: BlGridLayout horizontal.
			1
				to: tileDimensions x
				do: [ :x | 
					| point file image |
					point := (centerNumber x + x - self additionalNumberOfTilesAroundCenter - 1)
							@ (centerNumber y + y - self additionalNumberOfTilesAroundCenter - 1).
					file := osm filenameForTileNumber: point zoom: zoom.
					image := (SkiaImage fromFile: file) asElement
							constraintsDo: [ :c | 
								c horizontal matchParent.
								c vertical matchParent ].
					rowContainer addChild: image ].
			tiles addChild: rowContainer ].

	^ tiles
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> canvasSize [
	"Return the size in px, of canvas in which the GtOsmCanvassableMap is displayed.
	Most likely, this is the size of inspector canvas."
	^ self parent parent measuredBounds extent x
		@ self parent parent measuredBounds extent y
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> centerCoordinate: aCoordinate [
	centerCoordinate := aCoordinate
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> centerPointCanvassOffset [
	^ (self parent bounds extent) / 2.
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> centerTileNumber [
	^ GtOpenStreetMapTiles new getTileNumberLat: centerCoordinate y long: centerCoordinate x zoom: zoom
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> coordinateToPxOnCanvas: aCoordinate [
	"Calculate px position of aCoordinate on canvas, where 0@0 is the top left corner of center tile in tilesContainer.
	Calculated px position can point to outside of canvas."
	| osmTiles tileNumber centerTilePxOffset centerTileNumber |
	osmTiles := GtOpenStreetMapTiles new.
	
	centerTileNumber := osmTiles
			getTileNumberLat: centerCoordinate y
			long: centerCoordinate x
			zoom: self zoom.
	tileNumber := osmTiles
			getTileNumberLat: aCoordinate y
			long: aCoordinate x
			zoom: self zoom.
	centerTilePxOffset := osmTiles
			pixelPointAt: aCoordinate
			tile: tileNumber
			zoom: self zoom.

	^ centerTilePxOffset + ((tileNumber - centerTileNumber) * 256) + (self additionalNumberOfTilesAroundCenter * 256)
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> drawEverything [
	tilesContainer := self buildTilesContainer.

	self
		enqueueTask: [ self addCenterMarker.	"TODO: this should not be enqueued as blTask, but called immediately.
			For some reason, there is a bug that if canvas was not dragged with mouse after drawEverything, the view will not be translated to proper position..."
			self translateViewToPx: (self coordinateToPxOnCanvas: centerCoordinate) ]
				asBlTask.

	widgetsLayer
		size: (self tilesContainerDimensions x * 256)
				@ (self tilesContainerDimensions y * 256).

	self
		size: (self tilesContainerDimensions x * 256)
				@ (self tilesContainerDimensions y * 256);
		addChildFirst: tilesContainer;
		addChild: widgetsLayer.

	self
		when: BlDragEndEvent
		do: [ :evt |
			centerCoordinate := self pxOnCanvasToCoordinate: self viewCenteredAtPx.
			self focusViewOnCoordinate: centerCoordinate
		]
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> focusViewOnCoordinate: aCoordinate [
	centerCoordinate := aCoordinate.
	self removeChild: tilesContainer.
	tilesContainer := self buildTilesContainer.
	self addChildFirst: tilesContainer.
	self translateViewToPx: (self coordinateToPxOnCanvas: centerCoordinate).
	self redrawWidgets.
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
	tilesContainer := BlElement new.
	widgetsLayer := BlElement new.
	widgets := OrderedCollection new
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> pxOnCanvasToCoordinate: aPoint [
	"Calculate coordinate position of aPoint on canvas"
	| osm |
	osm := GtOpenStreetMapTiles new.
	Transcript show: 'pxOnCanvasToCoordinate centerTileNumber: ', self centerTileNumber asString; cr.
	^ osm
		getCoordinatesForX: self centerTileNumber x
		y: self centerTileNumber y
		zoom: zoom
		pxX: aPoint x - (self additionalNumberOfTilesAroundCenter * 256)
		pxY: aPoint y - (self additionalNumberOfTilesAroundCenter * 256)
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> redrawWidgets [
	widgetsLayer removeChildren.
	widgets
		do: [ :w | 
			| blEl resultTransformation |
			resultTransformation := self coordinateToPxOnCanvas: w coordinate.
			blEl := w drawWidget.
			blEl relocate: resultTransformation - blEl visualBounds origin.
			widgetsLayer addChild: blEl ]
]

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> removeWidget: aWidget [
	widgets remove: aWidget
]

{ #category : #accessing }
GtOsmCanvassableMap >> tilesContainer [
	^ tilesContainer
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> tilesContainerCenterPxOffsetFromCanvasCenter [
^ ((self canvasSize / 2) - (self tilesContainerPxSize / 2) - self childrenTranslationFactor)
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> tilesContainerDimensions [
	| dim |
	dim := self additionalNumberOfTilesAroundCenter * 2 + 1.
	^ dim@dim
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> tilesContainerPxSize [
	| px |
	px := 256 * (self additionalNumberOfTilesAroundCenter * 2 + 1).
	^ px@px
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> tilesExtent [
	^ self measuredBounds extent x @ self measuredBounds extent y
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

{ #category : #'draw-canvas' }
GtOsmCanvassableMap >> translateViewToPx: aPoint [
	"Translate the view where the center of inspector live view is at aPoint"
	
	"TODO: this should not be enqueued as blTask, but called immediately.
	For some reason, there is a bug that if canvas was not dragged with mouse after drawEverything, the view will not be translated to proper position..."
	"self
		enqueueTask: [
			self childrenTranslationFactor: self canvasSize / 2 - aPoint.
			] asBlTask.
			"
	self childrenTranslationFactor: self canvasSize / 2 - aPoint.
]

{ #category : #'as yet unclassified' }
GtOsmCanvassableMap >> updateZoom: aNumber [
	self zoom: aNumber.
]

{ #category : #'view-properties' }
GtOsmCanvassableMap >> viewCenteredAtPx [
	^ (self canvasSize / 2) - self childrenTranslationFactor.
]

{ #category : #accessing }
GtOsmCanvassableMap >> zoom [
	^ zoom
]

{ #category : #accessing }
GtOsmCanvassableMap >> zoom: anObject [
	zoom := anObject
]
