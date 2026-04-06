(struct empty-set ())
(struct hierarchy (name key type children))
(struct/dc hierarchy
    [name "getTeams"]
    [key 'boxscore.'teams['team.'displayName]] ; list of team names
    [type (listof string?)] ; team names are type string
    [children (struct/dc hierarchy
        [name "getVenue"]
        [key 'gameInfo.'venue.'fullName])]
        [type string?]
        [children (struct/c empty-set)])])
