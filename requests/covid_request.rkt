#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define/contract (c json)
  (-> jsexpr?
    (listof (list/c string? string? string?)))
    (for/list ([data (hash-ref json 'rawData)])
        (list
            (hash-ref data 'Country_Region)
            (hash-ref data 'Confirmed)
            (hash-ref data 'Deaths)
        ))
)

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "https://coronavirus.m.pipedream.net"
  c)