' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Channel entry point
sub Main()
    screen = CreateObject("roSGScreen")
	m.global = screen.getGlobalNode()
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.Show() 
	scene.observeField("close", m.port)
	
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
		Dbg("msg.getNode(): ", msg.getNode())
		Dbg("msg.getField(): ", msg.getField())
        if msgType = "roSGNodeEvent"
		    node = msg.getField()
			Dbg("roSGNodeEvent ", node)
            if node = "close" and msg.getData()
                return
            end if
        'else if msgType = "roDeviceInfoEvent"
         '   info = msg.GetInfo()
		'	Dbg("roDeviceInfoEvent ", info)
        end if
    end while
end sub
