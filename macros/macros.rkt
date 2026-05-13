#lang racket

(begin-for-syntax
    ; match with path such as: [(at 'response) (each 'results) (get 'pillarName 'sectionName 'isHosted)]
    (define-syntax-class path-step
        (pattern ((~literal at) key:expr))
        (pattern ((~literal each) key:expr))
        (pattern ((~literal get) key:expr ...)))

    ; match with hierarchy/c or #:empty
    (define-syntax-class contract
        #:description "contract hierarchy"
        (pattern (~datum #:empty))
        (pattern ((~literal hierarchy/c)
                  [name:str]
                  [step:path-step ...]
                  [type:expr]
                  [next:contract])))

    ; go through steps in hierarchy, get values from json obj
    (define (process-steps steps json-expr)
        (syntax-parse steps
          [() json-expr] ; empty - return json
          [((~literal at) key rest ...) ; at - recurse through curr json
           (process-steps #'(rest ...) #'(hash-ref #,json-expr key))]
          [((~literal each) key rest ...) ; each - loop through curr list
           #'(for/list ([item (hash-ref #,json-expr key)])
               #,(process-steps #'(rest ...) #'item))]
          [((~literal get) key ...) ; TODO: gets only first key
           #'(hash-ref #,json-expr 'key)]))

    ; recurse through each hierarchy
    (define (process-hierarchy hierarchy json-expr)
        (syntax-parse hierarchy
          [(~datum #:empty) #'(begin)] ; end here
          [((~literal hierarchy/c) [name:str] [step:path-step ...] [type:expr] [next:contract])
           (define result (process-steps #'(step ...) json-expr))
           #'(begin
               (define #,(string->symbol name) #,result)
               #,(process-hierarchy #'next json-expr))]))
)

; main
(define-syntax (define-heirarchy stx)
   (syntax-parse stx
    [(_ url:str hierarchy:contract)
     (define json
        (call/input-url (string->url url)
            get-pure-port
            (compose string->jsexpr port->string)))
     #'(process-hierarchy #'hierarchy #'json)
    ]))
