#lang racket
(require (for-syntax syntax/parse) syntax/parse)

(begin-for-syntax
 (define-syntax-class path
  (pattern ((~literal at) key:expr))
  (pattern ((~literal each) key:expr))
  (pattern ((~literal get) (~seq key:expr)))))

(define-syntax (foo stx)
  (syntax-parse stx
    [(_ p:path) #'#t]))

(foo (each 'hi))
(foo (at 'hi))
(foo (get ('hi 'bye)))
