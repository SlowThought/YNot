#lang racket
#| "vehicle.rkt" defines the YVehicle class, which holds an individual vehicle's parameters and state.
   It also holds and allows access to parameters common to all vehicles (dimensions, mass, moments
   of inertia?)
   Written by Patrick King. All rights reserved. |#

(require "YObject.rkt")

;; Eventually, we race against an AI or network opponent in an identical vehicle, except for color

(define cockpit? #t)
(define mass-v-kg 115.)
(define zd-m-v 1.5)
(define wheelbase-m 4.)
(define wheeltrack-m 2.)

#| Inertial momentum -- following value is currently garbage.
   Eventually, it will be estimated from above estimates, and modifiable by the user if
   he/she thinks it's important |#

(define I-kg-m^2 230)

(module* test #f
  (require pict3d "fuselage.rkt")
  (render-fuselage wheelbase-m wheeltrack-m zd-m (rgba 1 0 0) 0))

