function getApiRequest(path as String, params = {} as Object, objectConverter = defaultConverter as Dynamic) as Object
  url = m.global.config.apiUrl + path
  return apiRequest(url, params, "GET", objectConverter)
end function

function getApiRequestLive(path as String, params = {} as Object, objectConverter = defaultConverter as Dynamic) as Object
  url = m.global.config.apiUrlLivestream + path
  return apiRequest(url, params, "GET", objectConverter)
end function


function postApiRequest(path as String, params = {} as Object, objectConverter = defaultConverter as Dynamic) as Object
  url = m.global.config.apiUrl + path
  return apiRequest(url, params, "POST", objectConverter)
end function


function postFormApiRequest(path as String, params = {} as Object, objectConverter = defaultConverter as Dynamic, Method = "POST") as Object
  url = m.global.config.apiUrl + path
  http = NewHttp(url, "application/x-www-form-urlencoded")
  http.Params = params
  http.Method = Method
  response = http.Request()
  Dbg(method, http.http.getUrl())
  Dbg("Request params", params)
  Dbg("Request body", http.body)

  if response = "" then return invalid

  return apiFormatResponse(response, objectConverter)
end function


function apiRequest(url as String, params = {} as Object, method = "GET" as String, objectConverter = defaultConverter as Dynamic) as Object
  http = NewHttp(url)
  http.Params = params
  http.Method = method
  response = http.Request()
  Dbg(method, http.http.getUrl())
  Dbg("Request params", params)
  Dbg("Request body", http.body)

  if response = "" then return invalid

  return apiFormatResponse(response, objectConverter)
end function


function s2memberApiRequest(url as String, params = {} as Object, method = "POST" as String, objectConverter = defaultConverter as Dynamic) as Object
  http = NewHttp(url, "application/x-www-form-urlencoded")
  http.Params = {"s2member_pro_remote_op": FormatJson(params)}
  http.Method = method
  response = http.Request()
  Dbg(method, http.http.getUrl())
  Dbg("Request params", params)
  Dbg("Request body", http.body)
  Dbg("Response Code", http.responseCode)

  if response = "" then return invalid

  return apiFormatResponse(response, objectConverter)
end function


function apiFormatResponse(responseData as Dynamic, objectConverter = defaultConverter as Dynamic) as Object
  responseJson = ParseJson(responseData)
  Dbg("Response", responseJson)
  if responseJson <> invalid then return objectConverter(responseJson)
  return invalid
end function


' ********************************************************************************
' Default Converter
' ********************************************************************************
function defaultConverter(response) as Object
  return response
end function


function isNonErrorResponse(response)
  return not isEmpty(response)
end function


' ********************************************************************************
' Creates error AA
' message and error code can be set as parameter
' ********************************************************************************
function createError(message="Server response error", code=0) as Object
  if isnonemptystr(message)
    apiError = { error: { message: message,code: code } }
  else
    apiError = { error: { message: "Server response error", code: 0 } }
  end if
  Dbg("apiError", apiError)
'  setNodeField(m.global, "apiError", apiError)
  return invalid
end function


sub initTask()
  Dbg("initTask")
  setAppConfig()
  m.top.responseAA = {}
end sub

sub ottFeedAnalyticsTask()
  Dbg("ottFeedAnalyticsTask")
  ottFeedAnalyticsRequest(m.top.params)
end sub


sub ottFeedAnalyticsRequest(params)
  Dbg("ottFeedAnalyticsRequest")
  ' apiRequest(m.global.config.OTTfeedAnalyticsURL, params)
  http = NewHttp(m.global.config.OTTfeedAnalyticsURL)
  http.Params = params
  response = http.Request()
  Dbg("GET", http.http.getUrl())
  Dbg("Request params", params)
  Dbg("Request body", http.body)
end sub


sub getContentTask()
  Dbg("getContentTask")
  m.top.responseNode = getContent()
end sub


sub getCollectionTask()
  Dbg("getCollectionTask")
  m.top.responseNode = getCollection(m.top.params)
end sub


sub searchTask()
  Dbg("searchTask")
  m.top.responseNode = search(m.top.params.searchTerm)
end sub


sub addToQueueTask()
  Dbg("addToQueueTask")
  if isnonemptystr(m.top.params.id)
    addToQueueResponse = postFormApiRequest("/queues/" + m.top.params.id)
    queues = m.global.user.queues
    queues[m.top.params.id] = true
    m.global.user.queues = queues
    m.top.responseAA = {}
  else
  end if
