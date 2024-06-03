local KGCore = exports['kg-core']:GetCoreObject()
local ActiveMission = 0

RegisterServerEvent('AttackTransport:akceptujto', function()
	local copsOnDuty = 0
	local _source = source
	local xPlayer = KGCore.Functions.GetPlayer(_source)
	local accountMoney = xPlayer.PlayerData.money['bank']
	if ActiveMission == 0 then
		if accountMoney < Config.ActivationCost then
			TriggerClientEvent('KGCore:Notify', _source, 'You need ' .. Config.Currency .. '' .. Config.ActivationCost .. ' in the bank to accept the mission')
		else
			for _, v in pairs(KGCore.Functions.GetPlayers()) do
				local Player = KGCore.Functions.GetPlayer(v)
				if Player ~= nil then
					if (Player.PlayerData.job.name == 'police' or Player.PlayerData.job.type == 'leo') and Player.PlayerData.job.onduty then
						copsOnDuty = copsOnDuty + 1
					end
				end
			end
			if copsOnDuty >= Config.ActivePolice then
				TriggerClientEvent('AttackTransport:Pozwolwykonac', _source)
				xPlayer.Functions.RemoveMoney('bank', Config.ActivationCost, 'armored-truck')
				OdpalTimer()
			else
				TriggerClientEvent('KGCore:Notify', _source, 'Need at least ' .. Config.ActivePolice .. ' police to activate the mission.')
			end
		end
	else
		TriggerClientEvent('KGCore:Notify', _source, 'Someone is already carrying out this mission')
	end
end)

RegisterServerEvent('kg-armoredtruckheist:server:callCops', function(streetLabel, coords)
	-- local place = "Armored Truck"
	-- local msg = "The Alarm has been activated from a "..place.. " at " ..streetLabel
	-- Why is this unused?
	TriggerClientEvent('kg-armoredtruckheist:client:robberyCall', -1, streetLabel, coords)
end)

function OdpalTimer()
	ActiveMission = 1
	Wait(Config.ResetTimer * 1000)
	ActiveMission = 0
	TriggerClientEvent('AttackTransport:CleanUp', -1)
end

RegisterServerEvent('AttackTransport:zawiadompsy', function(x, y, z)
	TriggerClientEvent('AttackTransport:InfoForLspd', -1, x, y, z)
end)

RegisterServerEvent('AttackTransport:graczZrobilnapad', function()
	local _source = source
	local xPlayer = KGCore.Functions.GetPlayer(_source)
	local bags = math.random(1, 3)
	local info = {
		worth = math.random(Config.Payout.Min, Config.Payout.Max)
	}
	exports['kg-inventory']:AddItem(_source, 'markedbills', bags, false, info, 'AttackTransport:graczZrobilnapad')
	TriggerClientEvent('kg-inventory:client:ItemBox', _source, KGCore.Shared.Items['markedbills'], 'add')

	local chance = math.random(1, 100)
	TriggerClientEvent('KGCore:Notify', _source, 'You took ' .. bags .. ' bags of cash from the van')

	if chance >= 95 then
		exports['kg-inventory']:AddItem(_source, 'security_card_01', 1, false, false, 'AttackTransport:graczZrobilnapad')
		TriggerClientEvent('kg-inventory:client:ItemBox', _source, KGCore.Shared.Items['security_card_01'], 'add')
	end
	Wait(2500)
end)
