class X2StrategyElement_StealSparkRewards extends X2StrategyElement_DefaultRewards config (StealSpark);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	Rewards.AddItem(CreateStealSparkRewardTemplate());

	return Rewards;
}

static function X2DataTemplate CreateStealSparkRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'TRReward_StealSpark');

	Template.GenerateRewardFn = GenerateStealSparkReward;
	Template.SetRewardFn = SetStealSparkReward;
	Template.GiveRewardFn = GiveStealSparkReward;
	Template.GetRewardStringFn = GetStealSparkRewardString;
	Template.CleanUpRewardFn = CleanUpStealSparkReward;

	return Template;
}

static function GenerateStealSparkReward(XComGameState_Reward RewardState, XComGameState NewGameState, optional float RewardScalar = 1.0, optional StateObjectReference AuxRef)
{
	local XComGameState_CovertAction ActionState;

	ActionState = XComGameState_CovertAction(NewGameState.GetGameStateForObjectID(AuxRef.ObjectID));
	if (ActionState != none) ActionState.StoredRewardRef = RewardState.GetReference();

	RewardState.RewardObjectReference = CreateSparkSoldier(NewGameState);
}

static function SetStealSparkReward(XComGameState_Reward RewardState, optional StateObjectReference RewardObjectRef, optional int Amount)
{
	RewardState.RewardObjectReference = RewardObjectRef;
}

static function GiveStealSparkReward(XComGameState NewGameState, XComGameState_Reward RewardState, optional StateObjectReference AuxRef, optional bool bOrder = false, optional int OrderHours = -1)
{	
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_Unit Unit;

	XComHQ = `XCOMHQ;
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	XComHQ.AddToCrew(NewGameState, Unit);
}

static function string GetStealSparkRewardString(XComGameState_Reward RewardState)
{
	local XComGameState_Unit Unit;

	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(RewardState.RewardObjectReference.ObjectID));
	
	return RewardState.GetMyTemplate().DisplayName $":" @Unit.GetSoldierShortRankName() @Unit.GetFullName();
}

static protected function CleanUpStealSparkReward(XComGameState NewGameState, XComGameState_Reward RewardState)
{
	// Do literary nothing. Literary.	
}

// HELPERS
static function StateObjectReference CreateSparkSoldier(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_FacilityXCom FacilityState;
	local XComOnlineProfileSettings ProfileSettings;
	local XComGameState_Unit NewSparkState;
	local int NewRank, idx;	

	XComHQ = class'UIUtilities_Strategy'.static.GetXComHQ();

	// Create the necessary Spark Equipments 
	class'X2Helpers_DLC_Day90'.static.CreateSparkEquipment(NewGameState);	

	FacilityState = XComHQ.GetFacilityByName('Storage');
	if (FacilityState != none && FacilityState.GetNumLockedStaffSlots() > 0)
	{
		// Unlock the Repair SPARK staff slot in Engineering
		FacilityState.UnlockStaffSlot(NewGameState);
	}

	// Create a Spark from the Character Pool (will be randomized if no Sparks have been created)
	ProfileSettings = `XPROFILESETTINGS;
	NewSparkState = `CHARACTERPOOLMGR.CreateCharacter(NewGameState, ProfileSettings.Data.m_eCharPoolUsage, 'SparkSoldier');
	NewSparkState.RandomizeStats();
	NewSparkState.ApplyInventoryLoadout(NewGameState);

	// Rank ups
	NewRank = GetPersonnelRewardRank(true, false);
	NewSparkState.SetXPForRank(NewRank);
	NewSparkState.StartingRank = NewRank;

	// idx starts at 1 because Sparks do not start with Rookie (CharTemplate.DefaultSoldierClass = 'Spark')
	for (idx = 1; idx < NewRank; idx++)
	{		
		NewSparkState.RankUpSoldier(NewGameState);
	}

	// Make sure the new Spark has the best gear available (will also update to appropriate armor customizations)
	NewSparkState.ApplySquaddieLoadout(NewGameState);
	NewSparkState.ApplyBestGearLoadout(NewGameState);

	NewSparkState.kAppearance.nmPawn = 'XCom_Soldier_Spark';
	NewSparkState.kAppearance.iAttitude = 2;	// Force the attitude to be Normal
	NewSparkState.UpdatePersonalityTemplate();	// Grab the personality based on the one set in kAppearance
	NewSparkState.SetStatus(eStatus_Active);
	NewSparkState.bNeedsNewClassPopup = false;

	return NewSparkState.GetReference();	
}