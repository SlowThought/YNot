#lang racket/gui
#| NotImplemented.rkt is part of the YNot sailing simulator. Author Patrick King. All rights reserved.
   YNot is a very crude simulation of a land yacht, intended to explore the effects of
   apparent wind. |#

(provide not-implemented)

(define (not-implemented fn prnt)
  (let [(NotImplemented (new dialog%
                             [label "Not Implemented"]
                             [parent prnt]))]
    (new message%
         [parent NotImplemented]
         [label (string-append fn " not yet implemented.")])
    (send NotImplemented show #t)))

(module+ test
  (not-implemented "TestNotImplemented" #f))
  


