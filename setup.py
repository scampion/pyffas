from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext



ext_modules=[
    Extension("pyffas",
              ["pyffas.pyx"],
              libraries=["swscale", "avcodec", "avformat", "avutil"]) 
]

setup(
    name = "pyffas",
    version = open('VERSION').readline().rstrip(),
    cmdclass = {"build_ext": build_ext},
    ext_modules = ext_modules,
    author='Sebastien Campion',
    author_email='sebastien.campion@inria.fr',
    url="http://fossil/cgi-bin/repo/pyffas",
    description="Python FFmpeg Fast Access Seeker is a python module dedicated to accurate video frame access. Some video file formats was designed for streaming like MPEG for TV, by contrast with AVI witch contain a frame index. An accurate frame per frame navigation in this file is not possible without a first indexing process.",
    keywords='accurate video frame access ffmpeg',
    license='General Public License v3',
    classifiers=['Development Status :: 5 - Production/Stable',
                'Intended Audience :: Developers',
                 'Natural Language :: English',
                 'Operating System :: OS Independent',
                 'Programming Language :: Python :: 2',
                 'Topic :: Multimedia'
                 ],
    )
