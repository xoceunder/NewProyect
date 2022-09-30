'******************************************************
'Registry Helper Functions
'******************************************************
Function regRead(key, section=invalid, defaultValue=invalid)
  if isInvalid(section) then section = "Default"
  sec = CreateObject("roRegistrySection", section)
  if sec.Exists(key) then return sec.Read(key)
  return defaultValue
End Function

Function regWrite(key, val, section=invalid)
  if isInvalid(section) then section = "Default"
  sec = CreateObject("roRegistrySection", section)
  sec.Write(key, val)
  sec.Flush() 'commit it
End Function

Function RegDelete(key, section=invalid)
    if isInvalid(section) then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
End Function


'******************************************************
'Insertion Sort
'Will sort an array directly, or use a key function
'******************************************************
Sub Sort(A as Object, key = invalid as dynamic)
  if not isArray(A) then return
  if key = invalid
    A.Sort()
  else
    if type(key) <> "Function" then return
    for i = 1 to A.Count() - 1
      valuekey = key(A[i])
      value = A[i]
      j = i-1
      while j >= 0 and key(A[j]) > valuekey
        A[j + 1] = A[j]
        j = j - 1
      end while
      A[j+1] = value
    next
  end if
End Sub


'******************************************************
'Convert anything to a string
'
'Always returns a string
'******************************************************
Function tostr(any)
  return AnyToString(any)
End Function


'******************************************************
'Get a " char as a string
'******************************************************
Function Quote()
  return Chr(34)
End Function


'******************************************************
'isxmlelement
'
'Determine if the given object supports the ifXMLElement interface
'******************************************************
Function isxmlelement(obj as dynamic) As Boolean
  if isInvalid(obj) then return false
  if GetInterface(obj, "ifXMLElement") = invalid return false
  return true
End Function


'******************************************************
'islist
'
'Determine if the given object supports the ifList interface
'******************************************************
Function islist(obj as dynamic) As Boolean
  if isInvalid(obj) then return false
  if GetInterface(obj, "ifList") = invalid return false
  return true
End Function


'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
Function itostr(i As Integer) As String
  return i.ToStr()
End Function


'******************************************************
'Get remaining hours from a total seconds
'******************************************************
Function hoursLeft(seconds As Integer) As Integer
  hours% = seconds / 3600
  return hours%
End Function


'******************************************************
'Get remaining minutes from a total seconds
'******************************************************
Function minutesLeft(seconds As Integer) As Integer
  hours% = seconds / 3600
  mins% = seconds - (hours% * 3600)
  mins% = mins% / 60
  return mins%
End Function


Function getHourStart(secs = 0)
  date = CreateObject("roDateTime")
  if evalBoolean(secs)
    date.fromSeconds(secs)
  else
    secs = date.asSeconds()
  end if
  hourStart = secs - date.GetSeconds() - date.GetMinutes() * 60
  return hourStart
end function


Function setHourStart(secs)
  m.hourStart = getHourStart(secs)
end function


'******************************************************
'Pluralize simple strings like "1 minute" or "2 minutes"
'******************************************************
Function Pluralize(val As Integer, str As String) As String
  ret = val.ToStr() + " " + str
  if val <> 1 then ret += "s"
  return ret
End Function


'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function


'******************************************************
'Tokenize a string. Return roList of strings
'******************************************************
Function strTokenize(str As String, delim As String) As Object
    st=CreateObject("roString")
    st.SetString(str)
    return st.Tokenize(delim)
End Function


Function strSplitTrim(str As String, delim As String) As Object
    st=str.Split(delim)
    for i=0 to st.count()-1
        st[i] = st[i].Trim()
    end for
    return st
End Function


'******************************************************
'Replace substrings in a string. Return new string
'******************************************************
Function strReplace(basestr As String, oldsub As String, newsub As String) As String
    return basestr.Replace(oldsub,newsub)
End Function


'******************************************************
'Get all XML subelements by name
'
'return list of 0 or more elements
'******************************************************
Function GetXMLElementsByName(xml As Object, name As String) As Object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            list.Push(e)
        endif
    next

    return list
End Function


'******************************************************
'Get all XML subelement's string bodies by name
'
'return list of 0 or more strings
'******************************************************
Function GetXMLElementBodiesByName(xml As Object, name As String) As Object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            b = e.GetBody()
            if type(b) = "roString" or type(b) = "String" list.Push(b)
        endif
    next

    return list
End Function


'******************************************************
'Get first XML subelement by name
'
'return invalid if not found, else the element
'******************************************************
Function GetFirstXMLElementByName(xml As Object, name As String) As dynamic
    if islist(xml.GetBody()) = false return invalid

    for each e in xml.GetBody()
        if e.GetName() = name return e
    next

    return invalid
End Function


'******************************************************
'Get first XML subelement's string body by name
'
'return invalid if not found, else the subelement's body string
'******************************************************
Function GetFirstXMLElementBodyStringByName(xml As Object, name As String) As dynamic
    e = GetFirstXMLElementByName(xml, name)
    if e = invalid return invalid
    if type(e.GetBody()) <> "roString" and type(e.GetBody()) <> "String" return invalid
    return e.GetBody()
End Function


'******************************************************
'Get the xml element as an integer
'
'return invalid if body not a string, else the integer as converted by strtoi
'******************************************************
Function GetXMLBodyAsInteger(xml As Object) As dynamic
    if type(xml.GetBody()) <> "roString" and type(xml.GetBody()) <> "String" return invalid
    return strtoi(xml.GetBody())
End Function


'******************************************************
'Parse a string into a roXMLElement
'
'return invalid on error, else the xml object
'******************************************************
Function ParseXML(str As String) As dynamic
    if isInvalid(str) then return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function


