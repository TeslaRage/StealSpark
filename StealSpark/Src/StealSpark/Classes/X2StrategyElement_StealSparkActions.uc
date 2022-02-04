class X2StrategyElement_StealSparkActions extends X2StrategyElement_DefaultCovertActions;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CovertActions;

	CovertActions.AddItem(CreateInvestigateSparkTemplate());
	CovertActions.AddItem(CreateHeistSparkTemplate());

	return CovertActions;
}

static function X2DataTemplate CreateInvestigateSparkTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'TRCovertAction_InvestigateSpark');

	Template.bCanNeverBeRookie = true;
	Template.ChooseLocationFn = class'X2StrategyElement_DefaultActivities'.static.UseActivityPrimaryRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	
	Template.Narratives.AddItem('CovertActionNarrative_InvestigateSpark');

	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 2));
	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));

	Template.Risks.AddItem('CovertActionRisk_SoldierWounded');
	Template.Rewards.AddItem('Reward_Progress');

	return Template;
}

static function X2DataTemplate CreateHeistSparkTemplate()
{
	local X2CovertActionTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CovertActionTemplate', Template, 'TRCovertAction_HeistSpark');

	Template.bCanNeverBeRookie = true;
	Template.ChooseLocationFn = class'X2StrategyElement_DefaultActivities'.static.UseActivityPrimaryRegion;
	Template.OverworldMeshPath = "UI_3D.Overwold_Final.CovertAction";
	
	Template.Narratives.AddItem('CovertActionNarrative_HeistSpark');

	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot', 2));
	Template.Slots.AddItem(CreateDefaultSoldierSlot('CovertActionSoldierStaffSlot'));
	Template.OptionalCosts.AddItem(CreateOptionalCostSlot('Supplies', 25));

	Template.Risks.AddItem('CovertActionRisk_Ambush');
	Template.Rewards.AddItem('TRReward_StealSpark');

	return Template;
}

private static function CovertActionSlot CreateDefaultSoldierSlot(name SlotName, optional int iMinRank, optional bool bRandomClass, optional bool bFactionClass)
{
	local CovertActionSlot SoldierSlot;

	SoldierSlot.StaffSlot = SlotName;
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHP');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostAim');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostMobility');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostDodge');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostWill');
	SoldierSlot.Rewards.AddItem('Reward_StatBoostHacking');
	SoldierSlot.Rewards.AddItem('Reward_RankUp');
	SoldierSlot.iMinRank = iMinRank;
	SoldierSlot.bChanceFame = false;
	SoldierSlot.bRandomClass = bRandomClass;
	SoldierSlot.bFactionClass = bFactionClass;

	if (SlotName == 'CovertActionRookieStaffSlot')
	{
		SoldierSlot.bChanceFame = false;
	}

	return SoldierSlot;
}

private static function StrategyCostReward CreateOptionalCostSlot(name ResourceName, int Quantity)
{
	local StrategyCostReward ActionCost;
	local ArtifactCost Resources;

	Resources.ItemTemplateName = ResourceName;
	Resources.Quantity = Quantity;
	ActionCost.Cost.ResourceCosts.AddItem(Resources);
	ActionCost.Reward = 'Reward_DecreaseRisk';
	
	return ActionCost;
}