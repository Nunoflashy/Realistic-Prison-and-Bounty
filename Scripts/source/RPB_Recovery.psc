scriptname RPB_Recovery hidden

;/
@functions:
    string function ResetActor(Actor akActor) global
/;

;/
    Frees @akActor from everything this mod may have left on them, however they got stuck: a prisoner is released where
    they stand (belongings back from the prison's container, outfit, cell package, hostility restore, and whatever is left
    of their arrest), an arrestee's arrest is reverted, a guard loses its Captor and package lock, any Scene still
    playing with them in it ends, and their AI is back on. Every step only acts on what it finds, so it's safe on any mix
    of leftovers and on an actor with nothing left at all.

    This is the manual way out for real gameplay (MCM Check Arrestee / Check Prisoner) and testing (F4), and what the
    tests' teardown uses so a deleted test actor never leaves items in a shared prison container.

    Returns what was done, for a message or a log line ("" when there was nothing to do).
/;
string function ResetActor(Actor akActor) global
    if (!akActor)
        return ""
    endif

    RPB_Arrest arrest = RPB_API.GetArrest()
    RPB_PrisonManager prisonManager = RPB_API.GetPrisonManager()
    RPB_SceneManager sceneManager = RPB_API.GetSceneManager()
    string done = ""

    ; A Scene still playing with them in it would keep driving them (and its guard) after everything below
    if (sceneManager.EndSceneWithActor(akActor, "the actor is being reset"))
        done += "Scene ended; "
    endif

    ; Prisoner: released in place, the same release as the prison's own minus the move (this also clears a leftover arrest)
    RPB_Prison prison = prisonManager.FindPrisonByPrisoner(akActor)
    RPB_Prisoner prisonerRef = none
    if (prison)
        prisonerRef = prison.Prisoners.AtKey(akActor)
    endif

    if (prisonerRef)
        prison.ReleaseInPlace(prisonerRef)
        done += "released from " + prison.Name + "; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_PrisonerSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_PrisonerSpell())
        done += "stray Prisoner effect removed; "
    endif

    ; Arrestee: whatever the release didn't already clear. Its Captor goes first, if it's still escorting them.
    RPB_Arrestee arresteeRef = arrest.Arrestees.AtKey(akActor)
    if (arresteeRef)
        RPB_Captor captorRef = arresteeRef.Captor
        if (captorRef && captorRef.Arrestee == akActor)
            Actor guard = captorRef.GetActor()
            captorRef.Destroy()
            RPB_Recovery.__FreeGuard(guard, sceneManager)
            done += "their guard was freed; "
        endif

        arresteeRef.RevertArrest()
        done += "arrest reverted; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_ArresteeSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_ArresteeSpell())
        done += "stray Arrestee effect removed; "
    endif

    ; A guard: its own Captor and a package lock left on it
    RPB_Captor ownCaptor = arrest.GetCaptor(akActor)
    if (ownCaptor)
        ownCaptor.Destroy()
        done += "Captor removed; "
    elseif (akActor.HasSpell(RPB_Utility.RPB_CaptorSpell()))
        akActor.RemoveSpell(RPB_Utility.RPB_CaptorSpell())
        done += "stray Captor effect removed; "
    endif
    if (RPB_Recovery.__FreeGuard(akActor, sceneManager))
        done += "package lock removed; "
    endif

    ; A pending arrest holds its arrestee with SetRestrained and SetDontMove (the revert above lifts them, this covers an
    ; arrest state that was already gone)
    akActor.SetRestrained(false)
    akActor.SetDontMove(false)
    sceneManager.UnsetPendingHoldOnActor(akActor) ; the pending hold's package alias, if one is recorded
    if (RPB_Utility.RemoveCuffs(akActor) > 0)
        done += "cuffs removed; "
    endif
    akActor.EnableAI(true)
    akActor.EvaluatePackage()

    RPB_Utility.Debug("Recovery::ResetActor", akActor + ": " + RPB_Utility.string_if(done == "", "nothing to reset", done))
    return done
endFunction

; Removes a package lock left on @akGuard. Only when one is recorded: UnsetPackageLockOnActor() on an actor without one
; resolves alias id 0, which is one of the Scene aliases, and would unbind it.
bool function __FreeGuard(Actor akGuard, RPB_SceneManager apSceneManager) global
    if (!akGuard || !RPB_StorageVars.GetIntOnReference("Package Lock", akGuard))
        return false
    endif

    apSceneManager.UnsetPackageLockOnActor(akGuard)
    akGuard.EvaluatePackage()
    return true
endFunction