end sub


sub removeFromQueueTask()
  Dbg("removeFromQueueTask")
  if isnonemptystr(m.top.params.id)
    addToQueueResponse = postFormApiRequest("/queues/" + m.top.params.id, invalid, defaultConverter, "DELETE")
    queues = m.global.user.queues
    queues[m.top.params.id] = false
    m.global.user.queues = queues
    m.top.responseAA = {}
  else
  end if
end sub


sub autoLoginTask()
  Dbg("autoLoginTask")
  email = RegRead("email", m.global.config.regSection, "")
  password = RegRead("password", m.global.config.regSection, "")
  if email <> "" and password <> ""
    if m.global.config.firebaseAuth = true
      m.top.params = {credentials: [{
            id: "email"
            value: email
      },{
            id: "password"
            value: password
      }]}
    else if m.global.config.s2memberAuth = true
      m.top.params = {credentials: [{
            id: "user_login"
            value: email
      },{
            id: "user_pass"
            value: password
      }]}
    end if
  end if
  loginTask()
end sub


sub storeCredentials(email, password)
  Dbg("storeCredentials", email)
  if isnonemptystr(email) and isnonemptystr(password)
    RegWrite("email", email, m.global.config.regSection)
    RegWrite("password", password, m.global.config.regSection)
  end if
end sub


sub loginTask()
  Dbg("loginTask", m.top.params)
  responseAA = invalid
  if m.top.params <> invalid and isnonemptyArray(m.top.params.credentials)
    isSuccess = false
    params = {}
    for each cred in m.top.params.credentials
      params[cred.id] = cred.value
    end for
    if m.global.config.firebaseAuth = true
      params["returnSecureToken"] = true
      url = m.global.config.firebaseAuthUrl + m.global.config.authenticationAPIKey
      response = apiRequest(url, params, "POST")
      isSuccess = isNonErrorResponse(response) and isnonemptystr(response.idToken)
      if isSuccess
        storeCredentials(response.email, params.password)
        response.password = params.password
        responseAA = response
      end if
    else if m.global.config.s2memberAuth = true
      password = params.user_pass
      params["user_login"] = LCase(params["user_login"])
      params["user_ip"] = CreateObject("roDeviceInfo").GetExternalIp()
      params = {"data": params}
      params["op"] = "auth_check_user"
      params["api_key"] = m.global.config.authenticationAPIKey
      response = s2memberApiRequest(m.global.config.s2memberAuthUrl, params)
      isSuccess = isNonErrorResponse(response) and response.id <> invalid
      if isSuccess
        userId = evalString(response.id)
        params["op"] = "get_user"
        params.data = {"user_id": userId}
        response = s2memberApiRequest(m.global.config.s2memberAuthUrl, params)
        email = response.data.user_email
        storeCredentials(email, password)
        responseAA = {
          email: email
          password: password
          idToken: userId
          localId: userId
          role: response.role
        }
      end if
    end if
  end if
  m.top.responseAA = responseAA
end sub


sub registrationTask()
  Dbg("registrationTask", m.top.params)
  responseAA = invalid
  if m.top.params <> invalid and isnonemptyArray(m.top.params.credentials)
    params = {}
    for each cred in m.top.params.credentials
      if cred.id <> "signup" then params[cred.id] = cred.value
    end for
    if m.global.config.firebaseAuth = true
      params["returnSecureToken"] = true
      url = m.global.config.firebaseRegisterUrl + m.global.config.authenticationAPIKey
      response = apiRequest(url, params, "POST")
      isSuccess = isNonErrorResponse(response) and isnonemptystr(response.idToken)
      if isSuccess
        storeCredentials(response.email, params.password)
        response.password = params.password
        responseAA = response
      end if
    else if m.global.config.s2memberAuth = true
      password = params.user_pass
      params["s2member_registration_ip"] = CreateObject("roDeviceInfo").GetExternalIp()
      params["user_email"] = params["user_login"]
      params["user_login"] = LCase(params["user_login"])
      params = {"data": params}
      params["op"] = "create_user"
      params["api_key"] = m.global.config.authenticationAPIKey
      response = s2memberApiRequest(m.global.config.s2memberAuthUrl, params)
      isSuccess = isNonErrorResponse(response) and response.id <> invalid
      if isSuccess
        userId = evalString(response.id)
        params["op"] = "get_user"
        params.data = {"user_id": userId}
        response = s2memberApiRequest(m.global.config.s2memberAuthUrl, params)
        email = response.data.user_email
        storeCredentials(email, password)
        responseAA = {
          email: email
          password: password
          idToken: userId
          localId: userId
          role: response.role
        }
      end if
    end if
  end if
  m.top.responseAA = responseAA
