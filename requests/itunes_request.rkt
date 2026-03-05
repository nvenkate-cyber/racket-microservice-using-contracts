#lang racket
(require json)
(require net/url)

; object type that holds the data from calling service
; (struct content [wrapper-type artist-name country])

; get json response from url
(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))


;(define/contract (c json)
;  (-> jsexpr?
;    (listof (list/c string? string? string?)))
;    (for/list ([cont (hash-ref json 'results)])
;      (list (hash-ref cont 'wrapperType)
;            (hash-ref cont 'artistName)
;            (hash-ref cont 'country)))
;    )

; function takes the json object and keys that need to be iterated over,
; recursively calls through the function to check for the given keys within jexpr
; contract here is to ensure given json and keys conform to appropriate types
(define/contract (c json keys)
  (-> jsexpr?
      (listof symbol?)
      (listof any/c))
  (define (find-key curr-layer k)
    (cond [(hash? curr-layer)
         (if (hash-has-key? curr-layer k)
             (hash-ref curr-layer k)
             (find-key (hash-values curr-layer) k))
         ]
        [(list? curr-layer)
         (foldl (lambda (i acc) (cons (find-key i k) acc)) '() curr-layer)]
        [else '()]))
  (define (find-multiple-keys curr-layer keys)
    (map (lambda (k) (find-key curr-layer k)) keys))
  (find-multiple-keys json keys))

; define function that takes in url and contract
(define (get-response url contract-fn)
  (define json (get-json url))
  (contract-fn json (list 'wrapperType 'artistName 'country)))

; main call
(get-response
 "https://itunes.apple.com/search?term=jack+johnson"
 c)

; recursively look for keys
; (define (find-key curr-layer k)
;   (cond
;     [(hash? curr-layer)
;       (if (hash-has-key? curr-layer k)
;         (hash-ref curr-layer k)
;         (find-key (hash-values curr-layer) k))
;       ]
;     [(list? curr-layer)
;       (foldl (lambda (i acc) (cons (find-key i k) acc)) '() curr-layer)]
;     [else '()]))
; (define (find-multiple-keys curr-layer keys)
;   (map (lambda (k) (find-key curr-layer k)) keys))
; (define main (get-json "https://itunes.apple.com/search?term=jack+johnson"))
; (find-multiple-keys main (list 'wrapperType 'artistName 'country))
