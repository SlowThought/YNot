#lang racket
;;; wind.rkt -- wind model for YNot sailing simulator. Written by Patrick King, all rights reserved.

(provide build-wind-model true-wind wind-dlg)
(require plot racket/gui/base)

;; Size of grid

(define n 19)
(define ds (/ 1000. (sub1 n))) ; Playground is 1 km x 1 km. Corners & edges contain nodes

;; Average velocity, stream function, gust, initially 4 m/s gust 4 m/s (roughly  a steady 9 mph)
(define v_avg 4.) 
(define gust_factor 4.)

(define (random-component) 
  (* (- gust_factor v_avg) (random)))

(define (default-psi n e)
  (+ (* -1 v_avg e)        ; n(orth) and e(ast) in meters from origin
     (random-component)))  ; (SW corner of play area)

;; matrix utilities

(define (build-matrix m n f) ; m rows, n columns. Matrix is padded to accomodate lu-value
  (build-vector (add1 m) (λ (r)
                    (build-vector (add1 n) (λ (c) (f r c))))))

(define (matrix-ref mtx row clm)
  (vector-ref (vector-ref mtx row) clm))

(define (matrix-set! mtx row clm value)
  (vector-set! (vector-ref mtx row) clm value))

(define (lu-value mtx N E)
  (let* [(i (inexact->exact (floor (/ E ds))))
         (j (inexact->exact (floor (/ N ds))))
         (dx (- E (* i ds)))
         (dy (- N (* j ds)))
         (ds-dx (- ds dx))
         (ds-dy (- ds dy))]
    ; Weighted average of 4 corner values
    (/ (+ (* ds-dx ds-dy (matrix-ref mtx i j))
          (* ds-dx dy    (matrix-ref mtx i (add1 j)))
          (* dx ds-dy    (matrix-ref mtx (add1 i) j))
          (* dx dy       (matrix-ref mtx (add1 i) (add1 j))))
       ds ds)))

;; Stream and velocity fields

(define ψ 'undef)
(define u 'undef)
(define v 'undef)

;; Fill the fields

(define (build-wind-model vavg [gf 0.5]) ; Wind is assumed to come from the North
  (set! v_avg (- vavg))
  (set! gust_factor (* vavg gf))
  ; Define ψ, fill matrix
  (set! ψ (build-matrix n n (λ (i j) (default-psi (* i ds)(* j ds)))))
  ; Make N & S borders match to accommodate drift of wind field
  ; Must account for rows 0,1 & n-1, n to accomdate lu-value
  (for [(s (in-range 2))
        (n (in-range (sub1 n) n))]
    (for [(c (in-range n))]
      (matrix-set! ψ s c
                   (matrix-ref ψ n c))))
;  This section makes things TOO smooth -- work on generation of original random ψ 
;  ; Refine interior values to observe Laplace equation
;  (for* [(k (in-range 3))
;         (i (in-range 1 n)) ; got rid of (sub1 n) because of lu-value padding
;         (j (in-range 1 n))]
;    (matrix-set!  ψ i j
;                 (/ (+ (matrix-ref ψ (add1 i) j)
;                       (matrix-ref ψ (sub1 i) j)
;                       (matrix-ref ψ i (add1 j))
;                       (matrix-ref ψ i (sub1 j)))
;                    4)))
  ;; Fill wind field
  ; u = dψ/dN = wind velocity in E direction
  (set! u (build-matrix
           n n (λ (i j) (cond
                          [(equal? i 0) (/ (- (matrix-ref ψ (add1 i) j)(matrix-ref ψ i j)) ds)]
                          [(equal? i n) (/ (- (matrix-ref ψ i j)(matrix-ref ψ (sub1 i) j)) ds)]
                          [#t (/ (- (matrix-ref ψ (add1 i) j)(matrix-ref ψ (sub1 i) j)) 2. ds)]))))
  ; v = -dψ/dE = wind velocity in N direction
  (set! v (build-matrix
           n n (λ (i j) (cond
                          [(equal? j 0) (/ (-(matrix-ref ψ i j)(matrix-ref ψ i (add1 j))) ds)]
                          [(equal? j n) (/ (-(matrix-ref ψ i (sub1 j))(matrix-ref ψ i j)) ds)]
                          [#t (/ (- (matrix-ref ψ i (sub1 j))(matrix-ref ψ i (add1 j))) 2. ds)])))))

(define (true-wind n e t)
  (let*[(m (+ n (* v_avg t))) ; upstream lookup location, real
        (int_m (floor m))     ; integer part of m
        (frac_m (- m int_m))  ; fractional part of m
        (displaced-n (+ (modulo int_m 1000) frac_m))] ; real value in range (0. 1000.)
    (vector (lu-value u displaced-n e) (lu-value v displaced-n e))))

(define (wind-dlg [parent #f])
  (send (new dialog%
             (label "Wind")
             (parent parent))
        show #t))

(module* test #f
  (require rackunit)
  ; Validate lu-value - If -999 values are in output, then padding of matrix size isn't working
  (let [(test-mtx #(#(1 2 -999)
                    #(4 8 -999)
                    #(-999 -999 -999)))]
    (check-eqv? (lu-value test-mtx 0. 0.) 1.)
    (check-eqv? (lu-value test-mtx ds 0.) 2.)
    (check-eqv? (lu-value test-mtx 0. ds) 4.)
    (check-eqv? (lu-value test-mtx ds ds) 8.)
    (check-= (lu-value test-mtx (/ ds 2) (/ ds 2)) (/ 15. 4) 0.0001))
  ; Do streamlines make sense?
  (build-wind-model 10. 15.)
  (plot (contours (λ (x y) (lu-value ψ x y)) 0 1000 0 1000 #:levels 10))
  ; Do velocity vectors make sense?
  (plot (vector-field (λ (N E) (true-wind N E 9999)) 0 1000 0 1000))
  ; Does dialog work: looks, enforcement of wind generation logic?
  (wind-dlg))