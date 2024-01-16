scriptname RPB_Utility hidden

string function ModName() global
    return "Realistic Prison and Bounty"
endFunction

; ==========================================================
;                        Log Functions
; ==========================================================

function Trace(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] TRACE: " + asCaller + "() " + " -> " + asLogInfo)
endFunction

function Debug(string asCaller, string asLogInfo, bool abCondition = true) global
    if (!abCondition)
        return
    endif

    debug.trace("["+ ModName() +"] DEBUG: " + asCaller + "() " + " -> " + asLogInfo)
endFunction

; ==========================================================
;                       Math Functions
; ==========================================================

float function Max(float a, float b) global
    if (a > b)
        return a
    else
        return b
    endif
endFunction

float function Min(float a, float b) global
    if (a < b)
        return a
    else
        return b
    endif
endFunction

int function Round(float value) global
    float fractionalPart = value - math.floor(value)

    if (fractionalPart >= 0.5)
        return math.ceiling(value)
    else
        return math.floor(value)
    endif
endFunction

; ==========================================================
;                 Ternary-Operator Functions
; ==========================================================

;/
	Ternary operator-like functions
	objective: float x = condition ? afTrue : afFalse
    usage: float x = float_if(condition, afTrue, afFalse)
    example: float x = float_if(y == 2, 4, 8)

/;
float function float_if(bool condition, float afTrue, float afFalse = 0.0) global
	if(condition)
		return afTrue
	endif
	return afFalse
endfunction

int function int_if(bool condition, int aiTrue, int aiFalse = 0) global
	if(condition)
		return aiTrue
	endif
	return aiFalse
endfunction

bool function bool_if(bool condition, bool abTrue, bool abFalse = false) global
	if(condition)
		return abTrue
	endif
	return abFalse
endfunction

string function string_if(bool condition, string asTrue, string asFalse = "") global
	if(condition)
		return asTrue
	endif
	return asFalse
endfunction

Form function form_if(bool condition, Form akTrue, Form akFalse = none) global
    if(condition)
        return akTrue
    else
        return akFalse
    endif
endfunction

; ==========================================================
;                        AI Functions
; ==========================================================

function RetainAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(true)
        Game.DisablePlayerControls( \
            abMovement = true, \
            abFighting = true, \
            abCamSwitch = false, \
            abLooking = false, \
            abSneaking = true, \
            abMenu = true, \
            abActivate = true, \
            abJournalTabs = false, \
            aiDisablePOVType = 0 \
        )
    endif
endFunction

function ReleaseAI(bool condition = true) global
    if (condition)
        Game.SetPlayerAIDriven(false)
        Game.EnablePlayerControls()
    endif
endFunction



Form function GetFormOfType(string asFormType) global
    if (asFormType == "Gold")
        return Game.GetFormEx(0xF)

    elseif (asFormType == "Lockpick")
        return Game.GetFormEx(0xA)
    endif
endFunction