SuperStrict

Import "common.bmx"
Import "modentry.bmx"
Import "searchentry.bmx"

Global Database:TModDatabase

Function LoadCache()
	Database = New TModDatabase( AllModsFile )
EndFunction

Type TModDatabase
	
	Field Mods:TList = CreateList()
	Field LastSearch:TList = CreateList()
	
	Method New( url:String )
		
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
			' Count the / and make sure they're exactly right
			' TODO: do not use magic numbers & support for longer file paths?
			If line.Split( "/" ).Length <> 3 didSkip = True;Continue
			
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
	
	Method GetFromFile:TModEntry( text:String )
		text = text.ToLower()
		For Local e:TModEntry = EachIn Self.Mods
			If e.File.ToLower() = text Then Return e
		Next
	EndMethod
	
	Method GetFromTitle:TModEntry( text:String )
		text = text.ToLower()
		For Local e:TModEntry = EachIn Self.Mods
			If e.Title.ToLower() = text Then Return e
		Next
	EndMethod
	
	Method Search:TList( text:String )
		text = text.ToLower()
		Self.LastSearch.Clear()
		
		Local match:TSearchEntry
		
		For Local e:TModEntry = EachIn Self.Mods
			' Reset match
			match = Null
			
			' Match by title
			If e.Title.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				match.AddMatchTag( "title" )
			EndIf
			
			' Match by artist
			If e.Artist.ToLower().Contains( text ) Then
				If Not match Then match = New TSearchEntry( e )
				match.AddMatchTag( "artist" )
			EndIf
			
			' Add if this is a match
			If match Then
				match.CleanMatchTag()
				Self.LastSearch.AddLast( match )
			EndIf
		Next
		
		Return Self.LastSearch
	EndMethod
EndType