# SlickEdit & CodeWright Style Column Select Package

This package borrows most of its functional code from the [Sublime Style Column Selection Package](https://atom.io/packages/sublime-style-column-selection).

In SlickEdit and formally CodeWright column selection is performed utilizing
just right mouse button and selecting the block of text desired.  The benefit of
this is that column select is no longer a two handed operation.

As of v1.6.0 you can now hold down control in order to make multiple column
selections.  Courtesy of purdeaandrei.

Note: I have occasionally noticed this package "going crazy".  It looks as if
      Atom gets into a bad state and some of the information required by the
      package isn't returned properly, so the selection ends up at a random
      place on the screen.

      Workaround: Use Atom's View->Reload menu option and the package will
                  function again.

This has now been tested to work under both Windows and Linux, but I have no Mac available to test with.
