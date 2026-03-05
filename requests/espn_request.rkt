#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define/contract (c json)
  (-> jsexpr?
    (list/c (listof string?) string?)) ; returns list of team names and field name
    (list 
        (for/list ([team (hash-ref (hash-ref json 'boxscore) 'teams)])
            (hash-ref (hash-ref team 'team) 'displayName))
        (hash-ref (hash-ref (hash-ref json 'gameInfo) 'venue) 'fullName)))

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
  c)