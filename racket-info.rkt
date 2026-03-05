#lang racket
;; 1: Intro
;; 1.1
(substring "the boy out of the country" 4 7)

;; 1.2
(define (extract str)
  (substring str 4 7))

(extract "the boy out of the country")
(extract "the country out of the boy")

;; (enter! "extract.rkt")
;; run enter! in racket- loads code and switches evaluation context
;; to the inside of the module
(extract "the gal out of the city")

;; 1.3
;; can also run file in racket using:
;; racket <src-filename>

;; 2: Racket Essentials
;; 2.1
#t #f ;; booleans
"Benjamin \"Bugsy\" Siegel"
"λx:(μα.α→α).xx"
"Bugs \u0022Figaro\u0022 Bunny"

;; 2.2
; cond - contains sequence of clauses between square brackets (each clause includes test expr and exprs evaluated when held true)
(define (reply-more s)
  (cond [(string-prefix? s "hello ")       
         "hi!"]
        [(string-prefix? s "goodbye ")
         "bye!"]
        [(string-suffix? s "?")
         "I don't know"]
        [else "huh?"]))
(reply-more "hello racket")
(reply-more "goodbye cruel world")
(reply-more "what is your favorite color?")
(reply-more "what is it")


; anonymous functions - lambda
(define (make-add-suffix s2)
  (lambda (s) (string-append s s2)))
; lexically scoped : s2 refers to arg for the call created in the function

; let bindings - only available in the body of let (binding clauses cannot refer to each other)
(let ([x (random 4)]
      [o (random 4)])
  (cond
    [(> x o) "X wins"]
    [(> o x) "O wins"]
    [else "cat's game"]))

