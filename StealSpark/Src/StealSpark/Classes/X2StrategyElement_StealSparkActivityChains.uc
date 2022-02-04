class X2StrategyElement_StealSparkActivityChains extends X2StrategyElement_DefaultActivityChains;

var config (StealSpark) int SparkLimit;
var config (StealSpark) array<name> BuildSparkTechs;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStealSparkTemplate());

	return Templates;
}

static function X2DataTemplate CreateStealSparkTemplate()
{
	local X2ActivityChainTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ActivityChainTemplate', Template, 'TRActivityChain_StealSpark');
	
	Template.ChooseFaction = ChooseMetFaction;
	Template.ChooseRegions = ChooseRandomContactedRegion;
	Template.SpawnInDeck = true;
	Template.NumInDeck = 2;
	Template.DeckReq = IsStealSparkChainAvailable;	
	
	Template.Stages.AddItem(ConstructPresetStage('TRActivity_InvestigateSpark'));
	Template.Stages.AddItem(ConstructPresetStage('Activity_WaitGeneric'));
	Template.Stages.AddItem(ConstructPresetStage('TRActivity_HeistSpark'));

	return Template;
}

static function bool IsStealSparkChainAvailable(XComGameState NewGameState)
{
	local XComGameState_HeadquartersXCom XComHQ;
	local StateObjectReference UnitRef;
	local XComGameState_Unit Unit;
	local XComGameState_HeadquartersProjectProvingGround HQProject;
	local XComGameState_Tech Tech;
	local bool bCanBuildSparks, bBuildingSpark;
	local int iCount;

	// Only 1 at a time, else we can spawn one while the previous is still in progress, thus violating the count rules
	if (DoesActiveChainExist('TRActivityChain_StealSpark', NewGameState)) return false;

	XComHQ = `XCOMHQ;

	if (class'X2Helpers_DLC_Day90'.static.IsLostTowersNarrativeContentComplete())
	{
		bCanBuildSparks = true;
	}
	else if (XComHQ.IsTechResearched('MechanizedWarfare'))
	{
		bCanBuildSparks = true;
	}

	// We should check if there is an on-going project to build/resurrect Sparks
	HQProject = XComHQ.GetCurrentProvingGroundProject();

	if (HQProject != none)
	{
		Tech = XComGameState_Tech(`XCOMHISTORY.GetGameStateForObjectID(HQProject.ProjectFocus.ObjectID));
		if (Tech != none)
		{
			if (default.BuildSparkTechs.Find(Tech.GetMyTemplateName()) != INDEX_NONE)
			{
				bBuildingSpark = true;
			}
		}
	}

	if (bCanBuildSparks && !bBuildingSpark)
	{
		foreach XComHQ.Crew(UnitRef)
		{
			Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));

			if (Unit != none && Unit.GetSoldierClassTemplateName() == 'Spark')
			{
				iCount++;
			}
		}

		if (iCount < default.SparkLimit)
		{
			return true;
		}
	}
	
	return false;
}