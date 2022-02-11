# Add bookmarks/outlines to PDF and DJVU

## Write a file named `toc***` containing outline

First principle: *Don't do it until necessary*.

Therefore basic strategy should be, by order doing the following:

1. Try to find an ebook version with outline embedded firstly.
2. Find a well formarted outline. Either 
	- you use `pdftotext -layout` to dump pages of pdf; and `djvutxt` for DJVU
	- you can copy and select from the book or
	- you find them on online book websites which usually contains outlines in the item introduction part.
3. Use `pdfgrep` for example: 
```sh
pdfgrep --page-range=7-449 -n -P '\n\K(§|Chapter)' ~/Mathematics/Geometry\ and\ Topology/Complex\ Geometry/Complex\ Analytic\ and\ Differential\ Geometry.pdf > tocDemaillyCADG
```
4. Perform OCR manually, painful and not effcient.

For good format outline files, take `tocHatcher` as an example.

**A trick**: you can add a single line `d=xxx` to indicate the page number shift.

## Embed into files

Basic usage:

```
./bookmark-[pdf | djvu] ebook-file toc-file
```
Notes:
- For PDFs, `pdftk` is needed
- There is a [README](README-djvu.org) for bookmark-djvu
