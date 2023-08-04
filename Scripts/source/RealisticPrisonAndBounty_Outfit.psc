scriptname RealisticPrisonAndBounty_Outfit extends Quest

import RealisticPrisonAndBounty_Util

Armor property Head
    Armor function get()
        return headClothing
    endFunction

    function set(Armor value)
        ; Validation
        headClothing = value
    endFunction
endProperty

Armor property Body
    Armor function get()
        return bodyClothing
    endFunction

    function set(Armor value)
        ; Validation
        bodyClothing = value
    endFunction
endProperty

Armor property Hands
    Armor function get()
        return handsClothing
    endFunction

    function set(Armor value)
        ; Validation
        handsClothing = value
    endFunction
endProperty

Armor property Feet
    Armor function get()
        return feetClothing
    endFunction

    function set(Armor value)
        ; Validation
        feetClothing = value
    endFunction
endProperty

bool property IsConditional
    bool function get()
        return _isConditional
    endFunction

    function set(bool value)
        _isConditional = value
    endFunction
endProperty

int property MinimumBounty
    int function get()
        return _minimumBounty
    endFunction

    function set(int value)
        _minimumBounty = value
    endFunction
endProperty

int property MaximumBounty
    int function get()
        return _maximumBounty
    endFunction

    function set(int value)
        _maximumBounty = value
    endFunction
endProperty

bool function validate()
    return !(headClothing == none || bodyClothing == none || handsClothing == none || feetClothing == none)
endFunction

bool function IsWearable(int bounty)
    ; Debug(self, "Outfit::IsWearable", "\n" + \
    ;     "IsConditional: " + IsConditional + "\n" + \
    ;     "bounty >= MaximumBounty: " + (bounty >= MaximumBounty) + "\n" + \
    ;     "bounty <= MinimumBounty: " + (bounty <= MinimumBounty) + "\n" + \
    ;     "(MaximumBounty == MinimumBounty) && bounty >= MinimumBounty: " + ((MaximumBounty == MinimumBounty) && bounty >= MinimumBounty) + "\n" + \
    ;     "bounty >= MinimumBounty && bounty <= MaximumBounty: " + (bounty >= MinimumBounty && bounty <= MaximumBounty) + "\n" + \
    ;     "MinimumBounty: " + (MinimumBounty) + "\n" + \
    ;     "MaximumBounty: " + (MaximumBounty) + "\n"\
    ; )
    if (!IsConditional)
        return true
    endif

    if ((MaximumBounty == MinimumBounty) && bounty >= MinimumBounty)
        return true
    endif

    if (bounty >= MinimumBounty && bounty <= MaximumBounty)
        return true
    endif

    return false
endFunction

Armor headClothing  = none
Armor bodyClothing  = none
Armor handsClothing = none
Armor feetClothing  = none
bool _isConditional
int _minimumBounty
int _maximumBounty
