' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

sub ShowMenuScreen()
    m.MenuScreen = CreateObject("roSGNode", "CollapsedMenu")
	m.MenuScreen.observeField("itemSelected", "OnMenuSelection")
    ShowScreen(m.MenuScreen) ' show MenuScreen
end sub

sub OnMenuSelection()
  Dbg("Menu item:", m.MenuScreen.itemSelected)
  if m.MenuScreen.itemSelected=0
    'ShowSearchScreen()
  else if m.MenuScreen.itemSelected=1
    'ShowHomeScreen()
  else if m.MenuScreen.itemSelected=2
    'ShowPlayScreen()
  else if m.MenuScreen.itemSelected=3
    'ShowRecentScreen()
  else if m.MenuScreen.itemSelected=4
    'ShowSeriesScreen()
    'RunSeriesTask() ' retrieving content
  else if m.MenuScreen.itemSelected=5
    ShowGridScreen()
    RunContentTask() ' retrieving content
  else if m.MenuScreen.itemSelected=6
    'ShowReadyScreen()
    'RunReadyTask() ' retrieving content
  end if
end sub