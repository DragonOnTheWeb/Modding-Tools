{
	Hotkey: Ctrl+Alt+D
}
unit TEST_BDAssetLoaderFO4;

interface
implementation
uses FFO_Furrifier, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    testErrorCount: integer;

procedure Assert(v: Boolean; msg: string);
begin
    if v then 
        AddMessage('OK: ' + msg)
    else
    begin
        AddMessage('XXXXXX Error: ' + msg);
        testErrorCount := testErrorCount + 1;
        Raise Exception.Create('Assert fail');
    end;
end;

//-------------------------------------------------------------------------
// Test the furrifier
function Finalize: integer;
var
    classCounts: array[0..40 {CLASS_COUNT}, 0..50 {MAX_RACES}] of integer;
    elem: IwbElement;
    elist: IwbContainer;
    f: IwbFile;
    fl: TStringList;
    g: IwbContainer;
    headpart: IwbMainRecord;
    i: integer;
    j: integer;
    k: integer;
    lykaiosIndex: integer;
    lykaiosRace: IwbMainRecord;
    m: integer;
    modFile: IwbFile;
    name: string;
    npc: IwbMainRecord;
    npcClass: integer;
    npcDesdemona: IwbMainRecord;
    npcGroup: IwbGroupRecord;
    npcMason: IwbMainRecord;
    npcPiper: IwbMainRecord;
    npcRace: integer;
    race: IwbMainRecord;
    raceID: Cardinal;
    racename: string;
    racepnam: float;
