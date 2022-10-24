# Modget

An APT inspired module file _(MOD music, tracker music)_ downloader and manager.

## Description

Download and play all of your favorite tracker music from modland via a simple command-line interface.\
Supports _.IT .S3M .XM_ and _.MOD_ files.

## Getting Started

Download the [latest release](https://github.com/Hezkore/Modget/releases) or compile the project yourself.\
Once you've acquired the executable; open the command-line and enter `modget [options] command`\
See [Usage](#usage) for commands and their options.

## Usage
A simple example: `modget search deadlock`\
You can filter the search results with: `modget search -a elwood deadlock`

* ### update - <small><small><small>update list of available mod files</small></small></small>

* ### search [keyword] - <small><small><small>search for mod file</small></small></small>
	* -a - filter by artist
	* -f - filter by filename
	* -t - filter by tracker software

* ### download [keyword] - <small><small><small>download mod file</small></small></small>
	* -a - filter by artist
	* -f - filter by filename
	* -t - filter by tracker software

* ### play [keyword] - <small><small><small>play mod file (BETA)</small></small></small>
	* -a - filter by artist
	* -f - filter by filename
	* -t - filter by tracker software