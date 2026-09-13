scriptname RPB_ActorMonitor extends ReferenceAlias

import RPB_Utility

; ==========================================================
;                      Script References
; ==========================================================

; ==========================================================
;                         Properties
; ==========================================================

RPB_ActorList property Actors
    RPB_ActorList function get()
        return (self as ReferenceAlias) as RPB_ActorList
    endFunction
endProperty