begin
    LOGLEVEL := 14;
    f := FileByIndex(0);

    if {Testing random numbers} FALSE then begin
        AddMessage('Same hash, different seeds');
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 4039, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 3828, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 2493, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 5141, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 5939, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 1663, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 6337, 100)]));
        AddMessage('Consecutive hash, same seed');
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 8707, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate02', 8707, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate03', 8707, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate04', 8707, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate05', 8707, 100)]));
        AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate06', 8707, 100)]));
    end;

    // Asset loader has to be iniitialized before use.
    AddMessage('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    Log(10, 'Starting tests');
    testErrorCount := 0;

    InitializeFurrifier;

    // ----------- masterRaceList
    // masterRaceList has a list of all the furry races that were found.
    // A particular race can be found by name.

    Assert(masterRaceList.Count > 8, 'Found furry races: ' + IntToStr(masterRaceList.Count));
    lykaiosIndex := RacenameIndex('FFOLykaiosRace');
    Assert(lykaiosIndex >= 0, 'Found the Lykaios race.');
    lykaiosRace := ObjectToElement(masterRaceList.Objects[lykaiosIndex]);
    Assert(SameText(EditorID(lykaiosRace), 'FFOLykaiosRace'), 'Recovered the Lykaios race record');

    AddMessage('---Can iterate through the masterRaceList');
    for i := 0 to masterRaceList.Count-1 do 
        AddMessage('[' + IntToStr(i) + '] ' + masterRaceList[i]);

    // ---------- Race Assets
    for i := 0 to masterRaceList.Count-1 do 
        AddMessage('[' + IntToStr(i) + '] ' + masterRaceList[i]);

    AddMessage('---Can iterate through the tint list');
    for i := 0 to tintlayerName.Count-1 do
        AddMessage(Format('[%d] %s', [i, tintlayerName[i]]));

    AddMessage('---Can iterate through tint probabilities');
    for i := 0 to masterRaceList.Count-1 do 
        for j := 0 to tintlayerName.Count-1 do
            for k := MALE to FEMALE do
                AddMessage(Format('Probability [%d/%d] %s %s %s = %d', [
                    integer(i),
                    integer(j),
                    masterRaceList[i], 
                    tintlayerName[j], 
                    IfThen(k=MALE, 'M', 'F'), 
                    integer(raceInfo[i, k].tintProbability[j])
                    ]));

    Assert(raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_MASK] = 100, 'Have tint probability');

    // Can select skin tints of the different races.
    AddMessage('---Can list the tint layers for all race/sex combos');
    for i := 0 to masterRaceList.Count-1 do 
        for j := MALE to FEMALE do
            for k := 0 to tintlayerName.Count-1 do
                for m := 0 to raceInfo[i, j].tintCount[k]-1 do
                    if length(raceInfo[i, j].tints[k, m].name) > 0 then // Assigned(raceInfo[i, j].tints[k, m].element) then
                        AddMessage(Format('%s %s "%s" [%d/%d] "%s" [%s]', [
                            masterRaceList[i],
                            IfThen(j=MALE, 'M', 'F'),
                            tintlayerName[k],
                            integer(k),
                            integer(m),
                            raceInfo[i, j].tints[k, m].name,
                            GetElementEditValues(ObjectToElement(raceInfo[i, j].tints[k, m].element), 'Textures\TTET')
                        ]));
    Assert(TL_SKIN_TONE = tintlayerName.IndexOf('Skin Tone'), 
        Format('Skin tone index correct: %d = %d', [integer(TL_SKIN_TONE), tintlayerName.IndexOf('Skin Tone')]));
    Assert(SameText(raceInfo[RacenameIndex('FFOHyenaRace'), MALE].tints[TL_SKIN_TONE, 0].name, 'Skin tone'), 
        'Hyena has skin tone ' + raceInfo[RacenameIndex('FFOHyenaRace'), MALE].tints[TL_SKIN_TONE, 0].name);
    Assert(raceInfo[RacenameIndex('FFOFoxRace'), FEMALE].tintCount[TL_MASK] = 3, 
        'Fox Fem has 3 masks: ' + IntToStr(raceInfo[RacenameIndex('FFOFoxRace'), FEMALE].tintCount[TL_MASK]));
    Assert(StartsText('Face Mask', raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_MASK, 0].name), 
        'Fox has face mask ' + raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_MASK, 0].name);
    Assert(SameText(raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_EAR, 0].name, 'Ears'), 
        'Fox has ear ' + raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_EAR, 0].name);


    // Can find tint presets for the different races.
    elem := PickRandomTintPreset('Desdemona', 6684, RacenameIndex('FFOHorseRace'), FEMALE, TL_MUZZLE, 1);
    Assert(Pathname(elem) <> '', 'Have pathname for tint preset: ' + PathName(elem));

    // Can find headparts for the different races.
    headpart := FindAsset(Nil, 'HDPT', 'FFO_HairFemale21_Dog');
    Assert(HeadpartValidForRace(headpart, RacenameIndex('FFOLykaiosRace'), FEMALE, HEADPART_HAIR), 
        'Dog female hair works on Lykaios');
    Assert(not HeadpartValidForRace(headpart, RacenameIndex('FFOCheetahRace'), FEMALE, HEADPART_HAIR), 
        'Dog female hair does not work on Cheetah');
    headpart := PickRandomHeadpart('Desdemona', 4219, RacenameIndex('FFOHorseRace'), FEMALE, HEADPART_EYES);
    Assert(ContainsText(EditorID(headpart), 'Ungulate'), 'Found good eyes for Desdemona: ' + EditorID(headpart));

    // --------- Classes
    // Class probabilities are as expected.
    Assert(classProbs[CLASS_MINUTEMEN, lykaiosIndex] > 10, 'Lykaios can be minutemen');

    // Classes can be derived from factions, so it's easy to read those.
    fl := TStringList.Create;
    GetNPCFactions(npc, fl);
    for i := 0 to fl.Count-1 do
        AddMessage('Has faction ' + fl[i]);
    fl.Free;
    
    // -------- NPC classes and races
    // NPCs are given classes to help with furrification.
    npc := FindAsset(f, 'NPC_', 'BlakeAbernathy');
    npcClass := GetNPCClass(npc);
    Assert(npcClass = NONE, 'Expected no specific class for BlakeAbernathy');
    npcRace := ChooseNPCRace(npc);
    Assert(npcRace >= 0, 'Expected to choose a race');
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Desdemona-');
    npcDesdemona := FindAsset(f, 'NPC_', 'Desdemona');
    Assert(Assigned(npcDesdemona), 'Found Desdemona');
    npcClass := GetNPCClass(npcDesdemona);
    Assert(npcClass = CLASS_RR, 'Expected RR for Desdemona; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npcDesdemona);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Cabots-');
    npc := FindAsset(f, 'NPC_', 'LorenzoCabot');
    Assert(Assigned(npc), 'Expected to find LorenzoCabot');
    Assert(SameText(EditorID(npc), 'LorenzoCabot'), 'Expected to find LorenzoCabot');
    name := GetElementEditValues(npc, 'FULL');
    AddMessage('Name = ' + name);
    npcClass := GetNPCClass(npc);
    Assert(npcClass = CLASS_CABOT, 'Expected CLASS_CABOT for LorenzoCabot; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npc);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Children of Atom-');
    npc := FindAsset(f, 'NPC_', 'EncChildrenOfAtom01Template');
    Assert(npc <> Nil, 'Found EncChildrenOfAtom01Template');
    npcClass := GetNPCClass(npc);
    Assert(npcClass = CLASS_ATOM, 'Expected CLASS_ATOM for EncChildrenOfAtom01Template; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npc);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Pack-');
    // Mason's race is forced to Horse
    npcMason := FindAsset(Nil, 'NPC_', 'DLC04Mason');
    Assert(npcMason <> Nil, 'Found DLC04Mason');
    npcClass := GetNPCClass(npcMason);
    Assert(npcClass = CLASS_PACK, 'Expected CLASS_PACK for DLC04Mason; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npcMason);
    Assert(SameText(masterRaceList[npcRace], 'FFOHorseRace'), 'Mason given horse race.');

    // -------- NPC race assignment
    // Can create overwrite records.
    npc := FindAsset(Nil, 'NPC_', 'DLC04Mason');
    modFile := CreateOverrideMod('TEST.esp');
    npcMason := FurrifyNPC(npc, modFile);
    Assert(EditorID(LinksTo(ElementByPath(npcMason, 'RNAM'))) = 'FFOHorseRace', 
        'Changed Mason`s race');
    elist := ElementByPath(npcMason, 'Head Parts');
    Assert(ElementCount(elist) >= 3, 'Have head parts');
    Assert(GetFileName(LinksTo(ElementByIndex(elist, 0))) = 'FurryFallout.esp', 
        'Have head parts from FFO');
    Assert(GetFileName(LinksTo(ElementByPath(npcMason, 'WNAM'))) = 'FurryFallout.esp', 
        'Have skin from FFO');

    npc := FindAsset(Nil, 'NPC_', 'CompanionPiper');
    modFile := CreateOverrideMod('TEST.esp');
    npcPiper := FurrifyNPC(npc, modFile);
    Assert(EditorID(LinksTo(ElementByPath(npcPiper, 'RNAM'))) = 'FFOFoxRace', 
        'Changed Piper`s race');
    elist := ElementByPath(npcPiper, 'Head Parts');
    Assert(ElementCount(elist) >= 3, 'Have head parts');
    Assert(GetFileName(LinksTo(ElementByIndex(elist, 0))) = 'FurryFallout.esp', 
        'Have head parts from FFO');
    Assert(GetFileName(LinksTo(ElementByPath(npcPiper, 'WNAM'))) = 'FurryFallout.esp', 
        'Have skin from FFO');

    LOGLEVEL := 1;

    // --------- Race distribution 
    if {Testing race distribution} false then begin
        // Walk through the NPCs and collect stats on how many of each race there are
        // to make sure the random assignment is giving a range of races.
        AddMessage('---Race Probabilities---');
        for k := 0 to FileCount-1 do begin
            f := FileByIndex(k);
            npcGroup := GroupBySignature(f, 'NPC_');
            for i := 0 to ElementCount(npcGroup)-1 do begin
                npc := ElementByIndex(npcGroup, i);
                if StartsText('HumanRace', GetElementEditValues(npc, 'RNAM')) then begin
                    npcClass := GetNPCClass(npc);
                    raceID := ChooseNPCRace(npc);
                    classCounts[npcClass, raceID] := classCounts[npcClass, raceID] + 1;
                end;
            end;
        end;

        AddMessage('Check that we have a reasonable distribution of races');
        for i := 0 to CLASS_COUNT-1 do begin
            AddMessage('-');
            for j := 0 to masterRaceList.Count-1 do begin
                if classCounts[i, j] > 0 then 
                    AddMessage(GetClassName(i) + ' ' + masterRaceList[j] + ' = ' + IntToStr(classCounts[i, j]));
            end;
        end;
    end;

    AddMessage(Format('Tests completed with %d errors', [testErrorCount]));
    AddMessage(IfThen(testErrorCount = 0, 
        '++++++++++++SUCCESS++++++++++',
        '-------------FAIL----------'));
    ShutdownAssetLoader;
end;

end.