'******************************************************
'Get XML sub elements whose bodies are strings into an associative array.
'subelements that are themselves parents are skipped
'namespace :'s are replaced with _'s
'
'So an XML element like...
'
'<blah>
'    <This>abcdefg</This>
'    <Sucks>xyz</Sucks>
'    <sub>
'        <sub2>
'        ....
'        </sub2>
'    </sub>
'    <ns:doh>homer</ns:doh>
'</blah>
'
'returns an AA with:
'
'aa.This = "abcdefg"
'aa.Sucks = "xyz"
'aa.ns_doh = "homer"
'
'return an empty AA if nothing found
'******************************************************
Sub GetXMLintoAA(xml As Object, aa As Object)
    for each e in xml.GetBody()
        body = e.GetBody()
        if type(body) = "roString" or type(body) = "String" then
            name = e.GetName()
            name = strReplace(name, ":", "_")
            aa.AddReplace(name, body)
        endif
    next
End Sub


'******************************************************
'Walk an AA and print it
'******************************************************
Sub PrintAA(aa as Object)
    print "---- AA ----"
    if isInvalid(aa) then
        print "invalid"
        return
    else
        cnt = 0
        for each e in aa
            x = aa[e]
            PrintAny(0, e + ": ", aa[e])
            cnt = cnt + 1
        next
        if cnt = 0
            PrintAny(0, "Nothing from for each. Looks like :", aa)
        endif
    endif
    print "------------"
End Sub


'******************************************************
'Walk a list and print it
'******************************************************
Sub PrintList(list as Object)
    print "---- list ----"
    PrintAnyList(0, list)
    print "--------------"
End Sub


'******************************************************
'Print an associativearray
'******************************************************
Sub PrintAnyAA(depth As Integer, aa as Object)
    for each e in aa
        x = aa[e]
        PrintAny(depth, e + ": ", aa[e])
    next
End Sub


'******************************************************
'Print a list with indent depth
'******************************************************
Sub PrintAnyList(depth As Integer, list as Object)
  i = 0
  for each e in list
    PrintAny(depth, "List(" + i.ToStr() + ")= ", e)
    i = i + 1
  next
End Sub


'******************************************************
'Print anything
'******************************************************
Sub PrintAny(depth As Integer, prefix As String, any As Dynamic)
    if depth >= 10
        print "**** TOO DEEP " 5
        return
    endif
    prefix = string(depth*2," ") + prefix
    depth = depth + 1
    str = AnyToString(any)
    if str <> invalid
        print prefix + str
        return
    endif
    if type(any) = "roAssociativeArray"
        print prefix + "(assocarr)..."
        PrintAnyAA(depth, any)
        return
    endif
    if islist(any) or  isArray(any) then
        print prefix + "(list of " + itostr(any.Count()) + ")..."
        PrintAnyList(depth, any)
        return
    endif

    print prefix + "?" + type(any) + "?"
End Sub


'******************************************************
'Print an object as a string for debugging. If it is
'very long print the first 500 chars.
'******************************************************

Sub Dbg(pre As Dynamic, o=invalid As Dynamic)
  currTime = getCurrentTime()
  if isInvalid(o) then o = ""
  s = anyToString(o)
  s = Left(s, 2000)
  if m.top <> invalid and isnonemptystr(m.top.id)
    idtext = " [" + m.top.id + "] "
  else
    idtext = ""
  end if
  ? "[" + currTime + "] " idtext anyToString(pre), s
End Sub


' Friday 13 fix for Express+
function CreateDateTimeObject(dt)
  return CreateObject("roDatetime")
  day = CreateObject("roDatetime")
  if m.global.timeBugValue > 0 then day.fromSeconds(CreateObject("roDatetime").asSeconds() + m.global.timeBugValue)
  return day
end function


function getCurrentTime(withsec=true)
  currentTime = CreateObject("roDatetime")
  currentTime.Mark()
  currentTime.toLocalTime()
  secs = currentTime.GetSeconds()
  seconds = currentTime.asSeconds()
  formattedTime = secondsToTime(seconds)
  if withsec then formattedTime = formattedTime+" | " + secs.ToStr() + "s"
  return formattedTime
end function


function secondsToDuration(secs, withSeconds=false)
  date = CreateObject("roDatetime")
  date.fromSeconds(secs)
  hour    = date.GetHours()
  if hour > 0
    formattedTime = hour.ToStr() + "h "
    minutes = Num2ZeroLeadingStr(date.GetMinutes())
  else
    formattedTime = ""
    if date.GetMinutes() > 0
      minutes = date.GetMinutes().toStr()
    else if date.GetSeconds() > 0
      return "1m"
    else
      return "0m"
    end if
  end if
  formattedTime += minutes + "m"
  if withSeconds and date.GetSeconds() > 0 then formattedTime += " " + Num2ZeroLeadingStr(date.GetSeconds()) + "s"
  return formattedTime
end function


function secondsToTime(secs, usTimeFormat=true, zeroLeadingHours=false, withsec=false)
  date = CreateObject("roDatetime")
  if isInteger(secs) then date.fromSeconds(secs)
  
  hour    = date.GetHours()
  minutes = Num2ZeroLeadingStr(date.GetMinutes())
  
  if usTimeFormat
    periodIndicator = "AM"
    if (hour > 12 and hour <= 23)
      hour = hour - 12
      periodIndicator = "PM"
    else if (hour = 12)
      periodIndicator = "PM"
    else if (hour = 0)
      hour = 12       
    end if
  end if
  if zeroLeadingHours
    hour = Num2ZeroLeadingStr(hour)
  else
    hour = hour.ToStr()
  end if
  
  formattedTime = hour + ":" + minutes
  if withsec then formattedTime += ":" + Num2ZeroLeadingStr(date.GetSeconds())
  if usTimeFormat then formattedTime += " " + periodIndicator
  return formattedTime
end function


function timestampToLocalTimestamp(secs)
  date = CreateObject("roDatetime")
  date.fromSeconds(secs)
  date.toLocalTime()
  return date.asSeconds()
end function


