sub init()
    m.app = App()
    m.layoutGroup = m.top.findNode("layoutGroup")
    m.title = m.top.findNode("title")
    m.icon = m.top.findNode("icon")
    m.redFlag = m.top.findNode("redFlag")
    m.animation = m.top.findNode("animation")
    m.testTimer = m.top.findNode("testTimer")
    m.parent = m.top.getParent()
    m.testTimer.ObserveField("fire","startAnimation")
    m.parent.observeField("itemSelected", "onItemSelectedChanged")

    setInitialValues()
end sub

sub setInitialValues()
    m.title.font = m.app.fonts.regular
	m.title.color = "0x575756"
    m.title.translation = [-300, 0]
end sub

sub onItemContentChanged()
    m.item = m.top.itemContent
    m.title.text = m.item.title
    m.icon.uri = m.item.hdgridposterurl
    m.testTimer.duration = m.item.duration
    if m.top.index = 1 then
        m.redFlag.visible = true
		m.title.color = "0xFFFFFF"
		m.title.font = m.app.fonts.bold
    end if
end sub

sub onItemHasFocus()
    if m.top.focusPercent > 0.5 then
	   icons=m.item.id
	   poster=m.item.hdgridposterurl	
	   m.icon.uri = poster.replace(icons, icons+"_white")
       m.title.color = "0xFFFFFF"
	   m.title.font = m.app.fonts.bold
    else 
	   icons=m.item.id
	   poster=m.item.hdgridposterurl	
	   m.icon.uri = poster.replace(icons+"_white",icons)
       m.title.color = "0x575756"
	   m.title.font = m.app.fonts.regular
    end if
end sub

sub onItemSelectedChanged()
    itemSelected = m.parent.itemSelected
    m.redFlag.visible = false
    if m.top.index = itemSelected then
        m.redFlag.visible = true
		m.title.color = "0xFFFFFF"
		m.title.font = m.app.fonts.bold
    end if
end sub

sub onGridHasFocus()
    if m.top.gridHasFocus then
        m.icon.translation = [ 25, 0 ]
        m.redFlag.translation = [ 25, 35 ]
        m.testTimer.control = "start"
    else
        m.icon.translation = [ 10, 0 ]
        m.redFlag.translation = [ 10, 35 ]
        m.title.translation = [-300, 0]
    end if
end sub

sub startAnimation()
    m.animation.control = "start"
end sub