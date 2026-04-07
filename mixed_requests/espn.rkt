#lang racket
(require json)
(require net/url)

; hierarchy contract (user experience)
; args: name, key, type, children
; children can be #:empty or nested hierarchy/c
; (require "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
;     (hierarchy/c
;    ["getTeams"]
;    ['boxscore.'teams['team.'displayName]]
;    [(listof string?)]
;    [(hierarchy/c
;        ["getVenue"]
;        ['gameInfo.'venue.'fullName]
;        [string?]
;        [#:empty]
;        )]))

; exapanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define json (call/input-url (string->url "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984")
    get-pure-port
    (compose string->jsexpr port->string)))
(define results-teams
    (for/list ([team (hash-ref (hash-ref json 'boxscore) 'teams)])
        (hash-ref (hash-ref team 'team) 'displayName)))
(define results-venue
    (hash-ref (hash-ref (hash-ref json 'gameInfo) 'venue) 'fullName))
(eval '(define (getTeams) results-teams) ns)
(eval '(define (getVenue) results-venue) ns)
