#lang racket
(require (for-syntax syntax/parse) syntax/parse)

(begin-for-syntax
  (define-syntax-class path-step
    (pattern ((~literal at) key:expr))
    (pattern ((~literal each) key:expr))
    (pattern ((~literal get) (~seq key:expr))))

  (define-syntax-class contract
        #:description "contract hierarchy"
        (pattern #:empty)
        (pattern ((~literal hierarchy/c)
                  [name:str]
                  [step:path-step ...]
                  [type:expr]
                  [next:contract]))))

(define-syntax (foo stx)
  (syntax-parse stx
    [(_ c:contract) #'#t]))

(foo #:empty)
(foo (hierarchy/c
   ["getAll"]
   [(each 'results) (get ('country 'artistName 'wrapperType))]
   [(listof (list/c string? string? string?))]
   [#:empty]))

(foo (hierarchy/c
    ["getCountries"]
    [(each 'results) (get 'country)]
    [(listof string?)]
    [(hierarchy/c
        ["getWrapperTypes"]
        [(each 'results) (get 'wrapperType)]
        [(listof string?)]
        [(hierarchy/c
            ["getArtistNames"]
            [(each 'results) (get 'artistName)]
            [(listof string?)]
            [#:empty])])]))
