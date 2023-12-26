#lang racket
#| All the fixed props in YNot simulator -- written by Patrick King, all rights reserved

   Everything(?) is in the E-N-Z (global) coordinate system

|#

(require pict3d)

(provide render-environment)

(define Sky
  (with-material (material #:ambient 0.1 #:diffuse 0.1 #:specular 0.4)
    (with-color (rgba "Sky Blue")
      (sphere (pos 500 500 0) 1500  #:inside? #t))))

(define Ground (material #:ambient 0.6 #:diffuse 0.0 #:specular 0.4 #:roughness 0.5))

(define Pavement
  (with-material Ground 
    (with-color (rgba "Gray")
      (rectangle (pos 0 0 0) (pos 1000 1000 -1)))))

(define Grass
  (with-material Ground
    (with-color (rgba "Dark Green")
      (combine
       (rectangle (pos 0 -500 -1) (pos 1500 0 0))
       (rectangle (pos 1000 0 -1) (pos 1500 1500 0))
       (rectangle (pos 1000 1000 0)(pos -500 1500 -1))
       (rectangle (pos -500 1000 0)(pos 0 -500 -1))))))

(define Sun (light (pos 0 0  1300))) ; just inside Sky sphere



(define (render-environment)
  (combine Sky Pavement Grass Sun))

(module+ test
  (require rackunit)
  (combine (basis 'camera (point-at (pos 505 500 3/2) (pos 520 520 2)))
           (render-environment)))