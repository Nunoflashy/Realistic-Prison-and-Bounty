scriptname RPB_Entity extends RPB_SerializableReferenceAlias hidden
{
    @property int ID
    @property string UUID
    @property bool Active
}

import RPB_Utility

; ==========================================================
;                     Script References
; ==========================================================

; =========================================================
;                           ORM                      
; =========================================================
int __indicesMap ; JMap < any& <JContainer> >

; function BuildIndex(int apObject, string asAttribute)
;     if (!__indicesMap)
;         __indicesMap = JMap.object()
;         int attributeIndex = JArray.object()
        
;         JMap.setObj(__indicesMap, asAttribute, attributeIndex)
;         JValue.retain(__indicesMap, "RPB_Entity")
;     endif

;     ; Clear this attribute's index
;     JArray.clear(JMap.getObj(__indicesMap, asAttribute))

;     int objectCount = JValue.count(__indicesMap)
    
;     int i = 0
;     while (i < objectCount)
;         int currentObject = GetObjectAt(apObject, i)
;         if (JMap.getInt(currentObject, asAttribute))
            
;         endif
;         i += 1
;     endWhile
; endFunction

int function GetObjectAt(int apObject, int index)
    if (!apObject)
        Debug("GetObjectAt", "Invalid root object.")
        return 0
    endif

    int resultObject = JArray.getObj(apObject, index)
    if (!resultObject)
        return 0
    endif

    return resultObject
endFunction

; =========================================================
;                    Serialization Config                      
; =========================================================

int property Root
    int function get()
        return self.GetSerializableRootObject()
    endFunction
endProperty

int function Children(string asObjectPath, string apConditions = "null")
    if (apConditions != "null")
        ; return FindProperty
    endif

    return RPB_Data.GetPropertyOfTypeObject(self.Root, asObjectPath)
endFunction

int function GetSerializableRootObject()
    return self.GetLocalPropertyOfTypeInt("Root Object")
endFunction