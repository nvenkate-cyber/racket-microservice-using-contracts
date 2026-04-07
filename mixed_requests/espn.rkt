#lang racket
(require json)
(require net/url)

; hierarchy contract (user experience)
; args: name, key, type, children
; children can be #:empty or nested hierarchy/c
(require "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
    (hierarchy/c
   ["getCurrCondition"]
   [list ('current.'temp_f) ('current.'condition.'text)]
   [(listof number? string?)]
   [(hierarchy/c
       ["getForecasts"]
       ['forecast.'forecastday[(list ('day.'avgtemp_f) ('astro.'sunrise) ('astro.'sunrise))]]
       [(listof (list/c number? string? string?))]
       [#:empty]
       )]))

; exapanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define json (call/input-url (string->url "http://api.weatherapi.com/v1/forecast.json?key=7ae96906839d4c73a80215338261702&q=60202&days=7")
    get-pure-port
    (compose string->jsexpr port->string)))
(define results-currCondition
    (list (hash-ref (hash-ref json 'current) 'temp_f)
        (hash-ref (hash-ref (hash-ref json 'current) 'condition) 'text)))
(define results-forecasts
    (for/list ([day (hash-ref (hash-ref json 'forecast) 'forecastday)])
        (list (hash-ref (hash-ref day 'day) 'avgtemp_f)
        (hash-ref (hash-ref day 'astro) 'sunrise)
        (hash-ref (hash-ref day 'astro) 'sunset))))
(eval '(define getCurrCondition results-currCondition) ns)
(eval '(define getForecasts results-forecasts) ns)