end sub


function isInValidityPeriod(film)
  if film <> invalid and film.content <> invalid
    if isnonemptystr(film.content.validityPeriodStart) and isnonemptystr(film.content.validityPeriodEnd)
      date = CreateObject("roDateTime")
      now = date.asSeconds()
      date.fromISO8601String(film.content.validityPeriodStart)
      validityPeriodStart = date.asSeconds()
      date.fromISO8601String(film.content.validityPeriodEnd)
      validityPeriodEnd = date.asSeconds()
      if validityPeriodStart < now and now < validityPeriodEnd then return true
      return false
    end if
  end if
  return true
end function


function getContent() as Object
  Dbg("getContent")

  contentsResponse = getApiRequestLive("")
  Dbg("getContentLive", contentsResponse)
  result = createObject("roSGNode", "ContentNode")
  
  
  if isNonErrorResponse(contentsResponse)
    Dbg("LiveStream: NOT empty")
    m.global.systemLanguage = evalString(contentsResponse.language)
    categoriesIndex = {"continueWatching": []}
    categoryList = []
    videos = {}
    
    if isnonemptyArray(contentsResponse.categories)
      for each category in contentsResponse.categories
        if isnonemptystr(category.query) and isnonemptystr(category.name)
          categoriesIndex[category.name] = []
          categoryList.Push(category)
        else if isnonemptystr(category.playlistName) and isnonemptystr(category.name)
          categoriesIndex[category.name] = []
          categoryList.Push(category)
          for each playlist in contentsResponse.playlists
            if isnonemptystr(playlist.name) and playlist.name = category.playlistName
              playlist.cat = category.name
            end if
          end for
        end if
      end for
    end if
    for each feedSection in m.global.config.feedSections
      if isnonemptyArray(contentsResponse[feedSection.name])
        for each film in contentsResponse[feedSection.name]
          if isInValidityPeriod(film)
            item = movieParser(film)
  '          item.ContentType = feedSection.ContentType
            item.live = feedSection.isLive = true
            item.isShortFormVideo = feedSection.isShortFormVideos = true
            if item.position > 0 then categoriesIndex.continueWatching.Push(item)
            videos[item.id] = item
            if isnonemptyArray(item.tags)
              for each cat in categoryList
                for each tag in item.tags
                  'sattun
                  if isnonemptystr(cat.query) and cat.query.instr(tag) >= 0
                    categoriesIndex[cat.name].Push(item)
                    exit for
                  end if
                end for
              end for
            end if
          end if
        end for
      end if
    end for
    if isnonemptyArray(contentsResponse.playlists)
      for each playlist in contentsResponse.playlists
        if isnonemptyArray(playlist.itemIds)
          for each id in playlist.itemIds
            if videos[id] <> invalid then categoriesIndex[playlist.cat].Push(videos[id])
          end for
        end if
      end for
    end if
    
    if isnonemptyArray(categoryList)
      for each category in categoryList
        list = categoriesIndex[category.name]
        if isnonemptyArray(list)
          if category.order = "chronological"
            list.sortBy("dateAdded")
          else if category.order = "most_recent"
            list.sortBy("dateAdded", "r")
          end if
          item = List2ContentNode(list)
          item.title = category.name
          result.appendChild(item)
        end if
      end for
    end if
    if isnonemptyArray(categoriesIndex.continueWatching)
      list = categoriesIndex.continueWatching
      item = List2ContentNode(list)
      item.title = translate("Continue Watching")
      result.appendChild(item)
    end if
  end if




  contentsResponse = getApiRequest("")
  Dbg("getContent", contentsResponse)

  result = createObject("roSGNode", "ContentNode")
  if isNonErrorResponse(contentsResponse)
    if isEmpty (categoriesIndex)
      Dbg("LiveStream: empty")
      m.global.systemLanguage = evalString(contentsResponse.language)
      categoriesIndex = {"continueWatching": []}
      categoryList = []
      videos = {}
    end if
    if isnonemptyArray(contentsResponse.categories)
      for each category in contentsResponse.categories
        if isnonemptystr(category.query) and isnonemptystr(category.name)
          categoriesIndex[category.name] = []
          categoryList.Push(category)
        else if isnonemptystr(category.playlistName) and isnonemptystr(category.name)
          categoriesIndex[category.name] = []
          categoryList.Push(category)
          for each playlist in contentsResponse.playlists
            if isnonemptystr(playlist.name) and playlist.name = category.playlistName
              playlist.cat = category.name
            end if
          end for
        end if
      end for
    end if
    for each feedSection in m.global.config.feedSections
      if isnonemptyArray(contentsResponse[feedSection.name])
        for each film in contentsResponse[feedSection.name]
          if isInValidityPeriod(film)
            item = movieParser(film)
  '          item.ContentType = feedSection.ContentType
            item.live = feedSection.isLive = true
            item.isShortFormVideo = feedSection.isShortFormVideos = true
            if item.position > 0 then categoriesIndex.continueWatching.Push(item)
            videos[item.id] = item
            if isnonemptyArray(item.tags)
              for each cat in categoryList
                for each tag in item.tags
                  'sattun
                  if isnonemptystr(cat.query) and cat.query.instr(tag) >= 0
                    categoriesIndex[cat.name].Push(item)
                    exit for
                  end if
                end for
              end for
            end if
          end if
        end for
      end if
    end for
    if isnonemptyArray(contentsResponse.playlists)
      for each playlist in contentsResponse.playlists
        if isnonemptyArray(playlist.itemIds)
          numberX = 0
          for each id in playlist.itemIds
            if numberX < 100 
            if videos[id] <> invalid then categoriesIndex[playlist.cat].Push(videos[id])
            numberX = numberX + 1
            'Dbg("numberX:", numberX)
            end if 
            
          end for
        end if
      end for
    end if
    
    if isnonemptyArray(categoryList)
      for each category in categoryList
        list = categoriesIndex[category.name]
        if isnonemptyArray(list)
          if category.order = "chronological"
            list.sortBy("dateAdded")
          else if category.order = "most_recent"
            list.sortBy("dateAdded", "r")
          end if
          item = List2ContentNode(list)
          item.title = category.name
          result.appendChild(item)
        end if
      end for
    end if
    if isnonemptyArray(categoriesIndex.continueWatching)
      list = categoriesIndex.continueWatching
      item = List2ContentNode(list)
      item.title = translate("Continue Watching")
      result.appendChild(item)
    end if
  end if
  return result
