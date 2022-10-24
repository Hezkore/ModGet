SuperStrict

Import Audio.AudioMiniAudio
Import Audio.ModLoader

Import "common.bmx"
Import "moddatabase.bmx"

' Main function
Function Main()
	GCSetMode( 2 )
	
	' Do we have enough arguments?
	If AppArgs.Length < 2 Then Print "Not enough arguments";End
	
	' Process user arguments
	Select AppArgsCommand().ToLower()
		Case "update"
			WriteString( StandardIOStream, "Updating database... " )
			LoadCache()
			Local modCount:Int = Database.Count()
			UpdateCache()
			LoadCache()
			Print( "Done" )
			WriteString( StandardIOStream, Database.Count() + " mod files available" )
			If modCount Then
				Local diff:Int = Database.Count() - modCount
				WriteString( StandardIOStream, " (" )
				If diff = 0 Then
					WriteString( StandardIOStream, "+-0" )
				ElseIf diff > 0
					WriteString( StandardIOStream, "+" + diff )
				Else
					WriteString( StandardIOStream, diff )
				EndIf
				Print( "  difference)" )
			EndIf
			
		Case "search"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ), AppArgsOption( "e" ), , Int(AppArgsOption( "l" )) ) Then
				For Local e:TSearchEntry = EachIn Database.LastSearch
					PrintSearchInfo( e )
					If e <> Database.LastSearch.Last() Then Print()
				Next
			EndIf
			
		Case "download"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ), AppArgsOption( "e" ), 10, Int(AppArgsOption( "l" )) ) Then
				Local totalDownloadSize:Int
				Local count:Int
				For Local e:TSearchEntry = EachIn Database.LastSearch
					If DoDownload( e.ModEntry ) Then
						count:+1
						totalDownloadSize:+LastDownloadSize
					EndIf
					If e <> Database.LastSearch.Last() Then Print()
				Next
				Print( "~nDownloaded " + count + " file(s) (" + (totalDownloadSize/1024) + "kb)" )
			EndIf
			
		Case "play"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ), AppArgsOption( "e" ), 0, Int(AppArgsOption( "l" )) ) Then
				For Local e:TSearchEntry = EachIn Database.LastSearch
					DoPlay( e.ModEntry )
					If e <> Database.LastSearch.Last() Then Print()
				Next
			EndIf
	EndSelect

	' End of application
	Quit()
EndFunction

' Helper functions
Function PrepareCache()
	If NeedsToUpdateCache() Then
		WriteString( StandardIOStream, "Updating database... " )
		UpdateCache()
		LoadCache()
		Print( "Done" )
	Else
		WriteString( StandardIOStream, "Caching database... " )
		LoadCache()
		Print( "Done" )
	EndIf
EndFunction

Function DoSearch:Int( text:String, fArtist:String, fFile:String, fTracker:String, fExtra:String, maxMatch:Int = 100, limit:Int = 0 )
	WriteString( StandardIOStream, "Searching for " )
	If text Then
		WriteString( StandardIOStream, "~q" + text + "~q" )
	Else
		WriteString( StandardIOStream, "anything" )
	EndIf
	
	Local hasFilter:Int = fArtist Or fFile Or fTracker
	If hasFilter Then
		WriteString( StandardIOStream, " (filtered by" )
		If fArtist Then WriteString( StandardIOStream, " artist: " + fArtist )
		If fFile Then WriteString( StandardIOStream, " file: " + fFile )
		If fTracker Then WriteString( StandardIOStream, " tracker: " + fTracker )
		If fExtra Then WriteString( StandardIOStream, " extra: " + fExtra )
		WriteString( StandardIOStream, ")" )
	EndIf
	
	WriteString( StandardIOStream, "... " )
	
	Local matches:TList = Database.Search( text, fArtist, fFile, fTracker, fExtra, limit )
	
	Print( matches.Count() + " matches" )
	
	' Ask the user if he really wants to continue with this many matches
	If maxMatch > 0 And matches.Count() > maxMatch Then
		Print( "~nThere are over " + maxMatch + " matches" )
		WriteString( StandardIOStream, "Are you sure you want to continue? (Y/N) " )
		StandardIOStream.Flush()
		If Left( Input(""), 1 ).ToLower() = "y" Then
			'Return True
		Else
			Return False
		EndIf
	EndIf
	
	Return True
EndFunction

Function PrintSearchInfo( e:TSearchEntry )
	Print( QuoteIfSpaced( e.ModEntry.Unique ) )
	Print( "  " + e.ModEntry.Title + " by " + e.ModEntry.Artist )
	If e.ModEntry.Extra Then Print( "  " + e.ModEntry.Extra )
	If e.MatchTags Then Print( "  Matching " + e.MatchTags )
EndFunction

Function DoDownload:Int( m:TModEntry )
	Print( "Downloading " + QuoteIfSpaced( m.Unique ) )
	Return DownloadModFile( m.Tracker, m.Artist, m.File, m.Extra )
EndFunction

Function DoPlay( m:TModEntry )
	Print( "Playing " + QuoteIfSpaced( m.Unique ) )
	Local filePath:String = SongFolder + "\" + m.Tracker + "\" + m.Artist + "\" + m.File
	Local song:TSound = LoadSound( filePath )
	If Not song Then
		Print( "Error: Unable to locate local file " + filePath )
		Return
	EndIf
	
	Print( "  " + m.Title + " by " + m.Artist )
	
	Local driver:TSoloudAudioDriver = TSoloudAudioDriver(GetAudioDriver())
	Local so:TSoLoud = driver._soloud
	Local channel:TChannel = PlaySound( song )
	
	Input("")
	
	channel.Stop()
EndFunction