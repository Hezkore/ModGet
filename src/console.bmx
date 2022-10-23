SuperStrict

Import Audio.AudioMiniAudio
Import Audio.ModLoader

Import "common.bmx"
Import "moddatabase.bmx"

GCSetMode( 2 )

' Do we have enough arguments?
If AppArgs.Length < 2 Then Print "Not enough arguments";End

' Process user arguments
Select AppArgsCommand().ToLower()
	Case "update"
		WriteString( StandardIOStream, "Updating database... " )
		UpdateCache()
		Print( "Done" )
	
	Case "search"
		PrepareCache()
		DoSearch( AppArgsConcat(), AppArgsOption( "a" ), AppArgsOption( "f" ), AppArgsOption( "t" ) )
	
	Case "download"
		PrepareCache()
		For Local i:Int = 2 Until AppArgs.Length
			DoDownload( AppArgs[i] )
		Next
	
	Case "play"
		PrepareCache()
		For Local i:Int = 2 Until AppArgs.Length
			DoPlay( AppArgs[i] )
		Next
EndSelect

' End of application
End

' Helper functions
Function PrepareCache()
	If NeedsToUpdateCache() Then
		WriteString( StandardIOStream, "Updating database... " )
		UpdateCache()
		Print( "Done" )
	Else
		WriteString( StandardIOStream, "Caching database... " )
		LoadCache()
		Print( "Done" )
	EndIf
EndFunction

Function DoSearch( text:String, fArtist:String, fFile:String, fTracker:String )
	WriteString( StandardIOStream, "Searching for ~q" + text + "~q... " )
	
	Local matches:TList = Database.Search( text, fArtist, fFile, fTracker )
	
	Print( matches.Count() + " matches" )
	
	' TODO: no magic number & huge print confirmation
	If matches.Count() > 1000 Then
	EndIf
	
	For Local e:TSearchEntry = EachIn matches
		PrintSearchInfo( e )
		If e <> matches.Last() Then Print()
	Next
EndFunction

Function PrintSearchInfo( e:TSearchEntry )
	Print( QuoteIfSpaced( e.ModEntry.Unique ) )
	Print( "  " + e.ModEntry.Title + " by " + e.ModEntry.Artist )
	Print( "  Matching " + e.MatchTags )
EndFunction

Function DoDownload( text:String )
	WriteString( StandardIOStream, "Downloading " + text + "... " )
	
	Local match:TModEntry = Database.GetFromUnique( text )
	
	If match Then
		Print( "found match" )
		DownloadModFile( match.Tracker, match.Artist, match.File )
	Else
		Print( "No match" )
		Print( "Error: Unable to locate file " + text )
	EndIf
EndFunction

Function DoPlay( text:String )
	
	' Find a match locally
	Local match:TModEntry = Database.GetFromUnique( text )
	
	If Not match Then
		Print( "No match" )
		Print( "Error: Unable to locate local file " + text )
		Return
	EndIf
	
	Local filePath:String = SongFolder + "\" + match.Tracker + "\" + match.Artist + "\" + match.File
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