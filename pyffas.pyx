cdef extern from "Python.h":
  ctypedef int size_t
  object PyBuffer_FromMemory(void *ptr, int size)
  object PyString_FromStringAndSize(char *s, int len)
  void* PyMem_Malloc( size_t n)
  void PyMem_Free( void *p)

from pyffas cimport *
cimport python_exc 
import pickle
import Image
import numpy
import sqlite3 


cdef class indexer:
  def __cinit__(self, videofile, sqlitefile):
    #FFMPEG Variables
    cdef AVFormatContext* avformatcontext
    cdef AVCodecContext* avcodeccontext  
    cdef AVCodec* avcodec  
    cdef AVStream* videoStream
    cdef AVPacket avpacket
    cdef AVFrame* avframe
    cdef int frameFinished 

    #FAS Variables
    videoStreamIdx = -1  
    conn = sqlite3.connect(sqlitefile)
    c = conn.cursor()
    c.execute("create table mediafile (filepath text,videostreamidx int,timeoffset long)")
    c.execute("create table videoframe (dts int, framenumber long, microseconds long, position long)")

    #init
    av_register_all()
    av_open_input_file(&avformatcontext, videofile, NULL, 0, NULL)

    #find video stream 
    av_find_stream_info(avformatcontext)
    for i in range(avformatcontext.nb_streams):
      if avformatcontext.streams[i].codec.codec_type == CODEC_TYPE_VIDEO :
        videoStreamIdx = i 
    if videoStreamIdx == -1 :
      raise NameError("No video track found in file %s!" % videofile)

    #find codec context
    avcodeccontext = avformatcontext.streams[videoStreamIdx].codec

    #find decoder
    avcodec = avcodec_find_decoder(avcodeccontext.codec_id)
    if avcodec== NULL: 
      raise NameError("Unsupported codec for file %s!" % videofile)

    #open codec     
    if avcodec_open(avcodeccontext,avcodec) < 0 : 
      raise NameError("Could not open codec for file %s!" % videofile)

    avframe = avcodec_alloc_frame()
    framenumber = 0
    current_pos = 0     
    time_off = None

    #index
    while av_read_frame(avformatcontext,&avpacket) >= 0 :
      if avpacket.stream_index != videoStreamIdx:
        continue
      avcodec_decode_video2(avcodeccontext,avframe,&frameFinished,&avpacket)
      if frameFinished :
        if not time_off : time_off = av_gettime()
        if avframe.key_frame : 
          c.execute("insert into videoframe values (?,?,?,?)",
                (avpacket.dts,framenumber,av_gettime()-time_off,current_pos))
        current_pos = avpacket.pos
        framenumber += 1  
      av_free_packet(&avpacket)

    #Record media filepath and video stream id 
    c.execute("insert into mediafile values (?,?,?)",(videofile,videoStreamIdx,time_off))

    #Commit and close db
    conn.commit()
    c.close()
      
