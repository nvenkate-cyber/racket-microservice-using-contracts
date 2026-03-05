#lang racket

(require racket
         (for-syntax syntax/parse))

(provide (except-out (all-from-out racket) #%module-begin))

(define-syntax (begin-program stx)
    (syntax-parse stx
        [(_ body ...)
        #'(#%module-begin body ...)]))

(provide (rename-out [begin-program #%module-begin]))
