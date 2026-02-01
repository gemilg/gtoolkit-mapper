Class {
	#name : 'GtOsmCanvassableMap',
	#superclass : 'BlCanvassableElement',
	#instVars : [
		'topLeftCoordinate',
		'bottomRightCoordinate',
		'zoom',
		'centerCoordinate',
		'tilesContainer',
		'widgets',
		'widgetsLayer',
		'osm'
	],
	#category : 'GToolkit-Mapper-Osm',
	#package : 'GToolkit-Mapper',
	#tag : 'Osm'
}

{ #category : 'draw-canvas' }
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

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> addWidget: aWidget [
	widgets add: aWidget
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> additionalNumberOfTilesAroundCenter [
	"This is the default value of number of tiles above/below/left/right the center tile"
	^ 3
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> bottomRightCoordinate [
	^ bottomRightCoordinate
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> bottomRightCoordinate: aNumber [
	bottomRightCoordinate := aNumber
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> bottomRightTileNumber [

	^ osm getTileNumberLat: bottomRightCoordinate y long: bottomRightCoordinate x zoom: zoom
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> buildTilesContainer [
	| tileDimensions rowContainer centerNumber tiles |
	tileDimensions := self tilesContainerDimensions.
	centerNumber := self centerTileNumber.
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
					file := osm
							asyncFilenameForTileNumber: point
							zoom: zoom
							callback: [ :p :z | 
								Transcript
									show: 'callback ' , p asString , ' 14';
									cr.
								self notifyTileReady: p zoom:z ].
					(file exists and: (osm isFileBeingDownloaded: file) not)
						ifTrue: [ image := (SkiaImage fromFile: file) asElement
									constraintsDo: [ :c | 
										c horizontal matchParent.
										c vertical matchParent ] ]
						ifFalse: [ image := osm emptyTileSkiaImage asElement
									constraintsDo: [ :c | 
										c horizontal matchParent.
										c vertical matchParent ] ].
					rowContainer addChild: image ].
			tiles addChild: rowContainer ].

	^ tiles
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> canvasSize [
	"Return the size in px, of canvas in which the GtOsmCanvassableMap is displayed.
	Most likely, this is the size of inspector canvas."
	^ self parent parent measuredBounds extent x
		@ self parent parent measuredBounds extent y
]

{ #category : 'initialization' }
GtOsmCanvassableMap >> centerCoordinate: aCoordinate [
	centerCoordinate := aCoordinate
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> centerPointCanvassOffset [
	^ (self parent bounds extent) / 2.
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> centerTileNumber [
	^ osm getTileNumberLat: centerCoordinate y long: centerCoordinate x zoom: zoom
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> coordinateToPxOnCanvas: aCoordinate [
	"Calculate px position of aCoordinate on canvas, where 0@0 is the top left corner of center tile in tilesContainer.
	Calculated px position can point to outside of canvas."
	| tileNumber centerTilePxOffset centerTileNumber |
	
	centerTileNumber := osm
			getTileNumberLat: centerCoordinate y
			long: centerCoordinate x
			zoom: self zoom.
	tileNumber := osm
			getTileNumberLat: aCoordinate y
			long: aCoordinate x
			zoom: self zoom.
	centerTilePxOffset := osm
			pixelPointAt: aCoordinate
			tile: tileNumber
			zoom: self zoom.

	^ centerTilePxOffset + ((tileNumber - centerTileNumber) * 256) + (self additionalNumberOfTilesAroundCenter * 256)
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> drawEverything [
	tilesContainer := self buildTilesContainer.

	self
		enqueueTask: [ self addCenterMarker.	"TODO: this should not be enqueued as blTask, but called immediately.
			For some reason, there is a bug that if canvas was not dragged with mouse after drawEverything, the view will not be translated to proper position..."
			self translateViewToPx: (self coordinateToPxOnCanvas: centerCoordinate) ]
				asBlTask.

	self
		size: (self tilesContainerDimensions x * 256)
				@ (self tilesContainerDimensions y * 256);
		addChildFirst: tilesContainer;
		addChild: widgetsLayer.

]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> focusViewOnCoordinate: aCoordinate [
	centerCoordinate := aCoordinate.
	self redrawEverything
]

{ #category : 'accessing' }
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

{ #category : 'accessing' }
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

{ #category : 'initialization' }
GtOsmCanvassableMap >> initialize [
	super initialize.
	osm := GtOpenStreetMapTiles new.
	topLeftCoordinate := 1000 @ -1000.
	bottomRightCoordinate := -1000 @ 1000.
	tilesContainer := BlElement new.
	widgetsLayer := BlElement new.
	widgets := OrderedCollection new.

	widgetsLayer
		size: (self tilesContainerDimensions x * 256)
				@ (self tilesContainerDimensions y * 256).

	self
		when: BlDragEndEvent
		do: [ :evt | 
			centerCoordinate := self pxOnCanvasToCoordinate: self viewCenteredAtPx.
			self focusViewOnCoordinate: centerCoordinate ]
]

{ #category : 'as yet unclassified' }
GtOsmCanvassableMap >> isTileNumberOnCanvas: p [
	^ ((p x >= (self centerTileNumber x - self additionalNumberOfTilesAroundCenter)
		and: p x <= (self centerTileNumber x + self additionalNumberOfTilesAroundCenter))
		and: (p y >= (self centerTileNumber y - self additionalNumberOfTilesAroundCenter)
				and: p y <= (self centerTileNumber y + self additionalNumberOfTilesAroundCenter)))
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> notifyTileReady: p zoom: z [
	| posOnCanvas |
	Transcript
		show: 'Tile ready [' , z asString , ', ' , p asString , ']';
		cr.

	posOnCanvas := self tileNumberToPosOnCanvas: p.
	(posOnCanvas isNotNil and: self zoom = z)
		ifTrue: [ | file |
			file := osm filenameForTileNumber: p zoom: z.
			self replaceTileAt: posOnCanvas with: (SkiaImage fromFile: file) asElement ]
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> pxOnCanvasToCoordinate: aPoint [
	"Calculate coordinate position of aPoint on canvas"

	Transcript show: 'pxOnCanvasToCoordinate centerTileNumber: ', self centerTileNumber asString; cr.
	^ osm
		getCoordinatesForX: self centerTileNumber x
		y: self centerTileNumber y
		zoom: zoom
		pxX: aPoint x - (self additionalNumberOfTilesAroundCenter * 256)
		pxY: aPoint y - (self additionalNumberOfTilesAroundCenter * 256)
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> redrawEverything [
	self removeChild: tilesContainer.
	tilesContainer := self buildTilesContainer.
	self addChildFirst: tilesContainer.
	self translateViewToPx: (self coordinateToPxOnCanvas: centerCoordinate).
	self redrawWidgets
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> redrawWidgets [
	widgetsLayer removeChildren.
	widgets
		do: [ :w | 
			| blEl resultTransformation |
			resultTransformation := self coordinateToPxOnCanvas: w coordinate.
			blEl := w drawWidget.
			blEl relocate: resultTransformation - blEl visualBounds origin + w attachPointOffset.
			widgetsLayer addChild: blEl ]
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> removeWidget: aWidget [
	widgets remove: aWidget
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> replaceTileAt: aPoint with: aBlElement [
	| elementToReplace |
	elementToReplace := (self tilesContainer childAt: aPoint y) childAt: aPoint x.
	(self tilesContainer childAt: aPoint y) replaceChild: elementToReplace with: aBlElement
]

{ #category : 'as yet unclassified' }
GtOsmCanvassableMap >> tileNumberToPosOnCanvas: aPoint [
	(self isTileNumberOnCanvas: aPoint) ifTrue: [ ^ aPoint - self centerTileNumber + self additionalNumberOfTilesAroundCenter + 1] ifFalse: [ ^ nil ]
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> tilesContainer [
	^ tilesContainer
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> tilesContainerCenterPxOffsetFromCanvasCenter [
^ ((self canvasSize / 2) - (self tilesContainerPxSize / 2) - self childrenTranslationFactor)
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> tilesContainerDimensions [
	| dim |
	dim := self additionalNumberOfTilesAroundCenter * 2 + 1.
	^ dim@dim
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> tilesContainerPxSize [
	| px |
	px := 256 * (self additionalNumberOfTilesAroundCenter * 2 + 1).
	^ px@px
]

{ #category : 'view-properties' }
GtOsmCanvassableMap >> tilesExtent [
	^ self measuredBounds extent x @ self measuredBounds extent y
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> topLeftCoordinate [
	^ topLeftCoordinate
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> topLeftCoordinate: aNumber [
	topLeftCoordinate := aNumber
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> topLeftTileNumber [

	^ osm getTileNumberLat: topLeftCoordinate y long: topLeftCoordinate x zoom: zoom
]

{ #category : 'draw-canvas' }
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

{ #category : 'view-properties' }
GtOsmCanvassableMap >> viewCenteredAtPx [
	^ (self canvasSize / 2) - self childrenTranslationFactor.
]

{ #category : 'accessing' }
GtOsmCanvassableMap >> zoom [
	^ zoom
]

{ #category : 'initialization' }
GtOsmCanvassableMap >> zoom: anObject [
	zoom := anObject
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> zoomIn [
	zoom < 19 ifTrue: [ zoom := zoom + 1 ].
	self redrawEverything
]

{ #category : 'draw-canvas' }
GtOsmCanvassableMap >> zoomOut [
	(zoom > 0) ifTrue: [zoom := zoom - 1].
	self redrawEverything
]
