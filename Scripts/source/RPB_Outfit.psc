scriptname RPB_Outfit extends ActiveMagicEffect

import RPB_Utility

RPB_Actor property Owner
    RPB_Actor function get()
        return parent as RPB_Actor
    endFunction
endProperty

; =========================================================
;                          public                         
; =========================================================

Armor property Head
    Armor function get()
        return _headClothing
    endFunction

    function set(Armor value)
        ; Validation
        _headClothing = value
    endFunction
endProperty

Armor property Body
    Armor function get()
        return _bodyClothing
    endFunction

    function set(Armor value)
        ; Validation
        _bodyClothing = value
    endFunction
endProperty

Armor property Hands
    Armor function get()
        return _handsClothing
    endFunction

    function set(Armor value)
        ; Validation
        _handsClothing = value
    endFunction
endProperty

Armor property Feet
    Armor function get()
        return _feetClothing
    endFunction

    function set(Armor value)
        ; Validation
        _feetClothing = value
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

bool function IsWearable(int bounty)
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

function Wear()
    ; Owner.EquipItem() ; etc
endFunction

; =========================================================
;                          private                         
; =========================================================

Armor   _headClothing 
Armor   _bodyClothing 
Armor   _handsClothing
Armor   _feetClothing 
bool    _isConditional
int     _minimumBounty
int     _maximumBounty

