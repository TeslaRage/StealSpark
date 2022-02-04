class X2StrategyElement_StealSparkActivities extends X2StrategyElement_DefaultActivities;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateInvestigateSpark());
	Templates.AddItem(CreateHeistSpark());	

	return Templates;
}

static function X2DataTemplate CreateInvestigateSpark()
{
	local X2ActivityTemplate_CovertAction Template;

	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Template, 'TRActivity_InvestigateSpark');

	Template.CovertActionName = 'TRCovertAction_InvestigateSpark';
	Template.AvailableSound = "Geoscape_NewResistOpsMissions";

	return Template;
}

static function X2DataTemplate CreateHeistSpark()
{
	local X2ActivityTemplate_CovertAction Template;

	`CREATE_X2TEMPLATE(class'X2ActivityTemplate_CovertAction', Template, 'TRActivity_HeistSpark');

	Template.CovertActionName = 'TRCovertAction_HeistSpark';
	Template.AvailableSound = "Geoscape_NewResistOpsMissions";

	return Template;
}