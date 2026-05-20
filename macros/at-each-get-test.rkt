#lang racket
(require net/url
         json
         (for-syntax syntax/parse))

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

(define-syntax (foo stx)
   (syntax-parse stx
    [(_ [] json-expr) #'json-expr] ;; return empty
    [(_ [step:path-step rest:path-step ...] json-expr)
     (syntax-parse #'step
       [((~literal each) key) ; for each
           #'(map (lambda (x) (foo [rest ...] x)) (hash-ref json-expr 'key))]
       [((~literal at) key)
           #'(foo [rest ...] (hash-ref json-expr 'key))]
       [((~literal get) key) ; get value
           #'(hash-ref json-expr 'key)])]))

(define url "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2")
(define json
    (call/input-url (string->url url)
            get-pure-port
            (compose string->jsexpr port->string)))

(foo [(at response) (each results) (get pillarName)] json)
; (foo [] json) ; returns original json