end function


function getCollection(params) as Object
  Dbg("getCollection", params)
  contentsResponse = getApiRequest("/" + params.endpoint + "/" + params.id)
  result = invalid
  locale = m.global.systemLanguage
  if isNonErrorResponse(contentsResponse) and isnonemptyAA(contentsResponse)
    if isnonemptyArray(contentsResponse.contents)
      item = List2ContentNode(contentsResponse.contents, movieParser)
      if isnonemptystr(contentsResponse["name_" + locale])
        item.title = contentsResponse["name_" + locale]
      else
        item.title = contentsResponse.name_en
      end if
      item.id = params.endpoint + "_" + contentsResponse.id
      result = item
    end if
  end if
  return result
end function


function search(term) as Object
  if isnonemptystr(term)
    Dbg("search", term)
    contentsResponse = getApiRequest("")
    result = []
    if isNonErrorResponse(contentsResponse)
      moreResult = []
      for each feedSection in m.global.config.feedSections
        if isnonemptyArray(contentsResponse[feedSection.name])
          for each film in contentsResponse[feedSection.name]
            if isInValidityPeriod(film)
              item = movieParser(film)
              item.live = feedSection.isLive = true
              item.isShortFormVideo = feedSection.isShortFormVideos = true
              item.HDLISTITEMICONURL = "pkg:/images/icon-search-" + LCase(feedSection.name) + "-w.png"
              item.HDLISTITEMICONSELECTEDURL = "pkg:/images/icon-search-" + LCase(feedSection.name) + "-b.png"
              if LCase(film.title).inStr(term) >= 0 then result.push(item)
              if LCase(film.shortDescription).inStr(term) >= 0 then moreResult.push(item)
              if isnonemptyArray(item.seasons)
                for each season in item.seasons
                  searchInEpisodes(result, season.episodes, term)
                end for
              end if
              searchInEpisodes(result, item.episodes, term)
            end if
          end for
        end if
      end for
      if result.count() < 1 then result.append(moreResult)
    end if
    if result.count() > 0
      item = List2ContentNode(result)
      item.id = "search_" + term
      return item
    end if
  end if
  return invalid
