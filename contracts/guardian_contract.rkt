(struct empty-set ())
(struct hierarchy (name key type children))

; get separate functions
(struct/dc hierarchy
    [name "getPillars"]
    [key 'response.'results['pillarName]]
    [type (listof string?)]
    [children (struct/dc hierarchy
        [name "getSections"]
        [key 'response.'results['pillarName]]
        [type (listof string?)]
        [children (struct/dc hierarchy
            [name "getIsHosted"]
            [key 'response.'results['isHosted]]
            [type (listof string?)]
            [children (struct/c empty-set)])])])

; combine all into one function
(struct/dc hierarchy
    [name "getAll"]
    [key 'response.'results (list 'pillarName 'sectionName 'isHosted)]
    [type (listof (list/c string? string? string?))]
    [children (struct/c empty-set)])
