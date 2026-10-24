
net.Receive( SSB.NET_ACCESS, function()

	SSB.access = net.ReadBool()
	SSB.hasCAMI = net.ReadBool()
	SSB.UpdateAccess()

end )

-- The menu rows read SSB.blacklist when they are painted, so nothing has to be refreshed
net.Receive( SSB.NET_SYNC, function()

	local blacklist = {}
	for _, model in ipairs( SSB.ReadModels() ) do
		blacklist[ model ] = true
	end

	SSB.blacklist = blacklist

end )
