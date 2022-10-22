SuperStrict

Import brl.retro

Import "common.bmx"

Type TModEntry
	
	Field Data:String
	Field DataSplits:String[]
	Field MD5:String
	Field Tracker:String
	Field Artist:String
	Field Title:String
	Field File:String
	Field Filetype:String
	Field Unique:String
	
	Method New( data:String )
		
		Self.MD5 = data.split( "~t" )[0]
		Self.Data = Mid( data, Len( Self.MD5 ) + 2 )
		
		Self.DataSplits = Self.Data.Split( "/" )
		
		Self.Tracker = Self.DataSplits[0]
		Self.Artist = Self.DataSplits[1]
		Self.File = Self.DataSplits[2]
		Self.Filetype = Mid( Self.File, Self.File.FindLast( "." ) + 2 )
		Self.Title = Left( Self.File, Self.File.Length - Self.Filetype.Length -1 )
		
		Self.Unique = QuoteIfSpaced( Self.File + "-" + Self.Artist + "/" + Self.Tracker )
	EndMethod
EndType