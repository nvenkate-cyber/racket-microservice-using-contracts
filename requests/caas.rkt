#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define/contract (c json)
  (-> jsexpr?
    (listof string?))
    (for/fold ([acc '()]) ([cat json])
        (append (hash-ref cat 'tags) acc)
    ))

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "https://cataas.com/api/cats?limit=10&skip=0"
  c)