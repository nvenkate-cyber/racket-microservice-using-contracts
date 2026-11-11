#lang racket
(require net/url
         json
         racket/port
         (for-syntax racket/base
                     racket/list
                     syntax/parse
                     racket/syntax))

(begin-for-syntax
  (define-syntax-class path-step
    (pattern (kind:id key:expr)
             #:fail-unless (memq (syntax-e #'kind) '(at each get))
             "expected (at key), (each key) or (get key)"))

  (define-syntax-class contract
    #:description "contract hierarchy"
    #:attributes ()
    (pattern ((~datum hierarchy/c)
              [step:path-step (~optional (~seq #:name name:str))]))
    (pattern ((~datum hierarchy/c)
              [step:path-step (~optional (~seq #:name name:str))]
              [child:contract ...])))

  ;; path: list of (kind-symbol . key-syntax), root first
  (define (build-expr path e)
    (cond
      [(null? path) e]
      [else
       (define kind (car (car path)))
       (define key  (cdr (car path)))
       (define next #`(hash-ref #,e #,key))
       (if (eq? kind 'each)
           (with-syntax ([(x) (generate-temporaries '(x))])
             #`(map (lambda (x) #,(build-expr (cdr path) #'x)) #,next))
           (build-expr (cdr path) next))]))

  ;; (define name (delay <expr over (force json)>))
  (define (make-def name-str path json-id)
    #`(define #,(format-id json-id "~a" name-str)
        (thunk
          #,(build-expr path #`(#,json-id)))))

  ;; returns a list of (define ...) forms
  (define (process-hierarchy h path json-id)
    (syntax-parse h
      [((~datum hierarchy/c)
        [step:path-step (~optional (~seq #:name name:str))])
       (define new-path
         (append path (list (cons (syntax-e #'step.kind) #'step.key))))
       (if (attribute name)
          (list (make-def (syntax-e #'name) new-path json-id))
          '())]
      [((~datum hierarchy/c)
        [step:path-step (~optional (~seq #:name name:str))]
        [child ...])
       (define new-path
         (append path (list (cons (syntax-e #'step.kind) #'step.key))))
       (append
        (if (attribute name)
            (list (make-def (syntax-e #'name) new-path json-id))
            '())
        (append-map (lambda (c) (process-hierarchy c new-path json-id))
                    (syntax->list #'(child ...))))])))

(define-syntax (define-hierarchy stx)
  (syntax-parse stx
    [(_ api-url:str h:contract)
     (define json-id (datum->syntax stx 'json))
     #`(begin
         (define #,json-id
           (thunk
             (call/input-url (string->url api-url) get-pure-port
                             (compose string->jsexpr port->string))))
         #,@(process-hierarchy #'h '() json-id))]))

(define-hierarchy
  "https://site.web.api.espn.com/apis/site/v2/sports/football/nfl/summary?region=us&lang=en&contentorigin=espn&event=401772984"
  (hierarchy/c
   [(at 'boxscore) #:name "atFunction"] ;; string names can be identifiers, attach contracts here
   [(hierarchy/c
     [(each 'teams)]
     [(hierarchy/c
       [(get 'homeAway) #:name "getPillarName"])
      (hierarchy/c
       [(at 'team)]
       [(hierarchy/c
         [(get 'name) #:name "getTeamNames"])])
      ])]))

(getPillarName)   ; '("away" "home")
getTeamNames    ; '("49ers" "Seahawks")