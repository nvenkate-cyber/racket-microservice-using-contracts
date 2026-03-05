#lang racket

(struct empty-set ())
(struct hierarchy (key type children))
(struct/dc hierarchy
    [key 'country]
    [type (listof string?)]
    [children (struct/c empty-set)])
