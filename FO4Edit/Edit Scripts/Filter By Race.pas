unit ApplyCustomScriptedFilter;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

function GetRaceTemplate(npc: IInterface): IInterface;
begin
  while Signature(npc) = 'LVLN' do
    npc := LinksTo(ElementByPath(npc, 'Leveled List Entries\[0]\LVLO\Reference'));
  
  if GetElementNativeValues(npc, 'ACBS\Template Flags\Use Traits') then
    Result := GetRaceTemplate(LinksTo(ElementBySignature(npc, 'TPLT')))
  else
    Result := npc;
end;

function Filter(e: IInterface): Boolean;
begin
  // e := GetRaceTemplate(e); // Use this to get NPCs based on a template
  Result := ContainsText(EditorID(LinksTo(ElementByPath(e, 'RNAM'))), 'DN_Dino');
end;

function Initialize: Integer;
begin
  FilterConflictAll := False;
  FilterConflictThis := False;
  FilterByInjectStatus := False;
  FilterInjectStatus := False;
  FilterByNotReachableStatus := False;
  FilterNotReachableStatus := False;
  FilterByReferencesInjectedStatus := False;
  FilterReferencesInjectedStatus := False;
  FilterByEditorID := False;
  FilterEditorID := '';
  FilterByName := False;
  FilterName := '';
  FilterByBaseEditorID := False;
  FilterBaseEditorID := '';
  FilterByBaseName := False;
  FilterBaseName := '';
  FilterScaledActors := False;
  FilterByPersistent := False;
  FilterPersistent := False;
  FilterUnnecessaryPersistent := False;
  FilterMasterIsTemporary := False;
  FilterIsMaster := False;
  FilterPersistentPosChanged := False;
  FilterDeleted := False;
  FilterByVWD := False;
  FilterVWD := False;
  FilterByHasVWDMesh := False;
  FilterHasVWDMesh := False;
  FilterBySignature := True;
  FilterSignatures := 'NPC_';
  FilterByBaseSignature := False;
  FilterBaseSignatures := '';
  FlattenBlocks := False;
  FlattenCellChilds := False;
  AssignPersWrldChild := False;
  InheritConflictByParent := False; // color conflicts
  FilterScripted := True; // use custom Filter() function

  ApplyFilter;

  Result := 1;
end;

end.