cdef class seeker:
  cdef int videoStreamIdx
  cdef AVFormatContext*  avformatcontext
  cdef AVCodecContext*   avcodeccontext
  cdef SwsContext *swsconvertctx
  cdef object conn
  cdef object gop 
  cdef long pos 
  cdef long time_off
  cdef char* videofile

  def __cinit__(self,videoindex,size=None):
    #FFMPEG variables
    self.avcodeccontext = NULL
    self.avformatcontext = NULL
    cdef AVCodec* avcodec  
    cdef AVPacket avpacket
    self.gop = []
    self.pos = 0 
    self.time_off = 0

    #Init variables from sql database
    self.conn = sqlite3.connect(videoindex)
    c = self.conn.cursor()
    c.execute("select * from mediafile")
    (vf, self.videoStreamIdx, self.time_off) = c.fetchone()
    self.videofile = vf
    
    av_register_all()
    av_open_input_file(&self.avformatcontext, self.videofile, NULL, 0, NULL)

    #find video stream 
    av_find_stream_info(self.avformatcontext)
    #find codec context
    self.avcodeccontext = self.avformatcontext.streams[self.videoStreamIdx].codec    
    #find decoder
    avcodec = avcodec_find_decoder(self.avcodeccontext.codec_id)
    if avcodec== NULL: 
      raise NameError("Unsupported codec for file %s!" % self.videofile)
    #open codec     
    if avcodec_open(self.avcodeccontext,avcodec) < 0 : 
      raise NameError("Could not open codec for file %s!" % self.videofile)    
    #init decoding buffer with first gop 
    c.execute("select framenumber from videoframe "\
          +"order by framenumber asc "\
          +"limit 1")
    fn = c.fetchone()[0]
    self.getgop(framenumber=fn)


  def getvideofile(self):
    return self.videofile

  def getpointer(self, framenumber=None, frametime=None):
    c = self.conn.cursor()
    if framenumber >=0 :
      c.execute("select framenumber,microseconds,position "\
          +"from videoframe "\
          +"where framenumber <= ? "\
          +"order by framenumber desc "\
          +"limit 1" , (framenumber,))
    if frametime >= 0 :
      c.execute("select framenumber,microseconds,position "\
          +"from videoframe "\
          +"where microseconds <= ? "\
          +"order by microseconds desc "\
          +"limit 1" , (frametime,))
    return c.fetchone()

  def getgop(self,framenumber=None,frametime=None):
    (current_fn,current_ms,pos) = self.getpointer(framenumber,frametime)
    #gop in cache, i.e already decoded return it
    if self.pos == pos : return self.gop

    self.pos = pos 
    self.gop = []
    cdef AVPacket avpacket
    cdef int frameFinished = 0 
    cdef AVFrame* avframe = avcodec_alloc_frame()
    cdef AVFrame *pFrame

    den = self.avformatcontext.streams[self.videoStreamIdx].time_base.den
    num = self.avformatcontext.streams[self.videoStreamIdx].time_base.num
    
    
    if av_seek_frame(self.avformatcontext,self.videoStreamIdx,pos,AVSEEK_FLAG_BYTE) < 0:
      raise NameError("Seek failed !!")

    avcodec_flush_buffers(self.avcodeccontext)

    iframe_decoded = 0 
    while av_read_frame(self.avformatcontext,&avpacket) >= 0 :
      #We decode only video packet
      if avpacket.stream_index != self.videoStreamIdx: continue
      avcodec_decode_video2(self.avcodeccontext,avframe,&frameFinished,&avpacket)
      if frameFinished > 0 :
        if avframe.key_frame   : iframe_decoded+= 1
        if iframe_decoded >= 2 : break 

        pFrame = self.ConvertToRGB24(<AVPicture *>avframe,self.avcodeccontext)
        numBytes  = avpicture_get_size(PIX_FMT_RGB24, self.avcodeccontext.width, self.avcodeccontext.height)
        buf_obj   = PyBuffer_FromMemory(pFrame.data[0],numBytes)
        im = Image.frombuffer("RGB",(self.avcodeccontext.width,self.avcodeccontext.height),buf_obj,"raw","RGB",0,1)
        #print "Decoded frame :  %i dts =  %i : time = %i " % (current_fn,avpacket.dts,av_gettime())
        #im.save("/tmp/t/yyy_%i.jpg" % avpacket.dts)                
        self.gop.append((current_fn,av_gettime()-self.time_off,im))
        PyMem_Free(pFrame.data[0])
        av_free(pFrame)
        current_fn += 1        
      av_free_packet(&avpacket)
      
    #sort gop 
    self.gop.sort()

  def getframe(self,framenumber=None,frametime=None):
    pointer = self.getpointer(framenumber,frametime)
    if not pointer : 
      return None 

    (current_fn,current_ms,pos) = pointer 
    self.getgop(framenumber,frametime)
    for (fn,time,frame) in self.gop :
      if current_fn >= framenumber or current_ms >= time :
        return frame
      else:
        current_fn += 1 

  cdef AVFrame *ConvertToGRAY8(self,AVPicture *frame,AVCodecContext *pCodecCtx):
    cdef AVFrame *pFrameGRAY8
    cdef int numBytes
    cdef uint8_t *rgb_buffer
    cdef int width,height
    cdef AVPicture *pPictureGRAY8
    
    pFrameGRAY8 = avcodec_alloc_frame()
    if pFrameGRAY8 == NULL:
      raise MemoryError("Unable to allocate RGB Frame")
    width = pCodecCtx.width
    height = pCodecCtx.height
    numBytes = avpicture_get_size(PIX_FMT_GRAY8, width,height)
    rgb_buffer = <uint8_t *>PyMem_Malloc(numBytes)
    avpicture_fill(<AVPicture *>pFrameGRAY8, rgb_buffer, PIX_FMT_GRAY8,width, height)
    pPictureGRAY8 = <AVPicture *>pFrameGRAY8
    self.swsconvertctx = sws_getContext(self.avcodeccontext.width,
              self.avcodeccontext.height,
              self.avcodeccontext.pix_fmt,
              self.avcodeccontext.width,
              self.avcodeccontext.height,
              PIX_FMT_GRAY8,
              SWS_BICUBIC, NULL, NULL, NULL)
    sws_scale(self.swsconvertctx,frame.data, frame.linesize, 0, height, pPictureGRAY8.data, pPictureGRAY8.linesize)
    sws_freeContext(self.swsconvertctx)
    return pFrameGRAY8    

  cdef AVFrame *ConvertToRGB24(self,AVPicture *frame,AVCodecContext *pCodecCtx):
    cdef AVFrame *pFrameRGB24
    cdef int numBytes
    cdef uint8_t *rgb_buffer
    cdef int width,height
    cdef AVPicture *pPictureRGB24
    pFrameRGB24 = avcodec_alloc_frame()
    if pFrameRGB24 == NULL:
      raise MemoryError("Unable to allocate RGB Frame")
    width = pCodecCtx.width
    height = pCodecCtx.height
    numBytes = avpicture_get_size(PIX_FMT_RGB24, width,height)
    rgb_buffer = <uint8_t *>PyMem_Malloc(numBytes)
    avpicture_fill(<AVPicture *>pFrameRGB24, rgb_buffer,
		   PIX_FMT_RGB24,width, height)
    
    pPictureRGB24 = <AVPicture *>pFrameRGB24
    self.swsconvertctx = sws_getContext(self.avcodeccontext.width,
              self.avcodeccontext.height,
              self.avcodeccontext.pix_fmt,
              self.avcodeccontext.width,
              self.avcodeccontext.height,
              PIX_FMT_RGB24,
              SWS_BICUBIC, NULL, NULL, NULL)
    sws_scale(self.swsconvertctx, frame.data, frame.linesize,
	      0, height, pPictureRGB24.data, pPictureRGB24.linesize)
    sws_freeContext(self.swsconvertctx)
    return pFrameRGB24    

  