function getCurrentTimeArray(hourshift=0)
    result = []
    currentTime = CreateObject("roDatetime")
    currentTime.Mark()
    currentTime.toLocalTime()
    
    periodIndicator = "AM"
    
    hour            = currentTime.GetHours() + hourshift
    minutes         = currentTime.GetMinutes()
    seconds         = currentTime.GetSeconds()
    
    if hour > 23 then
        hour = 12
    else if (hour > 12 and hour <= 23)
        hour = hour - 12
        periodIndicator = "PM"
    else if (hour = 12)
        periodIndicator = "PM"
    else if (hour = 0)
        hour = 12       
    end if
    hour = hour.ToStr()
    
    if (minutes < 10)
        minutes = "0" + minutes.ToStr()
    else
        minutes = minutes.ToStr()
    end if
    
    result.push(hour)
    result.push(minutes)
    result.push(seconds)
    result.push(periodIndicator)
    
    return result
end function


function getCurrentDate()
  currentDate = CreateObject("roDatetime")
  currentDate.Mark()
  Dbg("Now is", currentDate.asSeconds())
  return currentDate
end function


function daysBetweenDates(date1, date2) as Integer
  date1Secs = date1.AsSeconds()
  date2Secs = date2.AsSeconds()
  days = Abs((date2Secs - date1Secs)) / 60 / 60 / 24
  days = getCeiling(days)
  return days
end function


function fullDaysBetweenDates(dates, datee) as Integer
  date1 = CreateObject("roDatetime")
  if isNumber(dates) then
    date1.fromSeconds(dates)
  else if isDateTime(dates) then
    date1 = dates
  else if isString(dates) then
    date1.fromISO8601String(dates)
  end if
  date2 = CreateObject("roDatetime")
  if isNumber(datee) then
    date2.fromSeconds(datee)
  else if isDateTime(datee) then
    date2 = datee
  else if isString(datee) then
    date2.fromISO8601String(datee)
  end if
  date1Secs = date1.AsSeconds()
  date2Secs = date2.AsSeconds()
  days = int(Abs((date2Secs - date1Secs)) / 86400)
  return days
end function


function getCeiling(number as float) as Integer
  if Int(number) = number then ceiling = Int(number) else ceiling = Int(number) + 1
  return ceiling
end function


function getExpirationDays(expiration)
  date = CreateObject("roDatetime")
  if isNumber(expiration) then
    date.fromSeconds(expiration)
  else if isDateTime(expiration) then
    date = expiration
  else if isString(expiration) then
    date.fromISO8601String(expiration)
  end if
  return daysBetweenDates(CreateObject("roDatetime"), date)
end function


function getExpirationDate(secs)
  date = CreateObject("roDatetime")
  date.fromSeconds(secs)
  return date.AsDateString("no-weekday")
end function


function getCurrentTimeOffset(hourwidth, timeShift=0)
  date = CreateObject("roDatetime")
  sec = date.asSeconds() + timeShift
  date.fromSeconds(sec)
  return (hourwidth / 60) * date.getMinutes()
end function


function getTimeOffset(dateassecs, hourwidth)
  date = CreateObject("roDatetime")
  hours = date.getHours()
  date.fromSeconds(dateassecs)
  return (hourwidth/60) * ((date.getHours() - hours) * 60 + date.getMinutes())
end function


Function Num2ZeroLeadingStr(enumb, padding=2)
  return (String(padding, "0") + evalString(enumb)).Right(padding)
End Function


function convertDateTimeToDDMMYY(date)
  dateString = date.ToISOString().Split("T")[0]
  dateArray = dateString.Split("-")
  return dateArray[2]+dateArray[1]+dateArray[0].Right(2)
end function


function shiftDate(date, dayShift=0)
  if dayShift <> 0
    dateAsSecs = date.asSeconds()
    date = CreateObject("roDatetime")
    date.fromSeconds(dateAsSecs + dayShift*24*60*60)
  end if
  return date
end function


'******************************************************
'Try to convert anything to a string. Only works on simple items.
'
'Test with this script...
'
'    s$ = "yo1"
'    ss = "yo2"
'    i% = 111
'    ii = 222
'    f! = 333.333
'    ff = 444.444
'    d# = 555.555
'    dd = 555.555
'    bb = true
'
'    so = CreateObject("roString")
'    so.SetString("strobj")
'    io = CreateObject("roInt")
'    io.SetInt(666)
'    tm = CreateObject("roTimespan")
'
'    Dbg("", s$ ) 'call the Dbg() function which calls AnyToString()
'    Dbg("", ss )
'    Dbg("", "yo3")
'    Dbg("", i% )
'    Dbg("", ii )
'    Dbg("", 2222 )
'    Dbg("", f! )
'    Dbg("", ff )
'    Dbg("", 3333.3333 )
'    Dbg("", d# )
'    Dbg("", dd )
'    Dbg("", so )
'    Dbg("", io )
'    Dbg("", bb )
'    Dbg("", true )
'    Dbg("", tm )
'
'try to convert an object to a string. return invalid if can't
'******************************************************
Function AnyToString(any As Dynamic) As dynamic
  if isInvalid(any) then return LCase(type(any))
  if isString(any) then return any
  if isNumber(any) then return any.ToStr()
  if isBoolean(any) then return LCase(any.ToStr())
  if type(any) = "roTimespan" return itostr(any.TotalMilliseconds()) + "ms"
  if isAA(any)
    returnvalue = []
    for each arg in any.keys()
      returnvalue.push(arg + " : " + AnyToString(any[arg]))
    end for
    return "{ " + returnvalue.join(", ") + " }"
  else if isArray(any)
    returnvalue = []
    for each arg in any
      returnvalue.push(AnyToString(arg))
    end for
    return "[ " + returnvalue.join(", ") + " ]"
  else if isNode(any)
    return "<roSGNode>: " + AnyToString(nodeToAA(any))
  end if
  return ""
End Function


