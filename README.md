# SlickEdit & CodeWright Style Column Select Package

This package borrows most of its functional code from the [Sublime Style Column Selection Package](https://atom.io/packages/sublime-style-column-selection).

In SlickEdit and formally CodeWright column selection is performed utilizing
just right mouse button and selecting the block of text desired.  The benefit of
this is that column select is no longer a two handed operation.

To work around an issue on linux where the contextMenu event is triggered on a mouseDown rather than mouseUp, I needed to suppress the contextMenu event, and then reissue it with a call to:

atom.contextMenu.showForEvent(e)

This has now been tested to work under both Windows and Linux, but I have no Mac available to test with.
