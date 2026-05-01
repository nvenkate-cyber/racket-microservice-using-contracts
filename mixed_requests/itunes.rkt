#lang racket
(require json)
(require net/url)

; hierarchy contract (user experience)
; args: name, key, type, children
; children can be #:empty or nested hierarchy/c
(require "https://itunes.apple.com/search?term=jack+johnson"
    (hierarchy/c
   ["getAll"]
   [(each 'results (get 'country 'artistName 'wrapperType))]
   [(listof (list/c string? string? string?))]
   [#:empty]))

; exapanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define url "https://itunes.apple.com/search?term=jack+johnson")
(define json
    (call/input-url (string->url url)
        get-pure-port
        (compose string->jsexpr port->string)))
(define results
  (for/list ([res (hash-ref json 'results)])
    (list
     (hash-ref res 'country)
     (hash-ref res 'artistName)
     (hash-ref res 'wrapperType))))
(eval '(define getAll results) ns)

; separate functions
(require "https://itunes.apple.com/search?term=jack+johnson"
    (hierarchy/c
    ["getCountries"]
    ['results['country]]
    [(listof string?)]
    [(hierarchy/c
        ["getWrapperTypes"]
        ['results['wrapperType]]
        [(listof string?)]
        [(hierarchy/c
            ["getArtistNames"]
            ['results['artistName]]
            [(listof string?)]
            [#:empty])])]))

(require "https://itunes.apple.com/search?term=jack+johnson"
    (hierarchy/c
    ["getCountries"]
    [(each 'results (get 'country))]
    [(listof string?)]
    [(hierarchy/c
        ["getWrapperTypes"]
        [(each 'results (get 'wrapperType))]
        [(listof string?)]
        [(hierarchy/c
            ["getArtistNames"]
            [(each 'results (get 'artistName))]
            [(listof string?)]
            [#:empty])])]))

; expanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define url "https://itunes.apple.com/search?term=jack+johnson")
(define json
    (call/input-url (string->url url)
        get-pure-port
        (compose string->jsexpr port->string)))
(define results-countries
  (for/list ([res (hash-ref json 'results)])
     (hash-ref res 'country)))
(define results-wrapperTypes
  (for/list ([res (hash-ref json 'results)])
     (hash-ref res 'wrapperType)))
(define results-artistNames
  (for/list ([res (hash-ref json 'results)])
     (hash-ref res 'artistName)))
(eval '(define (getCountries) results-countries) ns)
(eval '(define (getWrapperTypes) results-wrapperTypes) ns)
(eval '(define (getArtistNames) results-artistNames) ns)
