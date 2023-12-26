#lang racket/gui
#| YNot.rkt is the top module of the YNot sailing simulator. Author Patrick King. All rights reserved.
   YNot is a very crude simulation of a land yacht, intended to explore the effects of
   apparent wind. It may grow into a full racing sim against AI opponents |#
(require "NotImplemented.rkt"
         "wind.rkt")

(define Main (new frame%
                  [label "YNot"]
                  [min-width 500]
                  [min-height 300]
                  [style '(fullscreen-button)]))

;;; The top pane contains the  3D display and the sail controls 
(define TopPane (new horizontal-pane%
                     [alignment '(right top)]
                     [parent Main]))

;;; The bottome pane contains steering controls and most of the instrumentation displays
(define BottomPane (new horizontal-pane%
                        [alignment '(left bottom)]
                        [stretchable-height #f]
                        [parent Main]))


;; 3D window is LHS of TopPane
(define 3DWindow (new panel%
                      [parent TopPane]))
(new message%
     [parent 3DWindow]
     [label "3D window will appear here"])

;;; Sail controls and indicators occur to the right
(define TopRight (new vertical-pane%
                      [stretchable-width #f]
                      [parent TopPane]))
;;; Right Top containees
;; Start/Pause Sim
(new button%
     [label "Start/Pause"]
     [parent TopRight]
     [callback (λ (m c) (not-implemented "Start/Pause" Main))])

(new button%
     [label "&Trim"]
     [parent TopRight]
     [callback (λ (m c) (not-implemented "Trim" Main))])

(new message%
     [label "SCI"] ; Sail control indicator - message is placeholder for eventual pict
     [parent TopRight])

(new button%
     [label "&Ease"]
     [parent TopRight]
     [callback (λ (m c) (not-implemented "Ease" Main))])

(new button%
     [label "&Release"]
     [parent TopRight]
     [callback (λ (m c) (not-implemented "Release" Main))])

;;; Menu Bar

(define MenuBar (new menu-bar%	 
                     [parent Main]))

;; File Menu

(define FileMenu (new menu%
                      [label "File"]
                      [parent MenuBar]))
(new menu-item%
     [label "Load"]
     [parent FileMenu]
     [callback (λ (m c) (not-implemented "File|Load" Main))])
(new menu-item%
     [label "Save"]
     [parent FileMenu]
     [callback (λ (m c) (not-implemented "File|Save" Main))])
(new menu-item%
     [label "E&xit"]
     [parent FileMenu]
     [callback (λ (m c) (exit))])

;; Edit Menu
(define EditMenu (new menu%
                      [label "Edit"]
                      [parent MenuBar]))
; Vehicle
; Winds
(new menu-item%
     [label "Wind"]
     [parent EditMenu]
     [callback (λ (m c) (wind-dlg Main))])
; Course

;; View Menu
; Chase
; RC
; Zoom
; Pan left
; Pan right
; Pan up
; Pan down

;; Help Menu
; Vehicle
; Keyboard shortcuts
; Wind
; Course


;;;; Lower pane -- Steering ctls, GS & WS, compass

(new button%
     [label "<"]
     [parent BottomPane]
     [callback (λ (m c) (not-implemented "TurnLeft" Main))])

(new button%
     [label "/"]
     [parent BottomPane]
     [callback (λ (m c) (not-implemented "CenterSteering" Main))])

(new message%
     [label "SA: [-]XX"]
     [parent BottomPane])

(new button%
     [label ">"]
     [parent BottomPane]
     [callback (λ (m c) (not-implemented "TurnRight" Main))])

(new message%
     [label "][GS: XX.X m/s"]
     [parent BottomPane])

(new message%
     [label "][Compass Display/Wind indicator]["]
     [parent BottomPane])

(new message%
     [label "WS: XX.X m/s"]
     [parent BottomPane])
;;; Left edge - GS Label
;;; Right edge - WS Label
;;; Middle remainder -- Compass pict -- course, apparent wind, next mark

(send Main show #t)