'******************************************************
'Walk an XML tree and print it
'******************************************************
Sub PrintXML(element As Object, depth As Integer)
  ? tab(depth*3);"Name: [" + element.GetName() + "]"
  if invalid <> element.GetAttributes() then
    print tab(depth*3);"Attributes: ";
    for each a in element.GetAttributes()
      print a;"=";left(element.GetAttributes()[a], 4000);
      if element.GetAttributes().IsNext() then print ", ";
    next
  endif

  if type(element.GetBody())="roString" or type(element.GetBody())="String" then
    print tab(depth*3);"Contains string: [" + left(element.GetBody(), 4000) + "]"
  else
    print tab(depth*3);"Contains list:"
    for each e in element.GetBody()
      PrintXML(e, depth+1)
    next
  endif
end sub


'******************************************************
'Return a random Registration Code with specified length
'******************************************************
Function generateRegistrationCode(codeLength As Integer) As String
  codeArray = ["-","0","1","2","3","4","5","6","7","8","9","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"]
  result=CreateObject("roString")
  for i = 1 to codeLength
    result.AppendString(codeArray[RND(36)],1)
  next
  return result
End Function


Function ReadManifest() AS Object
  manifest = {}
  lines = ReadASCIIFile("pkg:/manifest").Tokenize(Chr(10))
  FOR EACH line IN lines
    bits = line.Tokenize("=")
    if bits.Count() > 1
      manifest.AddReplace(bits[0].trim(), bits[1].trim())
    end if
  END FOR
  return manifest
END Function


function getSupportedUiResolutions()
  manifest_ui_resolutions = CreateObject("roAppInfo").GetValue("ui_resolutions")
  ui_resolutions = []
  if isnonemptystr(manifest_ui_resolutions)
    ui_resolutions = manifest_ui_resolutions.replace(" ", "").split(",")
    if ui_resolutions.count() > 0
      for i = 0 to ui_resolutions.count() - 1
        ui_resolutions[i] = LCase(ui_resolutions[i])
      end for
    else
    end if
  end if
  return ui_resolutions
end function


Function getScreenSize()
  di = CreateObject("roDeviceInfo")
  screenW = di.GetUIResolution().width
  screenH = di.GetUIResolution().height
  ui_resolutions = { width: screenW, height: screenH }
  uiResolutions = getSupportedUiResolutions()
  if uiResolutions.count() = 1
    if uiResolutions[0] = "sd"
      ui_resolutions = { width: 720, height: 480, name: "SD" }
    else if uiResolutions[0] = "hd"
      ui_resolutions = { width: 1280, height: 720, name: "HD" }
    else if uiResolutions[0] = "fhd"
      ui_resolutions = { width: 1920, height: 1080, name: "FHD" }
    end if
  else if uiResolutions.count() > 1
    if screenW = 720 and arrayContains(uiResolutions, "sd")
      ui_resolutions = { width: 720, height: 480, name: "SD" }
    else if screenW = 1280 and arrayContains(uiResolutions, "hd")
      ui_resolutions = { width: 1280, height: 720, name: "HD" }
    else if screenW = 1920 and arrayContains(uiResolutions, "fhd")
      ui_resolutions = { width: 1920, height: 1080, name: "FHD" }
    else if screenW = 1920 and arrayContains(uiResolutions, "hd")
      ui_resolutions = { width: 1280, height: 720, name: "HD" }
    else if screenW = 1920 and arrayContains(uiResolutions, "sd")
      ui_resolutions = { width: 720, height: 480, name: "SD" }
    else if screenW = 1280 and arrayContains(uiResolutions, "fhd")
      ui_resolutions = { width: 1920, height: 1080, name: "FHD" }
    else if screenW = 1280 and arrayContains(uiResolutions, "sd")
      ui_resolutions = { width: 720, height: 480, name: "SD" }
    else if screenW = 720 and arrayContains(uiResolutions, "hd")
      ui_resolutions = { width: 1280, height: 720, name: "HD" }
    else if screenW = 720 and arrayContains(uiResolutions, "fhd")
      ui_resolutions = { width: 1920, height: 1080, name: "FHD" }
    end if
  end if
  return ui_resolutions
end Function


function isString(obj) as boolean
  return not isInvalid(obj) and GetInterface(obj, "ifString") <> invalid
end function


function isInteger(value) as boolean
  return not isInvalid(value) and type(value) = "Integer" or type(value) = "roInt" or type(value) = "roInteger"
end function


function isDouble(obj) as boolean
  return not isInvalid(obj) and GetInterface(obj, "ifDouble") <> invalid
end function


Function isFloat(obj as dynamic) As Boolean
  return not isInvalid(obj) and GetInterface(obj, "ifFloat") <> invalid
End Function


function isNumber(value) as boolean
  return isInteger(value) or isFloat(value) or isDouble(value)
end function


function isBoolean(obj) as boolean
  return not isInvalid(obj) and GetInterface(obj, "ifBoolean") <> invalid
end function


function isDateTime(value) as boolean
    return not isInvalid(value) and type(value) = "roDateTime"
end function


function isArray(value) as boolean
    return not isInvalid(value) and type(value) = "roArray"
end function


function isAA(value) as boolean
    return not isInvalid(value) and type(value) = "roAssociativeArray"
end function


function isNode(value) as boolean
    return not isInvalid(value) and type(value) = "roSGNode"
end function


Function isnonemptystr(obj)
  return isString(obj) and Len(obj) > 0
End Function


function isNonEmptyArray(value) as boolean
  return (isArray(value) and value.count() > 0)
end function


function isEmptyAA(value) as boolean
  if isAA(value) then return value.items().count() = 0
  return true
end function


function isNonEmptyAA(value) as boolean
  return isAA(value) and value.items().count() > 0
end function


Function isEmpty(value)
  if isInvalid(value) then return true
  if isString(value) then return value = ""
  if isArray(value) then return value.Count() = 0
  if isNumber(value) then return value = 0
  if isAA(value) then return value.items().count() = 0
  if isBoolean(value) then return not value
  return false
End Function


function isFunction(value) as boolean
  if isInvalid(value) return false
  return type(value) = "roFunction" or type(value) = "Function"
end function


function isInvalid(value) as Boolean
  return type(value) = "<uninitialized>" or value = invalid
end function


function evalString(value) as string
  if isString(value) then return value
  if not isInvalid(value) and GetInterface(value, "ifToStr") <> invalid then return value.toStr()
  return ""
