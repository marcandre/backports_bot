
# StickyFlag

*file tagging for everyone*

[![Build Status](https://secure.travis-ci.org/cpence/stickyflag.png)](http://travis-ci.org/cpence/stickyflag) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/cpence/stickyflag)

## What does it do?

Filesystems are great.  Most of our file organization tasks can be performed by arranging things in hierarchical directories.  But every once in a while, you have an organization problem that can really only be resolved with categories that *cut across* these hierarchical structures.  What if you want everything related to Project X, including its code, meeting notes about it, photos you took of it, and so on?  The code is in your development directory, meeting notes in a meetings directory, and photos in an images directory.

StickyFlag solves this problem.  It lets you set tags on all your files, and then search across all those files quickly, by storing tags in a database.  But it doesn't just keep the tags in the database -- it saves the tags *directly into the files.*  So your tags stick with your files, even if your StickyFlag database becomes corrupted, or you want to sync your files via Dropbox over to a different machine.

## TL;DR

* Set tags on a wide variety of files
* Save those tags *in the files themselves*
* Also save those tags in a database for searching

## What can it tag?

StickyFlag can currently tag:

* MultiMarkdown files
* PDF files (with `pdftk` installed; see below)
* PNG files
* Matroska video files
* Source code (C/C++, TeX)

## What else does it need?

* If you're going to tag PDF files, you need to install [pdftk,](http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) which is available for all platforms (licensed under the GPL).
* If you're going to tag MKV files, you need to install [mkvtoolnix,](http://www.bunkus.org/videotools/mkvtoolnix/) which is available for all platforms (licensed under the GPL).

## How do I get it?

`gem install stickyflag`

## How do I use it?

* `stickyflag get [FILE] [...]`: Query the tags from a list of files
* `stickyflag set [FILE] [TAG]`: Set the given tag on the given file
* `stickyflag unset [FILE] [TAG]`: Remove the given tag from the given file
* `stickyflag clear [FILE]`: Remove all the tags from the given file
* `stickyflag update`: Refresh the information in the tag database from your files on disk
* `stickyflag tags`: Print a list of all the tags currently in use in all of your files
* `stickyflag find [TAG] [...]`: List all files that are tagged with *all* of the listed tags

`stickyflag update` will run from the current directory, or can run from a user-specified "root" directory, which can be set via calling `stickyflag config`.  `stickyflag config` can also be used to set a couple of other configuration values, like the path to your `pdftk` executable.

## Who did this?

StickyFlag is authored by [Charles Pence](http://charlespence.net) and released under the MIT license.
