
net.Receive( SSB.NET_ACCESS, function()

	SSB.access = net.ReadBool()
	SSB.canSkipCheck = net.ReadBool()
	SSB.hasCAMI = net.ReadBool()
	SSB.UpdateAccess()
	hook.Run( 'SSB.Updated' )

end )

-- The menu rows read SSB.blacklist when they are painted, only the bodygroups panel is updated
net.Receive( SSB.NET_SYNC, function()

	SSB.blacklist, SSB.forbidden = SSB.ReadSync()
	SSB.RefreshMenu()
	hook.Run( 'SSB.Updated' )

end )
