SuperStrict

Import "common.bmx"
Import "modentry.bmx"
Import "searchentry.bmx"

Global Database:TModDatabase

Function LoadCache()
	Database = New TModDatabase( AllModsFile )
EndFunction

Function LocalPathToMod:String( e:TModEntry )
	Return LocalPathToMod( e.tracker, e.artist, e.file, e.extra )
EndFunction

Type TModDatabase
	
	Field Mods:TList = CreateList()
	Field LastSearch:TList = CreateList()
	
	Method New( url:String )
		
		If FileSize( AllModsFile ) <= 1 Then Return
		Local stream:TStream = Readstream( url )
		Local line:String
		Local supported:Int
		Local i:Int
		Local didSkip:Int
		
		While Not Eof( stream )
			line = ReadLine( stream )
			
			' Make sure we have enough data!
			If Len( line ) < 4 Then didSkip = True;Continue
			' Make sure the format is supported
			supported = False
			For i = 0 Until SupportedFormats.Length
				If line.ToLower().EndsWith( SupportedFormats[i] ) Then
					supported = True
					Exit
				EndIf
			Next
			If Not supported Then didSkip = True;Continue
			
			Mods.AddLast( New TModEntry( line ) )
		Wend
		
		If didSkip Then Self.CleanAndSave()
	EndMethod
	
	Method Count:Int()
		Return Self.Mods.Count()
	EndMethod
	
	Method CleanAndSave()
		Local stream:TStream = WriteStream( AllModsFile )
		
		For Local e:TModEntry = EachIn Self.Mods
			WriteLine( stream, e.MD5 + "~t" + e.Data )
		Next
		
		CloseStream( stream )
	EndMethod
	
	Method GetFromUnique:TModEntry( text:String )
		text = text.ToLower()
		For Local e:TModEntry = EachIn Self.Mods
			If e.Unique.ToLower() = text Then Return e
		Next
	EndMethod
	
	Method Search:TList( text:String, artistFilter:String, fileFilter:String, trackerFilter:String, extraFilter:String, limit:Int )
		text = text.ToLower()
		
		artistFilter = artistFilter.ToLower()
		fileFilter = fileFilter.ToLower()
		trackerFilter = trackerFilter.ToLower()
		extraFilter = extraFilter.ToLower()
		
		Self.LastSearch.Clear()
		
		Local match:TSearchEntry
		
		For Local e:TModEntry = EachIn Self.Mods
			' Check filters
			If artistFilter And e.Artist.ToLower() <> artistFilter Then Continue
			If fileFilter And e.Title.ToLower() <> fileFilter Then Continue
			If trackerFilter Then
				If trackerFilter.StartsWith( "." ) Then
					If e.Filetype.ToLower() <> trackerFilter[1..] Then Continue
				Else
					If e.Tracker.ToLower() <> trackerFilter Then Continue
				EndIf
			EndIf
			If extraFilter And e.Extra.ToLower() <> extraFilter Then Continue
			
			' Reset match
			match = Null
			
			' Match by unique label
			If e.Unique.ToLower() = text Then
				If Not match Then match = New TSearchEntry( e )
				If text Then match.AddMatchTag( "unique" )
			EndIf
			
			' Match by title
			If e.Title.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				If text Then match.AddMatchTag( "title" )
			EndIf
			
			' Match by artist
			If e.Artist.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				If text Then match.AddMatchTag( "artist" )
			EndIf
			
			' Match by tracker
			If e.Tracker.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				If text Then match.AddMatchTag( "tracker" )
			EndIf
			
			' Match by extra
			If e.Extra.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				If text Then match.AddMatchTag( "extra" )
			EndIf
			
			' Add if this is a match
			If match Then
				match.CleanMatchTag()
				Self.LastSearch.AddLast( match )
				If limit > 0 And Self.LastSearch.Count() >= limit Then Exit
			EndIf
		Next
		
		Return Self.LastSearch
	EndMethod
EndType