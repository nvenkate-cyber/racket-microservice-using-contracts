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
                  [step:path-step (~optional (~seq #:name name:str))]
                  [children:contract ...]))))

(begin-for-syntax
  (define (process-step step json-expr)
   (syntax-parse step
       [((~literal each) key) ; for each
           #`(hash-ref #,json-expr key)]
       [((~literal at) key)
           #`(hash-ref #,json-expr key)]
       [((~literal get) key) ; get value
           #`(hash-ref #,json-expr key)]))

  (define (get-key step)
    (syntax-parse step
       [((~literal each) key) ; for each
           #`key]
       [((~literal at) key)
           #`key]
       [((~literal get) key) ; get value
           #`key]))

  (define (process-children json-expr children)
  (syntax-parse children
    [(curr:contract ...)
     #`(begin
         #,@(for/list ([child (in-list (syntax->list #'(curr ...)))])
              (process-hierarchy child json-expr)))]))

  ; processes hierarchy, saving value as a function
  (define (process-hierarchy hierarchy json-expr)
        (syntax-parse hierarchy
          [(~datum #:empty) #'(begin)] ; end here
          [((~literal hierarchy/c) [step:path-step (~optional (~seq #:name name:str)
                                                              #:defaults ([name #'#f]))]
                                   [children:contract ...])
           (with-syntax* ([id (if (eq? (syntax-e #'name) #f)
                                  (generate-temporary)
                                  (format-id json-expr "~a" (syntax-e #'name)))]
                      [expr (process-step #'step json-expr)] ; when going through children, use hash-ref of json-expr at step
                      [key (get-key #'step)]
                      [more (process-children #'(children ...) (hash-ref json-expr #'key))]
                      )
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

; (define-hierarchy "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
;   (hierarchy/c
;    ["getPillarName"]
;    [(at 'boxscore) (each 'teams) (get 'homeAway)]
;    [(listof string?)]
;    [(hierarchy/c
;     ["getTeamNames"]
;     [(at 'boxscore) (each 'teams) (at 'team) (get 'name)]
;     [(listof string?)]
;     [#:empty])]))


(define-hierarchy
  "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
  (hierarchy/c
   [(at 'boxscore) #:name "atFunction"]
   [(hierarchy/c
     [(each 'teams)]
     [(hierarchy/c
       [(get 'homeAway) #:name "getPillarName"]
       [#:empty])
      (hierarchy/c
       [(at 'team)]
       [(hierarchy/c
         [(get 'name) #:name "getTeamNames"]
         [#:empty])])
      #:empty])]))