end function


sub searchInEpisodes(result, episodes, term)
  if isnonemptyArray(episodes)
    for each episode in episodes
      if LCase(episode.title).inStr(term) >= 0
        episodeItem = movieParser(episode)
        episodeItem.ContentType = "episode"
        episodeItem.isShortFormVideo = true
        episodeItem.HDLISTITEMICONURL = "pkg:/images/icon-search-episode-w.png"
        episodeItem.HDLISTITEMICONSELECTEDURL = "pkg:/images/icon-search-episode-b.png"
        result.push(episodeItem)
      end if
    end for
  end if
end sub


sub getQueueIdsTask()
  Dbg("getQueueIdsTask")
  contentsResponse = getApiRequest("/profile")
  if isNonErrorResponse(contentsResponse) and isnonemptyAA(contentsResponse)
    if isnonemptyArray(contentsResponse.queues) and m.global.user <> invalid
      queues = {}
      for each q in contentsResponse.queues
        queues[q["_id"]] = true
      end for
      m.global.user.queues = queues
    end if
  end if
end sub


sub queueTask()
  Dbg("queueTask")
  m.top.responseNode = queue()
end sub


function queue()
  Dbg("queue")
  contentsResponse = getApiRequest("/profile")
  locale = m.global.systemLanguage
  if isNonErrorResponse(contentsResponse) and isnonemptyAA(contentsResponse)
    if isnonemptyArray(contentsResponse.queues)
      item = List2ContentNode(contentsResponse.queues, movieParser)
      if isnonemptystr(contentsResponse["name_" + locale])
        item.title = contentsResponse["name_" + locale]
      else
        item.title = contentsResponse.name_en
      end if
      queues = {}
      for each q in contentsResponse.queues
        queues[q["_id"]] = true
      end for
      m.global.user.queues = queues
      return item
    end if
  end if
  return invalid
end function


function parseEpisodes(episodes)
  if isnonemptyArray(episodes)
    result = []
    for each episode in episodes
      if isInValidityPeriod(episode)
        episodeItem = movieParser(episode)
        episodeItem.ContentType = "episode"
        result.push(episodeItem)
      end if
    end for
    result.sortBy("episodeNumber")
    return result
  end if
  return invalid
end function


