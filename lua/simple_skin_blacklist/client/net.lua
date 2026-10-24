
net.Receive( SSB.NET_ACCESS, function()

	SSB.access = net.ReadBool()
	SSB.canSkipCheck = net.ReadBool()
	SSB.hasCAMI = net.ReadBool()
	SSB.UpdateAccess()
	hook.Run( 'SSB.Updated' )

end )

-- The menu rows read SSB.blacklist when they are painted, only the bodygroups panel is updated
net.Receive( SSB.NET_SYNC, function()

	local blacklist = {}
	for _, model in ipairs( SSB.ReadModels() ) do
		blacklist[ model ] = true
	end

	SSB.blacklist = blacklist
	SSB.forbidden = SSB.ReadForbidden()
	SSB.RefreshMenu()
	hook.Run( 'SSB.Updated' )

end )
