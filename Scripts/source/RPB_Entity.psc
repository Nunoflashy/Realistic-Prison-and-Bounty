scriptname RPB_Entity extends RPB_SerializableReferenceAlias hidden
{
    @property int ID
    @property string UUID
    @property bool Active
}

; ==========================================================
;                     Script References
; ==========================================================

; =========================================================
;                    Serialization Config                      
; =========================================================

int function GetSerializableRootObject()
    return self.GetLocalPropertyOfTypeInt("Root Object")
endFunction