end function


function evalInteger(value)
  if isInteger(value) then return value
  if isNumber(value) then  return int(value)
  if isnonemptystr(value) then return value.toInt()
  return 0
end function


function evalFloat(value)
  if isFloat(value) then return value
  if isString(value) then return value.toFloat()
  if isInteger(value) then return (value.toStr()).toFloat()
  return 0
end function


function evalBoolean(value) as boolean
  if isInvalid(value) then return false
  if isBoolean(value) then return value
  if isString(value) then o = UCase(value.Trim())  :  return o = "TRUE" or o = "T" or o = "Y" or value = "1"
  if isNumber(value) then return value > 0
  if isArray(value) then return value.count() > 0
  if isAA(value) then return value.Keys().count() > 0
  return false
end function


function evalBooleanAsString(value) as string
  return evalBoolean(value).ToStr()
end function


function evalAA(value)
  if isAA(value) then return value
  return {}
end function


function evalObjectValue(value, path, defaultVal = invalid) as dynamic
  if isInvalid(value) then return defaultVal

  if isnonemptystr(path)
    parts = path.tokenize(".")
  else if isnonemptyArray(path)
    parts = path
  else
    return value
  end if

  result = value

  for i = 0 to parts.Count() - 1
    if isArray(result)
      parts[i] = evalInteger(parts[i])
      if parts[i] = invalid then return defaultVal
    else if isAA(result)
      result = result[parts[i]]
    else
      return defaultVal
    end if
  end for 

  return result
end function


function IntMin(a as integer, b as integer)
  if (a < b) then return a
  return b
end function


function IntMax(a as integer, b as integer)
  if (a > b) then return a
  return b
end function


function NumMin(a, b)
  if (isNumber(a) and isNumber(b))
    if (a < b) then return a
    return b
  end if 
  return invalid
end function


function NumMax(a, b)
  if (isNumber(a) and isNumber(b))
    if (a > b) then return a
    return b
  end if 
  return invalid
end function


function ArrayIndex(arr as object, value)
  if isnonemptyArray(arr)
    for i=0 to arr.count() - 1
      if arr[i] = value return i
    end for
  end if
  return -1
end function


function TextArrayContains(arr, value, caseSensitive=true)
  if isnonemptyArray(arr)
    for i=0 to arr.count() - 1
      if caseSensitive then
        if arr[i] = value then return true
      else
        if LCase(arr[i]) = LCase(value) then return true
      end if
    end for
  end if
  return false
end function


function ArrayContains(arr as object, value)
  if isnonemptyArray(arr)
    for i=0 to arr.count() - 1
      if arr[i] = value return true
    end for
  end if
  return false
end function


function ArrayFindAndRemove(arr as object, value)
  if isnonemptyArray(arr)
    for i=0 to arr.count() - 1
      if arr[i] = value
        arr.delete(i) 
        return true
      end if
    end for
  end if
  return false
end function


function ArrayLeft(arr as object, value)
  if isnonemptyArray(arr)
    if value >= arr.count() then return arr
    while value < arr.count()
      item = arr.pop()
    end while
  else
    arr = []
  end if
  return arr
end function


function ArrayRight(arr as object, value)
  if isnonemptyArray(arr)
    if value >= arr.count() then return arr
    while value < arr.count()
      item = arr.Shift()
    end while
  else
    arr = []
  end if
  return arr
end function


function copyAA(aa)
  result = {}
  if isnonemptyAA(aa) then result.Append(aa)
  return result
end function


function DateTimeLessThan(date1 as object, date2 as object)
  return (isDateTime(date1) and isDateTime(date2) and date1.asSeconds() < date2.asSeconds())
end function

function DateTimeGreaterThan(date1 as object, date2 as object)
  return (isDateTime(date1) and isDateTime(date2) and date1.asSeconds() > date2.asSeconds())
end function

function DateTimeEquals(date1 as object, date2 as object)
  return (isDateTime(date1) and isDateTime(date2) and date1.asSeconds() = date2.asSeconds())
end function


function DateEquals(date1 as object, date2 as object)
  return (isDateTime(date1) and isDateTime(date2) and date1.GetDayOfMonth() = date2.GetDayOfMonth() and date1.GetMonth() = date2.GetMonth() and date1.GetYear() = date2.GetYear())
end function


function isToday(date as object)
  return DateEquals(CreateObject("roDatetime"), date)
end function


function isYesterday(date as object)
  yesterday = CreateObject("roDatetime")
  yesterday.fromSeconds(yesterday.asSeconds() - 86400)
  return DateEquals(yesterday, date)
end function


Function convertFromBase64(b64String) as String
  if b64String <> invalid
    ba = CreateObject("roByteArray")
    ba.FromBase64String(b64String)
    return ba.ToAsciiString()
  end if
  return ""
End Function


Function bidirectionalAlgorithm(ltrString)
  if isnonemptystr(ltrString) <> invalid then
    if not isArabic(ltrString) then return ltrString
    rtlString = ""
    ltrStringA = ltrString.Split("")
    rtl = getFirstRTL(ltrString)
    for each wd in getSwitchingWords(ltrString)
      if rtl then
        rtlString = rtlString + rightToLeft(wd)
      else
        rtlString = rtlString + wd
      end if
      rtl = not rtl
    end for
    return rtlString
    switchingPositionsArray = getSwitchingPositions(ltrString)
    if switchingPositionsArray.count()>2 then
      for z=0 to switchingPositionsArray.count() -2
        switchingLen = switchingPositionsArray[z+1]-switchingPositionsArray[z]
        if rtl then
          rtlString = rtlString + rightToLeft(Mid(ltrString,switchingPositionsArray[z], switchingLen))
        else
          rtlString = rtlString + Mid(ltrString,switchingPositionsArray[z], switchingLen)
        end if
        rtl = not rtl
      end for
    else
      rtlString = ltrString
    end if
    return rtlString.Trim()
  else
    return ""
  end if
End Function


