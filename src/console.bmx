SuperStrict

Import Audio.AudioMiniAudio
Import Audio.ModLoader

Import "common.bmx"
Import "moddatabase.bmx"

Const MaxMatches:Int = 100

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
				Print( " difference)" )
			EndIf
			
		Case "search"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ) ) Then
				For Local e:TSearchEntry = EachIn Database.LastSearch
					PrintSearchInfo( e )
					If e <> Database.LastSearch.Last() Then Print()
				Next
			EndIf
			
		Case "download"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ) ) Then
				For Local e:TSearchEntry = EachIn Database.LastSearch
					DoDownload( e.ModEntry )
				Next
			EndIf
			
		Case "play"
			PrepareCache()
			If DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ) ) Then
				For Local e:TSearchEntry = EachIn Database.LastSearch
					DoPlay( e.ModEntry )
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

Function DoSearch:Int( text:String, fArtist:String, fFile:String, fTracker:String )
	WriteString( StandardIOStream, "Searching for ~q" + text + "~q... " )
	
	Local matches:TList = Database.Search( text, fArtist, fFile, fTracker )
	
	Print( matches.Count() + " matches" )
	
	' Ask the user if he really wants to continue with this many matches
	If matches.Count() > MaxMatches Then
		Print( "~nThere are over " + MaxMatches + " matches" )
		WriteString( StandardIOStream, "Are you sure you want to continue? (Y/N) " )
		StandardIOStream.Flush()
		If StandardIOStream.ReadString( 1 ).ToLower() = "y" Then
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
	Print( "  Matching " + e.MatchTags )
EndFunction

Function DoDownload( m:TModEntry )
	WriteString( StandardIOStream, "Downloading " + m.Title + "... " )
	DownloadModFile( m.Tracker, m.Artist, m.File )
EndFunction

Function DoPlay( m:TModEntry )
	Local filePath:String = SongFolder + "\" + m.Tracker + "\" + m.Artist + "\" + m.File
	Local song:TSound = LoadSound( filePath )
	If Not song Then
		Print( "Error: Unable to locate local file " + filePath )
		Return
	EndIf
	
	Local driver:TSoloudAudioDriver = TSoloudAudioDriver(GetAudioDriver())
	Local so:TSoLoud = driver._soloud
	Local channel:TChannel = PlaySound( song )
	
	Input()
EndFunction