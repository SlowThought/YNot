#lang racket
#| Racket Sailing Simulator - Sailwing (/keel?) model
   written by Patrick King, all rights reserved

   Default units are meters, kilograms, seconds

   We use a simple trapezoidal wing. AC located near centroid

      Parameters
          z_d -- deck height - the "boom" sweeps the deck
            b -- sail span
           cr -- root chord
           ct -- tip chord
           xr -- tack location (leading edge of root)is assumed to be at (0, z_d)
           xt -- head location (leading edge of tip) basically defines sweep of LE
           SM -- static margin, default 0.05, places default wing pivot, influences wing moment
      Geometric Properties
            S -- area
            A -- effective aspect ratio, taking into account deck height, ground effect
         z_AC -- height of aerodynamic center (height of centroid)
         x_/4 -- x of quarter chord at z == z_AC (assumed lift origin)
         x_/2 -- x of half chord at z == z_AC (assumed drag origin)
        c_bar -- mean aerodynamic chord
      Aerodynamic Properties
            K -- Induced drag constant
         CL_α -- Lift curve slope (low α)
       CL_max -- Maximum CL
|#

(provide sailwing build-sailwing render-sailwing CL CDI CD0 ; functions
         ρ_air ρ_H2O)                                       ; constants

(require pict3d)

;; Define wing geometry

(struct sailwing
  (zd b cr ct xt SM S A z_AC x_/4 x_/2 x_pivot K Cl/α Cl_max))

(define (build-sailwing z_d b cr ct xt [SM 0.05][Cl_max 1.])
  (let*[(S (* b (/ (+ cr ct) 2)))
        (2b (* 2 (+ b z_d)))
        (Rt (/ ct cr))
        (z_AC (/ (* b 1/3 (add1 (* 2 Rt))) (add1 Rt))) ; neglecting z_d
        (z_AC/b (/ z_AC b))
        (x_AC (* xt z_AC/b))
        (c_bar (+ (* cr z_AC/b)(* ct (- 1 z_AC/b))))
        (A (/ (* 2b 2b) 2 S))] ; Effective aspect ratio, including z_d
  (sailwing
   z_d b cr ct xt SM S
   A ; Aspect ratio A (effective)
   (+ z_AC z_d); Height of aerdynamic center
   (+ x_AC (/ c_bar 4)); Center of lift
   (+ x_AC (/ c_bar 2)); Center of drag
   (+ x_AC (* c_bar (- 0.25 SM))) ; Pivot point
   (/ 1 2.7 A) ; Induced drag coefficient -- e half way between elliptical and rectangular wing
   (* 2 pi (/ A (+ A 2))) ; Lift curve slope
   Cl_max)))

;; Sailwing force coeeficients, relevant constants for air, water

(define ρ_air 1.225) ; kg/m^3
(define ρ_H2O 1000.)  ; kg/m^3

(define (CL α wing)
  #| My logic here is flawed, or maybe aspect ratio of test case is too low to show Clmax. In any case,
     the graph of the test case is physically reasonable enough for us to proceed.
  |#
  (let [(Clmax (sailwing-Cl_max wing))]
    (if (> α 0)
        (min Clmax                       ; lift peak
             (* α (sailwing-Cl/α wing))  ; linear portion of curve
             (* Clmax (cos α)))          ; stall portion of curve
        (max (- Clmax)
             (* α (sailwing-Cl/α wing))
             (* (- Clmax) (cos α))))))

(define (CDI CL wing)
  (* CL CL (sailwing-K wing)))

(define (CD0 α)
  (+ (* 0.01 (cos α)) (abs(sin α))))

(define (CD α wing)
  (let* [(Cl (CL α wing))
         (Cdi (CDI Cl wing))
         (Cd0 (CD0 α))]
    (+ Cdi Cd0)))


(define (render-sailwing sw)
  (let* [(t/2 (/ (sailwing-cr sw) 20))
         (b  (sailwing-b sw))
         (xt (sailwing-xt sw))
         (ct (sailwing-ct sw))
         (cr (sailwing-cr sw))
         (p0 (pos 0 0 0))
         (p1 (pos xt 0 b))
         (p2 (pos (+ xt ct) 0 b))
         (p3 (pos cr 0 0))
         (p4r (pos (/ cr 3) t/2 0))
         (p4l (pos (/ cr 3) (- t/2) 0))]
  (combine
   (triangle p0 p1 p4r)
   (triangle p4r p1 p2)
   (triangle p4r p2 p3)
   (triangle p3 p2 p4l)
   (triangle p2 p1 p4l)
   (triangle p1 p0 p4l))))
       
(module+ test
  (require plot rackunit)
  (define MySail (build-sailwing 0 2.5 1 0.3 0.5))
  (printf "S is ~s~n" (sailwing-S MySail))
  (printf "zd is ~s~n" (sailwing-zd MySail))
  (printf "b is ~s~n" (sailwing-b MySail))
  (printf "z_AC is ~s~n" (sailwing-z_AC MySail))
  (printf "Center of lift is ~s~n" (sailwing-x_/4 MySail))
  (printf "Center of drag is ~s~n" (sailwing-x_/2 MySail))
  (printf "Pivot point is ~s~n" (sailwing-x_pivot MySail))
  (printf "K is ~s~n" (sailwing-K MySail))
  (printf "Cl_α is ~s~n" (sailwing-Cl/α MySail))
  (parameterize ([current-pict3d-width 1024]
                 [current-pict3d-height 1024])
    (combine
     (render-sailwing MySail)
     (light (pos 1/2 1000 500))
     (basis 'camera (point-at (pos 1/2 3 2) (pos 1/3 0 1)))))
  (plot (list (function (λ (alpha) (CL alpha MySail)) #:label "CL")
              (function (λ (alpha) (CD alpha MySail)) #:label "CD"))
        #:x-min (- (/ pi 2))
        #:x-max (/    pi 2)
        #:y-min (- (sailwing-Cl_max MySail))
        #:y-max    (sailwing-Cl_max MySail))
  (plot (function (λ (alpha) (/ (CL alpha MySail)
                                (CD alpha MySail)))
                  0 1/2 #:label "L/D")))