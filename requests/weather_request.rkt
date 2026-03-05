#lang racket
(require json)
(require net/url)


(define (get-json url)
  (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))

(define/contract (c json)
  (-> jsexpr?
    (list/c (list/c string? string?) (list/c number? string?) (listof (list/c number? string? string?))))
    ;              name      region       curr_temp  condition each day:avgt  sunrise  sunset
    (list 
        ; name and region:
        (list (hash-ref (hash-ref json 'location) 'name) (hash-ref (hash-ref json 'location) 'region))

        ; current temp and condition:
        (list (hash-ref (hash-ref json 'current) 'temp_f) (hash-ref (hash-ref (hash-ref json 'current) 'condition) 'text))

        ; forecast for each day:
        (for/list ([day (hash-ref (hash-ref json 'forecast) 'forecastday)])
            (list (hash-ref (hash-ref day 'day) 'avgtemp_f)
            (hash-ref (hash-ref day 'astro) 'sunrise)
            (hash-ref (hash-ref day 'astro) 'sunset)))))

; define function that takes in url and contract
(define (get-response url contract)
  (define json (get-json url))
  (contract json))

; main call
(get-response 
  "http://api.weatherapi.com/v1/forecast.json?key=7ae96906839d4c73a80215338261702&q=60202&days=7"
  c)