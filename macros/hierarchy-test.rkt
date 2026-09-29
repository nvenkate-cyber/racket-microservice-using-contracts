#lang racket
(require net/url
         json
         racket/port
         (for-syntax syntax/parse
                     racket/syntax
                     net/url))

(begin-for-syntax
  (define-syntax-class path-step
    (pattern ((~literal at) key:expr))
    (pattern ((~literal each) key:expr))
    (pattern ((~literal get) key:expr)))

  (define-syntax-class contract
        #:description "contract hierarchy"
        (pattern #:empty)
        (pattern ((~literal hierarchy/c)
                  [name:str]
                  [step:path-step ...]
                  [type:expr]
                  [next:contract]))))

(begin-for-syntax
  (define (process-steps paths json-expr)
   (syntax-parse paths
    [[] #'json-expr] ;; return empty
    [(step:path-step rest:path-step ...)
     (syntax-parse #'step
       [((~literal each) key) ; for each
           #'(map (lambda (x) #`(process-steps #'(rest ...) x)) (hash-ref json-expr 'key))]
       [((~literal at) key)
           (process-steps #'(rest ...) (hash-ref json-expr 'key))]
       [((~literal get) key) ; get value
           #'(hash-ref json-expr 'key)])]))


  (define (process-hierarchy hierarchy json-expr)
        (syntax-parse hierarchy
          [(~datum #:empty) #'(begin)] ; end here
          [((~literal hierarchy/c) [name:str] [step:path-step ...] [type:expr] [next:contract])
           #`(begin
               #,(process-steps #'(step ...) json-expr)
               #,(process-hierarchy #'next json-expr))]))) ; TODO: check if this can be written as function


(define-syntax (define-hierarchy stx)
  (syntax-parse stx
    [(_ url:str hierarchy:contract)
     #`(begin
         
         #,(process-hierarchy #'hierarchy 
           #'(call/input-url (string->url url)
                           get-pure-port
                           (compose string->jsexpr port->string))))])) ; TODO: use with-syntax to pass json identifier

(define-hierarchy "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2"
  (hierarchy/c
   ["getPillarName"]
   [(at response) (each results) (get pillarName)]
   [(listof string?)]
   [#:empty]))