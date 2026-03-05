#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define (null? v)
    (equal? v 'null))

(define/contract (c json)
  (-> jsexpr?
    (list/c (listof string?) (listof string?) (listof (list/c string? string? (listof (listof (list/c string? (or/c string? null?))))))))
    (list
    (for/list ([from (hash-ref (hash-ref json 'stations) 'from)])
            (hash-ref from 'name))
    (for/list ([to (hash-ref (hash-ref json 'stations) 'to)])
            (hash-ref to 'name))
    (for/list ([connection (hash-ref json 'connections)])
        (list
        (hash-ref (hash-ref (hash-ref connection 'from) 'station) 'name)
        (hash-ref (hash-ref (hash-ref connection 'to) 'station) 'name)
        (for/list ([section (hash-ref connection 'sections)])
            (for/list ([passlist (hash-ref (hash-ref section 'journey) 'passList)])
                (list
                (hash-ref (hash-ref passlist 'station) 'name)
                (hash-ref passlist 'arrival))
            )
        )
        )
    )))

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "http://transport.opendata.ch/v1/connections?from=Lausanne&to=Genève"
  c)