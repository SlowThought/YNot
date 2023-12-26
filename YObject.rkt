#lang racket
#| YObject.rkt is part of the YNot sailing simulator. Author Patrick King. All rights reserved.
   YObject provides infrastructure for collision detection, camera management, and rendering |#

(require pict3d "NotImplemented.rkt")
(provide YObject% collided?)

(define YObjects (list))

(define YObject%
  (class object%
    (super-new)
    (init-field x y r)
    (define/public (render)
      (not-implemented "YObject::render" #f))
    (set! YObjects (cons this YObjects))))

(define (pair-collided? Y1 Y2)
  (if (eqv? Y1 Y2) #f
      (let* [(x1 (get-field x Y1))
             (y1 (get-field y Y1))
             (x2 (get-field x Y2))
             (y2 (get-field y Y2))]
        (< (sqrt (+ (sqr (- x1 x2)) (sqr (- y1 y2))))
           (+ (get-field r Y1) (get-field r Y2))))))

(define (collided? Y)
  (let loop [(z (car YObjects))(rest (cdr YObjects))]
    (cond [(null? rest)(pair-collided? Y z)]
          [(pair-collided? Y z) #t]
          [else (loop (car rest)(cdr rest))])))

(module+ test
  (require rackunit)

  (define O (new YObject% [x 1][y 2][r 4]))
  (define P (new YObject% [x 1][y 7][r 1]))

  (check-false (collided? O)))