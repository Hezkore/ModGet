SuperStrict

Import brl.retro

Type TModEntry
	
	Field Data:String
	Field DataSplits:String[]
	Field MD5:String
	Field Tracker:String
	Field Artist:String
	Field Title:String
	Field File:String
	Field Filetype:String
	Field Extra:String
	Field Extras:Int
	Field Unique:String
	
	Method New( data:String )
		
		Self.MD5 = data.split( "~t" )[0]
		Self.Data = Mid( data, Len( Self.MD5 ) + 2 )
		
		Self.DataSplits = Self.Data.Split( "/" )
		
		Self.Tracker = Self.DataSplits[0]
		Self.Artist = Self.DataSplits[1]
		For Self.Extras = 2 Until Self.DataSplits.Length-1
			Self.Extra:+Self.DataSplits[Self.Extras]+"/"
		Next
		Self.File = Self.DataSplits[Self.Extras]
		If Self.Extra Then
			Self.Extra = Left( Self.Extra, Self.Extra.Length -1 )
			Self.Extras:-3
		EndIf
		Self.Filetype = Mid( Self.File, Self.File.FindLast( "." ) + 2 )
		Self.Title = Left( Self.File, Self.File.Length - Self.Filetype.Length -1 )
		
		Self.Unique = Self.File + "-" + Self.Artist + "/" + Self.Tracker
		If Self.Extra Then Self.Unique:+"~~" + Self.Extra
	EndMethod
EndType