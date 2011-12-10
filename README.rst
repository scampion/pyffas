**Python FFmpeg Fast Access Seeker** is a python module dedicated to **accurate video frame access.** Some video file formats was designed for streaming like MPEG for TV, by contrast with AVI witch contain a frame index. An accurate frame per frame navigation in this file is not possible without a first indexing process. PYFFAS build this index and offer a simple API to retrieve video frame.

LICENCE
_______

GPL v3

AUTHOR
______

Sebastien Campion

sebastien.campion@inria.fr

http://www.irisa.fr/prive/Sebastien.Campion/

USAGE
_____

Index your media

::

   import pyffas
   pyffas.indexer("/path/to/the/mediafile","/path/to/create/sqlite/index")

Access to frame

::

    import pyffas
    sk = pyffas.seeker("/path/to/create/sqlite/index")
    sk.getframe(frametime=1000) 
    im = sk.getframe(framenumber=100)
    im.save("/tmp/frame100.jpg")


INSTALL
_______

::

    python setup.py install 


TODO
____

* Audio frame export (Only video frame access work for the moment)

DEPENDENCIES
____________

 
* Python 
* FFMpeg 
* Cython
* SQLite