function movieParser(itemAA)
  if isnonemptyAA(itemAA.rating) and isnonemptystr(itemAA.rating.rating)
    rating = itemAA.rating.rating
  else
    rating = ""
  end if
  bifUrl = {}
  if isnonemptyAA(itemAA.content)
    content = itemAA.content
    if isnonemptyArray(content.trickPlayFiles)
      anyBifUrl = invalid
      for each trickPlayFile in content.trickPlayFiles
        if isnonemptyAA(trickPlayFile) and isnonemptystr(trickPlayFile.url)
          bifUrl[trickPlayFile.quality + "BifUrl"] = trickPlayFile.url
          anyBifUrl = trickPlayFile.url
        end if
      end for
      if anyBifUrl <> invalid
        if bifUrl.SDBifUrl = invalid then bifUrl.SDBifUrl = anyBifUrl
        if bifUrl.HDBifUrl = invalid then bifUrl.HDBifUrl = anyBifUrl
        if bifUrl.FHDBifUrl = invalid then bifUrl.FHDBifUrl = anyBifUrl
      end if
    end if
  else
    content = {"dateAdded": "1970-01-01T00:00:00+00:00"}
  end if
  if isnonemptyArray(content.videos)
    video = content.videos[0]
  else
    video = {}
  end if
  if m.bookmarks = invalid then m.bookmarks = ParseJson(RegRead("bookmarks", m.global.config.regSection, "{}"))
  SubtitleTracks = []
  if isnonemptyArray(content.captions)
    for each caption in content.captions
      SubtitleTracks.push({Language: caption.language, Description: caption.language, TrackName: caption.url})
    end for
  end if
  actors = []
  directors = []
  if isnonemptyArray(itemAA.credits)
    for each credit in itemAA.credits
      if credit.role = "actor"
        actors.push(credit.name)
      else if credit.role = "director"
        directors.push(credit.name)
      end if
    end for
  end if
  ContentType = "movie"
  if isnonemptyArray(itemAA.seasons) or isnonemptyArray(itemAA.episodes) then ContentType = "series"
  if isnonemptyArray(itemAA.seasons)
    seasons = []
    for each season in itemAA.seasons
      season.episodes = parseEpisodes(season.episodes)
      seasons.push(season)
    end for
    seasons.sortBy("seasonNumber")
  else
    seasons = invalid
  end if
  episodes = parseEpisodes(itemAA.episodes)
  return  { id:               itemAA.id
            title:            itemAA.title
            description:      itemAA.longDescription
            shortDescription: itemAA.shortDescription
            categories:       itemAA.genres
            ContentType:      ContentType
            tags:             itemAA.tags
            LENGTH:           content.duration
            hdposterurl:      itemAA.thumbnail
            backdrop:         itemAA.backgroundImage
            boxcover:         itemAA.thumbnailBoxcover
            ReleaseDate:      evalString(itemAA.releaseDate)
            dateAdded:        evalString(content.dateAdded)
            adBreaks:         content.adBreaks
            skipIntroCredits: content.skipIntroCredits
            Actors:           actors
            directors:        directors
            seasons:          seasons
            episodes:         episodes
            episodeNumber:    itemAA.episodeNumber
            position:         evalInteger(m.bookmarks[itemAA.id])
            SubtitleTracks:   SubtitleTracks
            rating:           rating
            url:              video.url
            SDBifUrl:         bifUrl.SDBifUrl
            HDBifUrl:         bifUrl.HDBifUrl
            FHDBifUrl:        bifUrl.FHDBifUrl
          }
end function


sub vodInfoTask()
  if isnonemptyAA(m.top.params) and isnonemptystr(m.top.params.id)
    Dbg("vodInfoTask", m.top.params.id)
    contentsResponse = getApiRequest("")
    if isNonErrorResponse(contentsResponse)
      videos = []
      if isnonemptyArray(contentsResponse.movies) then videos.append(contentsResponse.movies)
      if isnonemptyArray(contentsResponse.shortFormVideos) then videos.append(contentsResponse.shortFormVideos)
      for each film in videos
        if film.id = m.top.params.id
          Dbg("found", film)
          m.top.responseAA = movieParser(film)
          exit for
        end if
      end for
    end if
  end if
end sub


function vodPositionTask()
  params = m.top.params
  if isNonEmptyAA(params) and params.id <> invalid
    if params.action = invalid then params.action = "get"
    if params.action = "store" and params.position <> invalid
      bookmarks = ParseJson(RegRead("bookmarks", m.global.config.regSection, "{}"))
      if params.position > 0
        bookmarkAA = {}
        bookmarkAA[params.id] = params.position
        bookmarks.append(bookmarkAA)
      else
        bookmarks.delete(params.id)
      end if
      RegWrite("bookmarks", FormatJson(bookmarks), m.global.config.regSection)
    else if params.action = "get"
      bookmarks = ParseJson(RegRead("bookmarks", m.global.config.regSection, "{}"))
      m.top.responseAA = {position: evalInteger(bookmarks[params.id])}
    end if
  end if

  m.top.control = "DONE"
end function


sub getSimilarTitles()
  Dbg("getSimilarTitles", m.top.params)
  if isnonemptyAA(m.top.params) and isnonemptystr(m.top.params.id)
    response = getApiRequest("/similar_titles/" + m.top.params.id)
'    m.top.responseNode = response
  end if
end sub


Function getCommonParams()
  di = CreateObject("roDeviceInfo")
  return  { client_tracking_id: getClientTrackingId(),
            app_id: CreateObject("roAppInfo").GetID(),
            app_name: CreateObject("roAppInfo").GetTitle(),
            model: di.GetModel(),
            device_display_name: di.GetModelDisplayName()
          }
end Function


sub getTextFromFile()
  titles = {"TermsOfUse": "Terms Of Use", "PrivacyPolicy": "Privacy Policy", "AboutUs": "About OTTfeed"}
  m.top.responseAA = {text: readasciifile("pkg:/resources/" + m.top.params.fileName), title: titles[m.top.params.fileName]}
End sub
