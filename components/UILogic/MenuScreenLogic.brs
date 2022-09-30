' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

sub ShowMenuScreen()
    m.MenuScreen = CreateObject("roSGNode", "CollapsedMenu")
	m.MenuScreen.observeField("itemSelected", "OnMenuSelection")
    ShowScreen(m.MenuScreen) ' show MenuScreen
end sub

sub OnMenuSelection()
  Dbg("Menu item:", m.MenuScreen.itemSelected)
  if m.MenuScreen.itemSelected=1
    ShowGridScreen()
    'RunContentTask() ' retrieving content
  end if
end sub