#lang racket
(require json)
(require net/url)

; hierarchy contract (user experience)
; args: name, key, type, children
; children can be #:empty or nested hierarchy/c
(require "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2"
    (hierarchy/c
   ["getAll"]
   ['response.'results(list 'pillarName 'sectionName 'isHosted)]
   [(listof (list/c string? string? string?))]
   [#:empty]))
; exapanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define json (call/input-url (string->url "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2")
                             get-pure-port
                             (compose string->jsexpr port->string)))
(define results
  (for/list ([res (hash-ref (hash-ref json 'response) 'results)])
    (list
     (hash-ref res 'pillarName)
     (hash-ref res 'sectionName)
     (hash-ref res 'isHosted))))
(eval '(define getAll results) ns)


; separate functions
(require "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2"
    (hierarchy/c
    ["getPillars"]
    ['response.'results['pillarName]]
    [(listof string?)]
    [(hierarchy/c
        ["getSections"]
        ['response.'results['pillarName]]
        [(listof string?)]
        [(hierarchy/c
            ["getIsHosted"]
            ['response.'results['isHosted]]
            [(listof string?)]
            [#:empty])])]))

; expanded version:
(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
(define json (call/input-url (string->url "https://content.guardianapis.com/search?tag=environment/recycling&api-key=df8faaab-b349-41a0-b634-e5a6bbd6e7e2")
                            get-pure-port
                            (compose string->jsexpr port->string)))
(define results-pillarName
  (for/list ([res (hash-ref (hash-ref json 'response) 'results)])
     (hash-ref res 'pillarName)))
(define results-sectionName
  (for/list ([res (hash-ref (hash-ref json 'response) 'results)])
     (hash-ref res 'sectionName)))
(define results-isHosted
  (for/list ([res (hash-ref (hash-ref json 'response) 'results)])
     (hash-ref res 'isHosted)))
(eval '(define getPillars results-pillarName) ns)
(eval '(define getSections results-sectionName) ns)
(eval '(define getIsHosted results-isHosted) ns)