Function getSwitchingWords(originalString)
  rtl = getFirstRTL(originalString)
  osA = originalString.Split("")
  slen = []
  z=0
  for i=0 to Len(originalString)-1
    if osA[i]<>" " and ((not rtl and Asc(osA[i]) >= 1536) or (rtl and Asc(osA[i]) < 1536)) then
      slen.push(z)
      z=0
      rtl = not rtl
    end if
    z=z+1
  end for
  slen.push(z)
  switchingWords = []
  for each x in slen
    switchingWords.push(originalString.left(x))
    originalString=originalString.mid(x)
  end for
  return switchingWords
End Function


Function getSwitchingPositions(originalString)
  rtl = getFirstRTL(originalString)
  sps = [0]
  osA = originalString.Split("")
  for i=0 to Len(originalString)-1
    if osA[i]<>" " and ((not rtl and Asc(osA[i]) >= 1536) or (rtl and Asc(osA[i]) < 1536)) then
      sps.Push(i)
      rtl = not rtl
    end if
  end for
  sps.Push(Len(originalString)-1)
  return sps
End Function


Function getFirstRTL(originalString)
  osA = originalString.Trim().Split("")
  if Asc(osA[0]) >= 1536 then
    return true
  else
    return false
  end if
End Function


Function getSwitchingPos(originalString,startPosition,rtl)
  os = Mid(originalString,startPosition)
  osA = originalString.Split("")
  for i=startPosition to Len(originalString)-1
    if osA[i]<>" " and ((not rtl and Asc(osA[i]) >= 1536) or (rtl and Asc(osA[i]) < 1536)) then return i
  end for
  return Len(originalString)
End Function


Function rightToLeft(ltrString) as String
  trimmedstr = ltrString.trim()
  rtlString = ""
  ltrStringA = trimmedstr.Split("")
  ie = Len(trimmedstr)-1
  for i=ie to 0 Step -1
    rtlString = rtlString+ltrStringA[i]
  end for
  return ltrString.replace(trimmedstr,rtlString)
End Function


Function isArabic(ltrString)
  if isnonemptystr(ltrString) then
    osA = ltrString.Split("")
    for i=0 to Len(ltrString)-1
      if Asc(osA[i]) >= 1536 then return true
    end for
    return false
  else
    return false
  end if
End Function


Function joinArray(arraytojoin, joinChar)
 if isnonemptyArray(arraytojoin)
   returnvalue = arraytojoin.Join(joinChar).trim()
'   if returnvalue.right(joinChar.trim().len())=joinChar.trim() then return returnvalue.Left(returnvalue.len()-joinChar.trim().len())
 else
  returnvalue = ""
 end if
 return returnvalue
End Function


Function isAllowedRating(movieRating, userRating)
    if userRating=invalid or userRating="G" then return true
    if movieRating=invalid then return false
    ratings = {}
    'ratings["NR"] = 1000
    ratings["G"]        = 10
    ratings["TV-G"]     = 10
    ratings["TV-Y"]     = 10
    ratings["TV-Y7"]    = 10
    ratings["TV-Y7FV"]  = 10
    ratings["TV-Y7 FV"] = 10
    ratings["TV-FV"]    = 10
    ratings["PG"]       = 20
    ratings["TV-PG"]    = 20
    ratings["PG-13"]    = 30
    ratings["TV-14"]    = 30
    ratings["R"]        = 40
    ratings["NC-17"]    = 50
    ratings["TV-MA"]    = 50
    ratings["UR"]    = 50
    ratings["NR"]    = 50
    if ratings[UCase(movieRating)]=invalid or ratings[userRating]=invalid then return true
    return ratings[UCase(movieRating)] < ratings[userRating]
End Function


'============ FS functions start =================='


function getFSPrefix(filename)
  if isnonemptystr(filename)
    if LCase(filename.left(4)) = "tmp:" or LCase(filename.left(8)) = "cachefs:" then return ""
    if LCase(filename.left(1)) = "/" then return "tmp:"
  end if
  return "tmp:/"
end function


function restoreFile(filename) as Object
  if isnonemptystr(filename)
    fileSystem = CreateObject("roFileSystem")
    filename = getFSPrefix(filename) + filename

    if fileSystem.Exists(filename)
      ba = CreateObject("roByteArray")

      if ba.ReadFile(filename)
        jsonString = ba.ToAsciiString()
        content = parseJson(jsonString)
        return content
      end if
    end if
  end if
  return invalid
end function


function saveFile(filename, content) as Object
   result = false
   if isnonemptystr(filename) and not isInvalid(content)
      fileSystem = CreateObject("roFileSystem")
      filename = getFSPrefix(filename) + filename

      pathArray = filename.split("/")
      path = pathArray.shift() + "/"
      pathArray.pop()
      if pathArray.count() > 0
        for each dir in pathArray
          path += dir
          fileSystem.CreateDirectory(path)
          path += "/"
        end for
      end if
      if fileSystem.Exists(filename) then fileSystem.Delete(filename)

      jsonString = FormatJSON(content)
      ba = CreateObject("roByteArray")
      ba.FromAsciiString(jsonString)

      result = ba.WriteFile(filename)

      if not result then fileSystem.Delete(filename)
  end if
  return result
end function


'============ FS functions end =================='


'============ Cache functions start =================='


Function cacheIt(cacheData, cacheName) as Boolean
  saveObject = {}
  saveObject.response = cacheData
  saveObject.datetime = CreateObject("roDateTime").AsSeconds().toStr()
  return saveFile("cachefs:/cache/" + cacheName, saveObject)
end Function


Function getItFromCache(cacheName, cacheTtl = 172800) as Object
  Dbg("getItFromCache")
  jsonString = restoreFile("cachefs:/cache/" + cacheName)
  if jsonString = invalid then return invalid
  savedObj = parseJson(jsonString)
  if savedObj = invalid then return invalid

  date = CreateObject("roDateTime")
  if ((date.AsSeconds() - savedObj.datetime.toInt()) > cacheTtl)
    fileSystem = CreateObject("roFileSystem")
    fileSystem.Delete("cachefs:/cache/" + cacheName)
  else
    return savedObj.response
  end if
  return invalid
