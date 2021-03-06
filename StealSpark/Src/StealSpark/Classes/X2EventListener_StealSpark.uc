class X2EventListener_StealSpark extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStrategyListeners());	

	return Templates;
}

static function CHEventListenerTemplate CreateStrategyListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'TRStealSpark');
	
	Template.AddCHEvent('CovertAction_ModifyNarrativeParamTag', CovertAction_ModifyNarrativeParamTag, ELD_Immediate, 98);
	Template.RegisterInStrategy = true;

	return Template;
}

static protected function EventListenerReturn CovertAction_ModifyNarrativeParamTag (Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_CovertAction Action;
	local XGParamTag kTag;	
	local XComGameStateHistory History;
	local XComGameState_Reward Reward;
	local XComGameState_Unit Unit;
	
	Action = XComGameState_CovertAction(EventSource);
	kTag = XGParamTag(EventData);
	if (Action == none || kTag == none) return ELR_NoInterrupt;	

	if (Action.GetMyTemplateName() != 'TRCovertAction_HeistSpark') return ELR_NoInterrupt;

	History = `XCOMHISTORY;

	Reward = XComGameState_Reward(History.GetGameStateForObjectID(Action.StoredRewardRef.ObjectID));
	Unit = XComGameState_Unit(History.GetGameStateForObjectID(Reward.RewardObjectReference.ObjectID));

	if (Unit != none)
	{
		kTag.StrValue4 = Unit.GetSoldierShortRankName() @Unit.GetFullName();
	}	
	
	return ELR_NoInterrupt;
}