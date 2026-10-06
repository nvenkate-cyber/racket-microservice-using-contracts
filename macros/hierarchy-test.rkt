#lang racket
(require net/url
         json
         racket/port
         (for-syntax syntax/parse
                     racket/syntax
                     net/url))

(begin-for-syntax
  (define-syntax-class path-step
    #:datum-literals (at each get)
    (pattern (at key:expr))
    (pattern (each key:expr))
    (pattern (get key:expr)))

  (define-syntax-class contract
        #:description "contract hierarchy"
    #:datum-literals (hierarchy/c)
        (pattern #:empty)
        (pattern (hierarchy/c
                  [name:str]
                  [step:path-step ...]
                  [type:expr]
                  [next:contract]))))

(begin-for-syntax
  (define (process-steps paths json-expr)
   (syntax-parse paths
    [() json-expr] ;; return empty
    [[step:path-step rest:path-step ...]
     (syntax-parse #'step
       [((~literal each) key) ; for each
           (with-syntax ([(x) (generate-temporaries '(x))])
             #`(map (lambda (x) #,(process-steps #'(rest ...) #'x))
                    (hash-ref #,json-expr key)))]
       [((~literal at) key)
           (process-steps #'(rest ...) #`(hash-ref #,json-expr key))]
       [((~literal get) key) ; get value
           #`(hash-ref #,json-expr key)])]))

  ; processes hierarchy, saving value as a function
  (define (process-hierarchy hierarchy json-expr)
        (syntax-parse hierarchy
          [(~datum #:empty) #'(begin)] ; end here
          [((~literal hierarchy/c) [name:str] [step:path-step ...] [type:expr] [next:contract])
           (with-syntax* ([id (format-id json-expr "~a" (syntax-e #'name))]
                      [expr (process-steps #'(step ...) json-expr)]
                      [more (process-hierarchy #'next json-expr)])
             #'(begin
                 (define id expr)
                 more))])))


; defines json object and calls hierarchy process
(define-syntax (define-hierarchy stx)
  (syntax-parse stx
    [(_ api-url:str hierarchy:contract)
     (with-syntax* ([json (datum->syntax stx 'json)]
                    [body (process-hierarchy #'hierarchy #'json)])
       #'(begin
           (define json
             (call/input-url (string->url api-url) get-pure-port
                             (compose string->jsexpr port->string)))
           body))]))

(define-hierarchy "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
  (hierarchy/c
   ["getPillarName"]
   [(at 'boxscore) (each 'teams) (get 'homeAway)]
   [(listof string?)]
   [(hierarchy/c
    ["getTeamNames"]
    [(at 'boxscore) (each 'teams) (at 'team) (get 'name)]
    [(listof string?)]
    [#:empty])]))