end Function


function ClearCache()
  fileSystem = CreateObject("roFileSystem")
  return fileSystem.Delete("cachefs:/cache")
end function


'============ Cache functions end =================='


Function checkStreamFormat(streamFormat, defaultStreamFormat="mp4")
  availableFormats = ["mp4", "mkv", "hls", "ts", "wma", "mp3", "ism", "dash", "mka","mks", "wmv"]
  if isnonemptystr(streamFormat) and ArrayContains(availableFormats, streamFormat) then return streamFormat
  return defaultStreamFormat
End Function


Function getStreamFormat(url, defaultStreamFormat="mp4")
  if isnonemptystr(url)
    formatPatterns =  {
                        ".m3u8" : "hls"
                        ".mp4" : "mp4"
                        ".mp3" : "mp3"
                      }
    for each key in formatPatterns.Keys()
      if url.Instr(key) >= 0 return formatPatterns[key]
    end for
  end if
  return defaultStreamFormat
End Function


Function stringPadding(value, finalStrLen, paddingChr = "0", leftPadding = true)
  while value.len() < finalStrLen
    if leftPadding
      value = paddingChr + value
    else
      value += paddingChr
    end if
  end while
  return value
End Function


Function getUserAgent()
  version = CreateObject("roDeviceInfo").GetOsVersion()
  version_major = version.major
  version_minor = version.minor
'  version_build = mid(version,8,5)
  if version_minor.toint() < 10 then version_minor = mid(version_minor,2)
  return "Roku/DVP-" + version_major + "." + version_minor + " (" + version + ")"
End Function


Function getFirmwareVersion()
  version = CreateObject("roDeviceInfo").GetOsVersion()
  return [ version.major.toInt(), version.minor.toInt(), version.build.toInt() ]
End Function


Function compareFirmwareVersion(major, minor, build=invalid)
  version = getFirmwareVersion()
  if build = invalid then build = version[2]
  return (version[0] >= major) and (version[1] >= minor) and (version[2] >= build)
End Function

Function GeToken() As String
    hexChars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    hexString = ""
    For i = 1 to 25
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    Next
    return hexString+"&token="+hexString
End Function

Function GetModel() as string

    models = {}
    models["N1050"] = "Roku SD"
    models["N1000"] = "Roku HD Classic"
    models["N1100"] = "Roku HD Classic"
    models["2050X"] = "Roku XD"
    models["2050N"] = "Roku XD"
    models["N1101"] = "Roku XD|S Classic"
    models["2100X"] = "Roku XD|S"
    models["2100N"] = "Roku XD|S"
    models["2000C"] = "Roku HD"
    models["2500X"] = "Roku HD"
    models["2400X"] = "Roku LT"
    models["2450X"] = "Roku LT"
    models["2400SK"] = "Roku TV"
    models["2700X"] = "Roku LT" '2013
    models["2710X"] = "Roku 1" '2013
    models["2710R"] = "Roku 1" '2015
    models["2720X"] = "Roku 2" '2013
    models["3000X"] = "Roku 2 HD"
    models["3050X"] = "Roku 2 XD"
    models["3100X"] = "Roku 2 XS"
    models["3400X"] = "Roku Streaming Stick"
    models["3420X"] = "Roku Streaming Stick"
    models["3500R"] = "Roku Streaming Stick" '2014
    models["3500X"] = "Roku Streaming Stick" '2015
    models["4200X"] = "Roku 3"
    models["4200R"] = "Roku 3"
    models["4210X"] = "Roku 2" '2015
    models["4210R"] = "Roku 2" '2015
    models["4230X"] = "Roku 3" '2015
    models["4230R"] = "Roku 3" '2015 
    models["3600X"] = "Roku Streaming Stick"
    models["4400X"] = "Roku 4"
    models["3700X"] = "Roku Express"
    models["3710X"] = "Roku Express+"
    models["4620X"] = "Roku Premiere"
    models["4630X"] = "Roku Premiere+"
    models["4640X"] = "Roku Ultra"
    models["5000X"] = "Roku TV"
    models["5101X"] = "Roku TV"
    models["5103X"] = "Roku TV"
    models["6000X"] = "Roku 4K TV"
    models["7000X"] = "Roku 4K TV"
    models["7010X"] = "Roku 4K TV"
    
    device = CreateObject("roDeviceInfo")

    modelNumber = device.GetModel()

   If models.DoesExist(modelNumber) Then
        modelName = models[modelNumber]
    Else
        modelName = "Roku " + modelNumber
    End If

    return modelName
End Function

Function getDeviceESN()
  return getClientTrackingId()
End Function


Function getClientTrackingId()
  return CreateObject("roDeviceInfo").GetChannelClientId()
End Function


Function isRIDADisabled()
  return CreateObject("roDeviceInfo").IsRIDADisabled()
End Function


Function isOpenGl()
  gp = CreateObject("roDeviceInfo").GetGraphicsPlatform()
  return (LCase(gp) = "opengl")
End Function


Function setGlobalField(key, value)
  if m.global.hasField(key)
    m.global[key] = value
  else
    fields = {}
    fields[key] = value
    m.global.addFields(fields)
  end if
end Function


