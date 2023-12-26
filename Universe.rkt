#lang racket
(require pict3d
         pict3d/universe
         "cones.rkt"
         "fuselage.rkt"
         "SailWing.rkt"
         "World.rkt")
(provide launch-sim)

(struct State (N E ψ GS ϕ dϕ/dt sa ta))
#| N     -- m north of origin
   E     -- m east of origin
   ψ     -- vehicle heading/course, radians, N == 0, E == Π/2
   GS    -- ground speed, m/s
   ϕ     -- vehicle roll angle, radians
   dϕ/dt -- acceleration in roll, /s
   sa    -- steering angle, radians [-1 .. 1]
   ta    -- trim angle, radians [0 .. Π/2]
|#

;; Top of sim, "safe" space for globals?
(define my-fuse (fuselage 3 1 1/4 1 (pos 2 0 3/16)
                            (rgba 1.0 0.03 0.0))); "Candy apple" red

(define Init-state (State 500 500 45 0 0 (/ pi 2) 0 0))

(define (draw-universe s n t)
  (combine (render-environment)
           (move (rotate-z (render-fuselage my-fuse (State-sa s))
                           (State-ψ s))
                 (dir (State-E s) (State-N s) 0))
           (RCCamera (pos (State-E s) (State-N s) 1/2))))


;; Top event loop
(define (launch-sim)
  (big-bang3d Init-state
              #:on-draw draw-universe
              #:name "YNot"))