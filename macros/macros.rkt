#lang racket

(define-syntax (define-heirarchy stx)
   (syntax-parse stx
    [(import url:str hierarchy)
    (begin
        (define json
            (call/input-url (string->url url)
                get-pure-port
                (compose string->jsexpr port->string)))
    )]))

; syntax class
; call json with syntax
