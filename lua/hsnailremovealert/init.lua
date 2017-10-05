include("shared.lua")

util.AddNetworkString("hsnr.message")

HSNR.InitPlayer = function(pl)
	pl.hsnr = pl.hsnr or {}
	pl.hsnr.queue = pl.hsnr.queue or {}
	pl.hsnr.count = pl.hsnr.count or 0
end
hook.Remove("PlayerSpawn", "HSNR.InitPlayer", HSNR.InitPlayer)
-- hook.Add("PlayerSpawn", "HSNR.InitPlayer", HSNR.InitPlayer)

HSNR.OnNailRemoved = function(nail, ent1, ent2, remover)
	local owner = nail:GetDeployer()
	if IsValid(owner) and IsValid(remover) and owner:IsPlayer() and remover:IsPlayer() and owner ~= remover then
		table.insert(owner.hsnr.queue, {nick = remover:Nick(), uid = remover:UniqueID(), sid = remover:SteamID(), time = os.time()})
		HSNR.Alert(owner, remover)
	end
end
hook.Remove("OnNailRemoved", "HSNR.OnNailRemoved", HSNR.OnNailRemoved)
-- hook.Add("OnNailRemoved", "HSNR.OnNailRemoved", HSNR.OnNailRemoved)

HSNR.Alert = function(owner, remover)
	net.Start("hsnr.message")
		net.WriteInt(HSNR.MESSAGE.NAIL_REMOVED, 16)
		net.WriteEntity(remover)
	net.Send(owner)
end

HSNR.ReceiveShowList = function(pl)
	local queue = pl.hsnr.queue
	if !queue or #queue <= 0 then
		net.Start("hsnr.message")
			net.WriteInt(HSNR.MESSAGE.NO_QUEUE, 16)
		net.Send(pl)
	else
		net.Start("hsnr.message")
			net.WriteInt(HSNR.MESSAGE.SHOWLIST, 16)
			net.WriteTable(queue)
		net.Send(pl)
	end
end

HSNR.RequestShowList = function(pl, cmd, args, fullargs)
	if #args == 0 then
		HSNR.ReceiveShowList(pl)
		return
	end
	local command = string.lower(args[1])
	if command == "process"  or command == "p" then
		if !args[2] or string.len(args[2]) == 0 or !string.find(args[2], "^%d+$") then
			net.Start("hsnr.message")
				net.WriteInt(HSNR.MESSAGE.WRONG_ARGUMENT, 16)
			net.Send(pl)
		elseif #pl.hsnr.queue >= 1 then
			local id = tonumber(args[2])
			local target = player.GetByUniqueID(pl.hsnr.queue[id].uid)
			if !target or !IsValid(target) then
				net.Start("hsnr.message")
					net.WriteInt(HSNR.MESSAGE.TARGET_DISCONNECT, 16)
					net.WriteString(pl.hsnr.queue[id].sid)
					net.WriteString(pl.hsnr.queue[id].nick)
				net.Send(pl)
				
				table.remove(pl.hsnr.queue, id)
			else
				local count = (target.hsnr.count or 0) + 1
				target.hsnr.count = (target.hsnr.count or 0) + 1
				if count == 1 then
					if target:Team() == TEAM_HUMAN then
						target:AddPoints(-10)
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_POINT, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
							net.WriteString("10")
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_POINT, 16)
							net.WriteString(target:Nick())
							net.WriteString("10")
						net.Send(pl)
					elseif target:Team() == TEAM_UNDEAD then
						target:AddPoints(-1)
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_BRAIN, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
							net.WriteString("1")
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_BRAIN, 16)
							net.WriteString(target:Nick())
							net.WriteString("1")
						net.Send(pl)
					end
				elseif count == 2 then
					if target:Team() == TEAM_HUMAN then
						target:AddPoints(-30)
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_POINT, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
							net.WriteString("30")
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_POINT, 16)
							net.WriteString(target:Nick())
							net.WriteString("30")
						net.Send(pl)
					elseif target:Team() == TEAM_UNDEAD then
						target:AddPoints(-3)
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_BRAIN, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
							net.WriteString("3")
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_BRAIN, 16)
							net.WriteString(target:Nick())
							net.WriteString("3")
						net.Send(pl)
					end
				elseif count == 3 then
					if target:Team() == TEAM_HUMAN then
						target:TakeDamage(10000, target, target)
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_DAMAGE, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_DAMAGE, 16)
							net.WriteString(target:Nick())
						net.Send(pl)
					elseif target:Team() == TEAM_UNDEAD then
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PENALTY_KICK, 16)
							net.WriteFloat(pl.hsnr.queue[id].time)
						net.Send(target)
						
						net.Start("hsnr.message")
							net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_KICK, 16)
							net.WriteString(target:Nick())
						net.Send(pl)
						ulx.kick(NULL, target, "특정인의 못을 3회 이상 제거하여 킥 처리되었습니다.")
					end
				elseif count == 4 then
					net.Start("hsnr.message")
						net.WriteInt(HSNR.MESSAGE.PENALTY_KICK, 16)
						net.WriteFloat(pl.hsnr.queue[id].time)
					net.Send(target)
					
					net.Start("hsnr.message")
						net.WriteInt(HSNR.MESSAGE.PROCESS_PENALTY_KICK, 16)
						net.WriteString(target:Nick())
					net.Send(pl)
					ulx.kick(NULL, target, "특정인의 못을 3회 이상 제거하여 킥 처리되었습니다.")
				end
				
				table.remove(pl.hsnr.queue, id)
			end
		end
	end
end
concommand.Remove("nail", HSNR.RequestShowList)
-- concommand.Add("nail", HSNR.RequestShowList)