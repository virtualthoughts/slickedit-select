# SlickEdit & CodeWright Style Column Select Package

This package borrows most of its functional code from the [Sublime Style Column Selection Package](https://atom.io/packages/sublime-style-column-selection).

In SlickEdit and formally CodeWright column selection is performed utilizing
just right mouse button and selecting the block of text desired.  The benefit of
this is that column select is no longer a two handed operation.


This was originally implemented under Windows, where it works as intended.  It has been discovered that Linux and perhaps Mac has a long standing issue in chromium where the context menu is fired after mouse down rather than after mouse up.  If any one has ideas on how to address this issue under linux/mac I'm all ears.
