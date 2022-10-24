SuperStrict

Import brl.retro
Import brl.volumes
Import net.libcurl
Import archive.zip

Const OptionPrefix:String = "-"
Global SupportedFormats:String[] = [".669", ".amf", ".ams", ".dbm", ".digi", ".dmf", ".dsm", ".far", ".gdm", ".ice", ".imf", ".it", ".itp", ".j2b", ".m15", ".mdl", ".med", ".mid", ".mo3", ".mod", ".mptm", ".mt2", ".mtm", ".okt", ".plm", ".psm", ".ptm", ".s3m", ".stm", ".ult", ".umx", ".wow", ".xm"]
Const FTP:String = "ftp.modland.com/"
Const ModFTPPath:String = "pub/modules/"
Const AllModsFTPArchive:String = "allmods.zip"
Const AllModsArchiveFile:String = "allmods.txt"
Const AllModsLocalArchive:String = "modget.tmp"
Const AllModsLocalFile:String = "modget.cache"
?Win32
	Global WorkDir:String = GetUserAppDir() + "\modget\"
?Not Win32
	Global WorkDir:String = GetUserAppDir() + "/.modget/"
?
Global AllModsArchive:String = WorkDir + AllModsLocalArchive
Global AllModsFile:String = WorkDir + AllModsLocalFile
Global SongFolder:String = GetCustomDir( DT_USERMUSIC ) + "\modget"
Global LastDownloadSize:Int

CreateDir( WorkDir, True )

Function NeedsToUpdateCache:Int()
	' Do we have our precious cache file?
	If FileSize( AllModsFile ) > 1 Then
		Return 0
	EndIf
	
	' Do we have the archive containing the cache?
	If FileSize( AllModsArchive ) > 1 Then
		ExtractCache()
		Return 0
	EndIf
	
	' We've got nothing, we need new cache data!
	Return True
EndFunction

Function UpdateCache()
	Local curl:TCurlEasy = TCurlEasy.Create()
	
	Local stream:TStream = WriteStream( AllModsArchive )
	
	curl.setWriteStream( stream )
	curl.setOptString( CURLOPT_URL, FTP + AllModsFTPArchive )
	
	Local res:Int = curl.perform()
	
	If res Then
		Print( "Error: " + CurlError( res ) )
		Quit()
	EndIf
	
	curl.cleanup()
	
	If stream then stream.Close()
	
	If FileSize( AllModsArchive ) > 1 Then
		ExtractCache()
	Else
		Print( "Error: Unable to download cache data (file is " + FileSize( AllModsArchive ) + " bytes)" )
		Quit()
	EndIf
EndFunction

Function ExtractCache()
	' Find the correct file and exctract it
	Local entry:TArchiveEntry = New TArchiveEntry
	
	Local ra:TReadArchive = New TReadArchive
	ra.SetFormat( EArchiveFormat.ZIP )
	ra.Open( AllModsArchive )
	
	While ra.ReadNextHeader( entry ) = ARCHIVE_OK
		If entry.Pathname() = AllModsArchiveFile Then
			SaveText(LoadText(ra.DataStream()), AllModsFile)
			Exit
		EndIf
		'Print "File : " + entry.Pathname()
		'Print "Size : " + entry.Size()
		'Print "Type : " + entry.FileType().ToString()
		'Local s:String = LoadText(ra.DataStream())
		'Print "String size   : " + s.Length
		'Print "First n chars : " + s[0..17]
		'Print
	Wend
	
	ra.Free()
	
	DeleteFile( AllModsArchive )
	
	If FileSize( AllModsFile ) > 1 Then
		'Print "Cached data"
	Else
		Print( "Error: Unable to extract cache data" )
		Quit()
	EndIf
EndFunction

' Return the first application argument command
Function AppArgsCommand:String()
	Local i:Int = 1
	While i < AppArgs.Length
		If AppArgs[i].StartsWith( OptionPrefix ) Then
			i:+2
			Continue
		EndIf
		Return AppArgs[i]
	Wend
EndFunction

' Combine all arguments (excluding options and command) into one string
Function AppArgsConcat:String()
	Local data:String
	Local i:Int = 1
	Local foundCmd:Int
	While i < AppArgs.Length
		If AppArgs[i].StartsWith( OptionPrefix ) Then
			i:+2
			Continue
		EndIf
		If foundCmd Then
			data:+AppArgs[i] + " "
		Else foundCmd = True EndIf
		i:+1
	Wend
	Return data[..data.Length-1]
EndFunction

' Get a specific application argument option data
Function AppArgsOption:String( opt:String )
	If Not opt.StartsWith( OptionPrefix ) Then opt = OptionPrefix + opt
	For Local i:int = 1 Until AppArgs.Length -1
		If AppArgs[i] = opt Then Return AppArgs[i+1]
	Next
EndFunction

Function EncodeURL:String( url:String )
	Local result:String
	
	For Local i:Int = 0 Until url.Length
		If url[i] < 48 Or ..
				(url[i] > 57 And url[i] < 65 ) Or ..
					(url[i] > 90 And url[i] < 97 ) Or ..
						url[i] > 122 Then
			result:+ "%" + Right( Hex( url[i] ), 2 )
		Else result:+Chr( url[i] ) EndIf
	Next
	
	Return result
EndFunction

Function DownloadModFile:Int( tracker:String, artist:String, file:String )
	LastDownloadSize = 0
	Local folderPath:String = SongFolder + "\" + tracker + "\" + artist
	CreateDir( FolderPath, True )
	Local filePath:String = SongFolder + "\" + tracker + "\" + artist + "\" + file
	Local ftpPath:String = EncodeURL( ModFTPPath + tracker + "/" + artist + "/" + file )
	
	If Filesize( filePath ) > 1 Then
		Print( "  File already exists, skipping" )
		Return False
	EndIf
	
	Print( "  Remote " + FTP + ftpPath )
	Print( "  Local " + filePath )
	
	Local curl:TCurlEasy = TCurlEasy.Create()
	
	Local stream:TStream = WriteStream( filePath )
	
	curl.setProgressCallback(progressCallback)
	curl.setWriteStream( stream )
	curl.setOptString( CURLOPT_URL, FTP + ftpPath )
	
	WriteString( StandardIOStream, "  0kb " )
	Function progressCallback:Int(data:Object, dltotal:Long, dlnow:Long, ultotal:Long, ulnow:Long)
		If dlnow > 0 Then
			LastDownloadSize = dltotal
			' TODO: un-mess this please!
			If ( Double(dlnow) / Double(dltotal)  ) * 100.0 Mod 10 <= 1 Then WriteString( StandardIOStream, "." )
		EndIf
		Return 0
	EndFunction
	
	Local res:Int = curl.perform()
	
	If res Then
		Print( "Error: " + CurlError( res ) )
		Quit()
	EndIf
	
	curl.cleanup()
	
	If stream then stream.Close()
	
	If FileSize( FilePath ) > 1 Then
		Print( " " + (LastDownloadSize/1024) + "kb" )
	Else
		Print( "Error: Unable to download mod file (file " + FileSize( FilePath ) + " bytes)" )
		DeleteFile( FilePath )
		Quit()
	EndIf
	
	Return True
EndFunction

Function QuoteIfSpaced:String( text:String )
	If text.Contains( " " ) Then ..
		Return "~q" + text + "~q"
	Return text
EndFunction

Function Quit()
	Delay( 100 )
	End
EndFunction