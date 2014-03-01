itunesimport
============

Command-line utility for downloading folders of MP3 files, from a simple web directory listing (e.g. on a server with a BitTorrent client), and importing them into iTunes.

Because OS X's Samba support is awfully slow and FTP is a joke.

Installation
------------

	> cd path/to/itunesimport
	> bundle install

Example usage
-------------

`itunesimport` takes one argument only, the URL of the directory listing for the MP3 files. It will download any '.mp3' files listed and then open them all in iTunes to import.

	> ./itunesimport.rb "http://router:8081/Christie%20Front%20Drive%20-%20Stereo/"
	Importing "http://router:8081/Christie Front Drive - Stereo/"...
	  1/10 | 11.0MB | 01. Christie Front Drive - Saturday.mp3 |=================================| 100% Time: 00:00:13
	  2/10 | 6.0MB  | 02. Christie Front Drive - Radio.mp3 |====================================| 100% Time: 00:00:08
	  3/10 | 0.0MB  | 03. Christie Front Drive - First Interlude.mp3 |==========================| 100% Time: 00:00:01
	  4/10 | 7.0MB  | 04. Christie Front Drive - November.mp3 |=================================| 100% Time: 00:00:09
	  5/10 | 1.0MB  | 05. Christie Front Drive - Second Interlude.mp3 |=========================| 100% Time: 00:00:02
	  6/10 | 8.0MB  | 06. Christie Front Drive - Fin.mp3 |======================================| 100% Time: 00:00:10
	  7/10 | 11.0MB | 07. Christie Front Drive - About Two Days.mp3 |===========================| 100% Time: 00:00:15
	  8/10 | 2.0MB  | 08. Christie Front Drive - Thrid Interlude.mp3 |==========================| 100% Time: 00:00:04
	  9/10 | 6.0MB  | 09. Christie Front Drive - Seven Day Candle.mp3 |=========================| 100% Time: 00:00:07
	 10/10 | 0.0MB  | 10. Christie Front Drive - Fourth Interlude.mp3 |=========================| 100% Time: 00:00:01
	Opening in iTunes...

License
-------

Public domain.