; let* allows later clauses to use earlier bindings (of id's)
(let* ([x (random 4)]
      [o (random 4)]
      [diff (number->string (abs (- x o)))])
  (cond
    [(> x o) (string-append "X wins by " diff)]
    [(> o x) (string-append "O wins by " diff)]
    [else "cat's game"]))


;; 2.3: Lists, Iteration, and Recursion
(list-ref (list "hop" "skip" "jump") 0) ; extract by position

; andmap and ormap combine results by anding or oring:
(andmap string? (list "a" "b" "c"))
(andmap string? (list "a" "b" 6))
(ormap string? (list "a" "b" 6))

; multiple lists for map/andmap/ormap
(map (lambda (s n) (substring s 0 n))
     (list "peanuts" "popcorn" "crackerjack")
     (list 6 3 7))

; tail recursion
(define (my-length lst)
  (define (iter lst len)
    (cond
      [(empty? lst) len]
      [else (iter (rest lst) (+ len 1))]))
  ; body of my-length calls iter
  (iter lst 0))
(my-length (list "a" "b" "c"))

; same as:
(define (my-map f lst)
  (for/list ([i lst])
    (f i)))
(my-map (lambda (s) (+ s 1)) (list 1 2 3 4))

;; 2.4: Pairs, Lists, and Racket Syntax
(cons 1 2) ; cons/pair - tuple
(car (cons 1 2)) ; car - first
(cdr (cons 1 2)) ; cdr - rest

(cons (list 2 3) 1)
; vs
(cons 1 (list 2 3))

(cons 0 (cons 1 2)) ; list of number (0) and tuple (1 . 2)

; quote - does same things as list and tuple
; - can also wrap identifiers (symbols):
(quote jane-doe)

(car ''road)
(car '(quote road))

(+ 1 .(2)) ; == (+ 1 2)

(1 . < . 2)
'(1 . < . 2) ; quote


;; 3: Built-in Datatypes
;; 3.2: Numbers
0.5 ; inexact number
#e0.5 ; force parsing - #e (exact) #i (inexact)
#x03BB ; #b (binary), #o (octal), #x (hexadecimal)

(sin 0) ; rational
(sin 1/2) ; not rational

; computation w large exact ints or non-int exact nums more expensive than inexact nums:
(define (sigma f a b)
  (if (= a b)
      0
      (+ (f a) (sigma f (+ a 1) b))))
(time (round (sigma (lambda (x) (/ 1 x)) 1 2000)))
(time (round (sigma (lambda (x) (/ 1.0 x)) 1 2000)))

(= 1 1.0) ; converts inexact -> exact
(eqv? 1 1.0); checks exactness and numerical equality

;; 3.3: Characters
#\u03BB ; #\u - unprintable char - followed by scalar val as hexadecimal num
#\λ ; #\ - printable character followed

(display #\A)

;; 3.4: Strings
(define s (make-string 5 #\.))
(string-set! s 2 #\u03BB) ; changes index 2 to λ

(parameterize ([current-locale "C"])
  (string-locale-upcase "Straße"))    ; ** what does this do? **

;; 3.5: Bytes and Byte Strings
; byte - exact int between 0 and 255 (inclusive)

(bytes-ref #"Apple" 0) ; strings prefixed with #
(make-bytes 3 65)
(define b (make-bytes 2 0))
(bytes-set! b 0 1) ; set 0 index to 1
(bytes-set! b 1 121)

;; 3.6: Symbols
'a
(string->symbol "one, two") ; whitespace or special chars included in identifier by
'\6                         ; quoting with | or \

;; 3.7: Keywords
(define dir (find-system-path 'temp-dir)) ; not '#:temp-dir
(with-output-to-file (build-path dir "stuff.txt")
  (lambda () (printf "example\n"))
  ; optional #:mode arg
  #:mode 'text
  ; optional #:exists
  #:exists 'truncate)

;; 3.8: Pairs and Lists
null ; recognizes empty list

(cons 1 (cons 2 (srcloc "file.rkt" 1 0 1 8))) ; list* used to abbreviate conses that cannot be done using list

(member "Keys"
        '("Florida" "Keys" "U.S.A"))
(assoc 'where
       '((when "3:30") (where "Florida") (who "Mickey")))

(define p (mcons 1 2)) ; mcons - mutable pair
(set-mcar! p 0)

;; 3.9: Vectors
; fixed-length array of arb values

#("a" "b" "c")
#(name (that tune))
#4(balwin bruce)
(vector-ref #(name (that tune)) 1)

;; 3.10: Hash Tables
(define ht (make-hash))
(hash-set! ht "apple" '(red round))
(hash-set! ht "banana" '(yellow long))
(hash-ref ht "apple")
(hash-ref ht "coconut" "not there") ; last arg - failure result

; immutable hash:
(define ht2 #hash(("apple" . red)
                 ("banana" . yellow)))
(hash-ref ht2 "apple")

;; 3.11: Boxes
; single-element vector

(define b1 (box "apple"))
(unbox b1)
(set-box! b1 '(banana boat))


;; 4: Expressions and Definitions
;; 4.3: Function calls

(define (avg lst)
  (/ (apply + lst) (length lst))) ; apply applies func to vals in list

(define (anti-sum lst)
  (apply - 4 lst))
(anti-sum '(1 2 3))

;; 4.4: Functions: Lambda
(define max-mag
  (lambda nums
    (apply max (map magnitude nums))))

(define max-mag1
  (lambda (num . nums)
    (apply max (map magnitude (cons num nums))))) ; specifies at least one element in list

(define greet
  (lambda (given [surname "Smith"])
    (string-append "Hello, " given " " surname))) ; surname default is Smith
(greet "John")
(greet "John" "Doe")

(define greet2
  (lambda (given [surname (if (equal? given "John")
                              "Doe"
                              "Smith")])
    (string-append "Hello, " given " " surname)))
(greet2 "John")
(greet2 "Adam")
(greet2 "John" "Adam")

(define greet3
  (lambda (#:first given #:last surname)
    (string-append "Hello, " given " " surname))) ; defining arg-keyword for surname
(greet3 #:first "John" #:last "Smith") ; need to specify which arg is #:last
(greet3 #:last "Doe" #:first "John")

;; 4.8: Sequencing
(define (print-triangle height)
  (if (zero? height)
      (void)
      (begin
        (display (make-string height #\*))
        (newline)
        (print-triangle (sub1 height))))) ; begin evaluates all exprs in order, returning last expr

;; 4.9: Assignment: set!
(define greeted null)

(define (greet4 name)
  (set! greeted (cons name greeted))
  (string-append "Hello, " name))
(greet4 "Athos")
(greet4 "Porthos")
(greet4 "Aramis")
greeted

;; 4.11: Quasiquote
(quasiquote (1 2 (unquote (+ 1 2)) (unquote (- 5 1))))

(quasiquote (1 2 (unquote-splicing (list (+ 1 2) (- 5 1))) 5))

;; 4.12: Case
(let ([v (random 6)])
  (printf "~a\n" v)
  (case v
    [(0) 'zero]
    [(1) 'one]
    [(2) 'two]
    [else 'many]))

;; 4.13: Parameterize
; dynamic binding of parameter value
(define location (make-parameter "here"))

(parameterize ([location "there"])
  (location))

(parameterize ([location "in a house"])
  (list (location)
        (parameterize ([location "with a mouse"])
          (location))
        (location)))

(let ([get (parameterize ([location "with a fox"])
             (lambda () (location)))])
  (get)) ; directly applying parameter procedure affects only value associated with action parameterize

