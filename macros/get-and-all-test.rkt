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
    [(_ [steps:path-step] json-expr) ;; get value
     #'(hash-ref json-expr 'steps.key)
    ]))

(define url "https://itunes.apple.com/search?term=jack+johnson")
(define json
    (call/input-url (string->url url)
            get-pure-port
            (compose string->jsexpr port->string)))

(foo [(get resultCount)] json) ; returns 54
; (foo [] json) ; returns original json