function getPrintableDate(date)
  months = ["Jan", "Feb", "March", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  if m.global.systemLanguage = getLanguageList()[1]
    return translate(months[date.GetMonth()-1]) + " " + date.GetDayOfMonth().toStr()
  else
    return date.GetDayOfMonth().toStr() + " " + translate(months[date.GetMonth()-1])
  end if
end function


Function tvpGetTzdata() As Object
  tzList = {}
  tzList["US/Puerto Rico-Virgin Islands"] = {
      timezones: ["AST"],
      cities: ["America/Puerto_Rico"]
  }
  tzList["US/Guam"] = {
      timezones: ["ChST"],
      cities: ["Pacific/Guam"]
  }
  tzList["US/Samoa"] = {
      timezones: ["SST"],
      cities: ["Pacific/Midway"]
  }
  tzList["US/Hawaii"] = {
      timezones: ["HAST"],
      cities: ["Pacific/Honolulu"]
  }
  tzList["US/Aleutian"] = {
      timezones: ["HAST/HADT"],
      cities: ["America/Adak"]
  }
  tzList["US/Alaska"] = {
      timezones: ["AKST/AKDT"],
      cities: ["America/Anchorage"]
  }
  tzList["US/Pacific"] = {
      timezones: ["PST/PDT"],
      cities: ["America/Los_Angeles"]
  }
  tzList["US/Arizona"] = {
      timezones: ["MST"],
      cities: ["America/Phoenix"]
  }
  tzList["US/Mountain"] = {
      timezones: ["MST/MDT"],
      cities: ["America/Denver"]
  }
  tzList["US/Central"] = {
      timezones: ["CST/CDT"],
      cities: ["America/Chicago"]
  }
  tzList["US/Eastern"] = {
      timezones: ["EDT/EST"],
      cities: ["America/New_York"]
  }
  tzList["Canada/Pacific"] = {
      timezones: ["PST/PDT"],
      cities: ["America/Vancouver"]
  }
  tzList["Canada/Mountain"] = {
      timezones: ["MST/MDT"],
      cities: ["America/Edmonton"]
  }
  tzList["Canada/Central Standard"] = {
      timezones: ["CST"],
      cities: ["America/Regina"]
  }
  tzList["Canada/Central"] = {
      timezones: ["CST/CDT"],
      cities: ["America/Winnipeg"]
  }
  tzList["Canada/Eastern"] = {
      timezones: ["EST/EDT"],
      cities: ["America/Toronto"]
  }
  tzList["Canada/Atlantic"] = {
      timezones: ["AST/ADT"],
      cities: ["America/Halifax"]
  }
  tzList["Canada/Newfoundland"] = {
      timezones: ["NST/NDT"],
      cities: ["America/St_Johns"]
  }
  tzList["Europe/Iceland"] = {
      timezones: ["GMT"],
      cities: ["Atlantic/Reykjavik"]
  }
  tzList["Europe/Ireland"] = {
      timezones: ["IST/GMT"],
      cities: ["Europe/Dublin"]
  }
  tzList["Europe/United Kingdom"] = {
      timezones: ["BST/GMT"],
      cities: ["Europe/London"]
  }
  tzList["Europe/Portugal"] = {
      timezones: ["WET/WEST"],
      cities: ["Europe/Lisbon"]
  }
  tzList["Europe/Central European Time"] = {
      timezones: ["CET/CEST"],
      cities: ["Europe/Brussels"]
  }
  tzList["Europe/Greece/Finland"] = {
      timezones: ["EEST/EET"],
      cities: ["Europe/Athens"]
  }
  return tzList[CreateObject("roDeviceInfo").GetTimeZone()]
End Function


Function tvpIsTimezoneSynced(timezone As String) As Dynamic
  tzdata = tvpGetTzdata()
  If tzdata = Invalid then return Invalid

  For Each city In tzdata.cities
    If timezone = city then return True
  End For
  return false
End Function


Function tvpGetTzdataCity() As String
  tzdata = tvpGetTzdata()
  If tzdata = Invalid then return "America/Toronto"
  return tzdata.cities[0]
End Function


function secondsToReleaseDate(secs)
  date = CreateObject("roDatetime")
  date.fromSeconds(secs)
  month = m.global.config.epgDateMonths[date.GetMonth() - 1]
  dateString = date.getDayOfMonth().toStr() + " " + month + " " + date.getYear().toStr()
  return dateString + " " + translate("at") + " " + date.GetHours().toStr() + ":" + Num2ZeroLeadingStr(date.GetMinutes())
end function


function isHevcCompatibleDevice()
  ' Check if the Roku player can decode 4K 60fps HEVC streams or 4K 30fps vp9 streams
  hevc_video = { Codec: "hevc", Profile: "main", Level: "5.1" }
  can_decode_hevc = CreateObject("roDeviceInfo").CanDecodeVideo(hevc_video)
  return can_decode_hevc.result = true
end function


Function degreesToRadians(degrees)
  return evalInteger(degrees) * 3.14159265359 / 180
End Function


Function timeStringToSeconds(timeString)
  seconds = 0
  if isnonemptystr(timeString)
    list = timeString.Split(":")
    s = 1
    for i = list.count() - 1 to 0 step -1
      seconds += list[i].toInt() * s
      s *= 60
    end for
  end if
  return seconds
end Function


Function findNonZeroValue(values)
  for each value in values
    if value <> 0 then return value
  end for
  return 0
End Function


function Stringify(value as Dynamic) as String
  if value <> invalid and GetInterface(value, "ifToStr") <> invalid then return value.toStr()
  return ""
end function


Function escapeHtml(html)
  if isInvalid(html) then return ""

  r = CreateObject("roRegex", "<\s?(?i)br(?-i)\s?\/?>", "i")
  html = r.replaceAll(html, chr(10))

  r = CreateObject("roRegex", "<[^<]+?>", "i")
  html = r.replaceAll(html, "")

  entities =  { "&amp;": "&",
                "&quot;": chr(34),
                "&apos;": chr(39),
                "&lt;": "<",
                "&gt;": ">",
                "&laquo;": "<<",
                "&raquo;": ">>",
                "&lsaquo;": "<",
                "&rsaquo;": ">",
                "&copy;": chr(169),
                "&reg;": chr(174),
                "&trade;": chr(8482)
              }
  for each key in entities.keys()
    html = html.replace(key, entities[key])
  end for

  return html
End Function

'******************************************************
' @return The MD5 hash of the specified text
'******************************************************
Function getMD5Hash(text As String) As String
  digest = CreateObject("roEVPDigest")
  digest.Setup("md5")
  ba = CreateObject("roByteArray")
  ba.FromAsciiString(text)
  digest.Update(ba)
  return LCase(digest.Final())
End Function