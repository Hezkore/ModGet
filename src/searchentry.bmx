SuperStrict

Import "modentry.bmx"

Type TSearchEntry
	
	Field ModEntry:TModEntry
	Field MatchTags:String
	
	Method New( match:TModEntry )
		
		Self.ModEntry = match
	EndMethod
	
	Method AddMatchTag( tag:String )
		
		Self.MatchTags:+tag + ", "
	EndMethod
	
	Method CleanMatchTag()
		If Self.MatchTags.EndsWith( " " ) Then ..
			Self.MatchTags = Self.MatchTags[..Self.MatchTags.Length-1]
		If Self.MatchTags.EndsWith( "," ) Then ..
			Self.MatchTags = Self.MatchTags[..Self.MatchTags.Length-1]
	EndMethod
EndType