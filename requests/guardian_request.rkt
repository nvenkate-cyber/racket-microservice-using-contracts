#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define/contract (c json)
  (-> jsexpr?
    (listof (list/c string? string? boolean?)))
    (for/list ([res (hash-ref (hash-ref json 'response) 'results)])
            (list 
            (hash-ref res 'pillarName)
            (hash-ref res 'sectionName)
            (hash-ref res 'isHosted))))

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2"
  c)