(struct empty-set ())
(struct hierarchy (name key type children))

; get region name: (Evanston, Illinois)
(struct/dc hierarchy
    [name "getRegion"]
    [key (list ('location.'name) ('location.'region))]
    [type (list/c string? string?)]
    ; get curr condition/temp
    [children (struct/dc hierarchy
        [name "getCurrCondition"]
        [key (list ('current.'temp_f) ('current.'condition.'text))]
        [type (list/c number? string?)]
        ; per day forecast
        [children (struct/dc hierarchy
            [name "getForecasts"]
            [key 'forecast.'forecastday[(list ('day.'avgtemp_f) ('astro.'sunrise) ('astro.'sunrise))]]
            [type (listof (list/c number? string? string?))]
            [children (struct/c empty-set)])])])
