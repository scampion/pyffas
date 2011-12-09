ctypedef signed char int8_t
ctypedef unsigned char uint8_t
ctypedef signed short int16_t
ctypedef unsigned short uint16_t
ctypedef signed long int32_t
ctypedef signed long long int64_t

cdef extern from "libavutil/mathematics.h":
	int64_t av_rescale(int64_t a, int64_t b, int64_t c)

cdef extern from "libavutil/avutil.h":
	cdef enum PixelFormat:
		PIX_FMT_NONE= -1,
		PIX_FMT_YUV420P,  #< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
		PIX_FMT_YUYV422,  #< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
		PIX_FMT_RGB24,    #< packed RGB 8:8:8, 24bpp, RGBRGB...
		PIX_FMT_BGR24,    #< packed RGB 8:8:8, 24bpp, BGRBGR...
		PIX_FMT_YUV422P,  #< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
		PIX_FMT_YUV444P,  #< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
		PIX_FMT_YUV410P,  #< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
		PIX_FMT_YUV411P,  #< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
		PIX_FMT_GRAY8,    #<        Y        ,  8bpp
		PIX_FMT_MONOWHITE,#<        Y        ,  1bpp, 0 is white, 1 is black
		PIX_FMT_MONOBLACK,#<        Y        ,  1bpp, 0 is black, 1 is white
		PIX_FMT_PAL8,     #< 8 bit with PIX_FMT_RGB32 palette
		PIX_FMT_YUVJ420P, #< planar YUV 4:2:0, 12bpp, full scale (JPEG)
		PIX_FMT_YUVJ422P, #< planar YUV 4:2:2, 16bpp, full scale (JPEG)
		PIX_FMT_YUVJ444P, #< planar YUV 4:4:4, 24bpp, full scale (JPEG)
		PIX_FMT_XVMC_MPEG2_MC, #< XVideo Motion Acceleration via common packet passing
		PIX_FMT_XVMC_MPEG2_IDCT,
		PIX_FMT_UYVY422,  #< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
		PIX_FMT_UYYVYY411,#< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
		PIX_FMT_BGR8,     #< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
		PIX_FMT_BGR4,     #< packed RGB 1:2:1,  4bpp, (msb)1B 2G 1R(lsb)
		PIX_FMT_BGR4_BYTE,#< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
		PIX_FMT_RGB8,     #< packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
		PIX_FMT_RGB4,     #< packed RGB 1:2:1,  4bpp, (msb)1R 2G 1B(lsb)
		PIX_FMT_RGB4_BYTE,#< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
		PIX_FMT_NV12,     #< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 for UV
		PIX_FMT_NV21,     #< as above, but U and V bytes are swapped

		PIX_FMT_ARGB,     #< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
		PIX_FMT_RGBA,     #< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
		PIX_FMT_ABGR,     #< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
		PIX_FMT_BGRA,     #< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
	
	void av_free(void *ptr)

cdef extern from "libavcodec/avcodec.h":

	enum:
		AVSEEK_FLAG_BACKWARD = 1 #< seek backward
		AVSEEK_FLAG_BYTE     = 2 #< seeking based on position in bytes
		AVSEEK_FLAG_ANY      = 4 #< seek to any frame, even non keyframes
		CODEC_CAP_TRUNCATED = 0x0008
		CODEC_FLAG_TRUNCATED = 0x00010000 # input bitstream might be truncated at a random location instead of only at frame boundaries
		AV_TIME_BASE = 1000000
		FF_I_TYPE = 1 # Intra
		FF_P_TYPE = 2 # Predicted
		FF_B_TYPE = 3 # Bi-dir predicted
		FF_S_TYPE = 4 # S(GMC)-VOP MPEG4
		FF_SI_TYPE = 5
		FF_SP_TYPE = 6

		AV_NOPTS_VALUE = <int64_t>0x8000000000000000

		AV_PARSER_PTS_NB = 4
		PARSER_FLAG_COMPLETE_FRAMES = 0x0001


	enum CodecType:
		CODEC_TYPE_UNKNOWN = -1
		CODEC_TYPE_VIDEO = 0
		CODEC_TYPE_AUDIO = 1
		CODEC_TYPE_DATA = 2
		CODEC_TYPE_SUBTITLE = 3

	struct AVPacket:
		int64_t pts                            #< presentation time stamp in time_base units
		int64_t dts                            #< decompression time stamp in time_base units
		char *data
		int   size
		int   stream_index
		int   flags
		int   duration                      #< presentation duration in time_base units (0 if not available)
		void  *priv
		int64_t pos                            #< byte position in Track, -1 if unknown

	struct AVCodec:
		char *name
		int type
		int id
		int priv_data_size
		int capabilities
		AVCodec *next
		#AVRational *supported_framerates #array of supported framerates, or NULL if any, array is terminated by {0,0}
		int *pix_fmts       #array of supported pixel formats, or NULL if unknown, array is terminanted by -1

	struct AVCodecContext:
		int     bit_rate
		int     bit_rate_tolerance
		int     flags
		int     sub_id
		int     me_method
		#AVRational     time_base
		int     width
		int     height
		int     gop_size
		int     pix_fmt
		int     rate_emu
		int     sample_rate
		int     channels
		int     sample_fmt
		int     frame_size
		int     frame_number
		int     real_pict_num
		int     delay
		float     qcompress
		float     qblur
		int     qmin
		int     qmax
		int     max_qdiff
		int     max_b_frames
		float     b_quant_factor
		int     rc_strategy
		int     b_frame_strategy
		int     hurry_up
		int     rtp_mode
		int     rtp_payload_size
		int     mv_bits
		int     header_bits
		int     i_tex_bits
		int     p_tex_bits
		int     i_count
		int     p_count
		int     skip_count
		int     misc_bits
		int     frame_bits
		#char     codec_name [32]
		int     codec_type
		int     codec_id
		unsigned int     codec_tag
		int     workaround_bugs
		int     luma_elim_threshold
		int     chroma_elim_threshold
		int     strict_std_compliance
		float     b_quant_offset
		int     error_resilience
		int     has_b_frames
		int     block_align
		int     parse_only
		int     mpeg_quant
		char *     stats_out
		char *     stats_in
		float     rc_qsquish
		float     rc_qmod_amp
		int     rc_qmod_freq
		int     rc_override_count
		char *     rc_eq
		int     rc_max_rate
		int     rc_min_rate
		int     rc_buffer_size
		float     rc_buffer_aggressivity
		float     i_quant_factor
		float     i_quant_offset
		float     rc_initial_cplx
		int     dct_algo
		float     lumi_masking
		float     temporal_cplx_masking
		float     spatial_cplx_masking
		float     p_masking
		float     dark_masking
		int     unused
		int     idct_algo
		int     slice_count
		int *     slice_offset
		int     error_concealment
		unsigned     dsp_mask
		int     bits_per_sample
		int     prediction_method
		#AVRational     sample_aspect_ratio
	 	#AVFrame *     coded_frame
		int     debug
		int     debug_mv
		#uint64_t     error [4]
		int     mb_qmin
		int     mb_qmax
		int     me_cmp
		int     me_sub_cmp
		int     mb_cmp
		int     ildct_cmp
		int     dia_size
		int     last_predictor_count
		int     pre_me
		int     me_pre_cmp
		int     pre_dia_size
		int     me_subpel_quality
		int     dtg_active_format
		int     me_range
		int     intra_quant_bias
		int     inter_quant_bias
		int     color_table_id
		int     internal_buffer_count
		void *     internal_buffer
		int     global_quality
		int     coder_type
		int     context_model
		int     slice_flags
		int     xvmc_acceleration
		int     mb_decision
		uint16_t *     intra_matrix
		uint16_t *     inter_matrix
		unsigned int     Track_codec_tag
		int     scenechange_threshold
		int     lmin
		int     lmax
		#AVPaletteControl *     palctrl
		int     noise_reduction
		int     rc_initial_buffer_occupancy
		int     inter_threshold
		int     flags2
		int     error_rate
		int     antialias_algo
		int     quantizer_noise_shaping
		int     thread_count
		int     me_threshold
		int     mb_threshold
		int     intra_dc_precision
		int     nsse_weight
		int     skip_top
		int     skip_bottom
		int     profile
		int     level
		int     lowres
		int     coded_width
		int     coded_height
		int     frame_skip_threshold
		int     frame_skip_factor
		int     frame_skip_exp
		int     frame_skip_cmp
		float     border_masking
		int     mb_lmin
		int     mb_lmax
		int     me_penalty_compensation
		int     bidir_refine
		int     brd_scale
		float     crf
		int     cqp
		int     keyint_min
		int     refs
		int     chromaoffset
		int     bframebias
		int     trellis
		float     complexityblur
		int     deblockalpha
		int     deblockbeta
		int     partitions
		int     directpred
		int     cutoff
		int     scenechange_factor
		int     mv0_threshold
		int     b_sensitivity
		int     compression_level
		int     use_lpc
		int     lpc_coeff_precision
		int     min_prediction_order
		int     max_prediction_order
		int     prediction_order_method
		int     min_partition_order
		int     max_partition_order
		int64_t     timecode_frame_start
		int skip_frame
		int skip_idct
		int skip_loop_filter

	struct AVFrame:
		uint8_t *data[4]
		int linesize[4]
		int64_t pts
		int pict_type
		int key_frame

	struct AVPicture:
		uint8_t *data[4]
		int linesize[4]

	struct AVCodecParser :
		pass

	struct AVCodecParserContext:
		void *priv_data
		AVCodecParser *parser
		int64_t frame_offset #offset of the current frame 
		int64_t cur_offset # current offset (incremented by each av_parser_parse()) 
		int64_t next_frame_offset #offset of the next frame 
		int pict_type # XXX: Put it back in AVCodecContext.
		int repeat_pict # XXX: Put it back in AVCodecContext. 
		int64_t pts     # pts of the current frame 
		int64_t dts     # dts of the current frame 
		int64_t last_pts
		int64_t last_dts
		int fetch_timestamp		
		int cur_frame_start_index
		int64_t cur_frame_offset[AV_PARSER_PTS_NB]
		int64_t cur_frame_pts[AV_PARSER_PTS_NB]
		int64_t cur_frame_dts[AV_PARSER_PTS_NB]
		int flags
		int64_t offset	#< byte offset from starting packet start
		int64_t cur_frame_end[AV_PARSER_PTS_NB]
		int key_frame 
		int64_t convergence_duration
		int dts_sync_point
		int dts_ref_dts_delta
		int pts_dts_delta
		int64_t cur_frame_pos[AV_PARSER_PTS_NB]
		int64_t pos
		int64_t last_pos



	AVFrame *avcodec_alloc_frame()
	int avcodec_open(AVCodecContext *avctx, AVCodec *codec)
	AVCodec *avcodec_find_decoder(int id)
	int avcodec_decode_video2(AVCodecContext *avctx, AVFrame *picture,
                         int *got_picture_ptr,  AVPacket *avpkt)
	void avcodec_flush_buffers(AVCodecContext *avctx)
	int avpicture_fill(AVPicture *picture, uint8_t *ptr,
        	           int pix_fmt, int width, int height)
	int avpicture_get_size(int pix_fmt, int width, int height)

cdef extern from "libavformat/avformat.h":
	void av_register_all()

	struct AVRational:
		int num
		int den

	struct AVStream:
		int index    #/* Track index in AVFormatContext */
		int id       #/* format specific Track id */
		AVCodecContext *codec #/* codec context */
		# real base frame rate of the Track.
		# for example if the timebase is 1/90000 and all frames have either
		# approximately 3600 or 1800 timer ticks then r_frame_rate will be 50/1
		#AVRational r_frame_rate
		void *priv_data
		# internal data used in av_find_stream_info()
		int64_t codec_info_duration
		int codec_info_nb_frames
		# encoding: PTS generation when outputing Track
		#AVFrac pts
		# this is the fundamental unit of time (in seconds) in terms
		# of which frame timestamps are represented. for fixed-fps content,
		# timebase should be 1/framerate and timestamp increments should be
		# identically 1.
		#AVRational time_base
		int pts_wrap_bits # number of bits in pts (used for wrapping control)
		# ffmpeg.c private use
		int Track_copy   # if TRUE, just copy Track
		int discard       # < selects which packets can be discarded at will and dont need to be demuxed
		# FIXME move stuff to a flags field?
		# quality, as it has been removed from AVCodecContext and put in AVVideoFrame
		# MN:dunno if thats the right place, for it
		float quality
		# decoding: position of the first frame of the component, in
		# AV_TIME_BASE fractional seconds.
		int64_t start_time
		# decoding: duration of the Track, in AV_TIME_BASE fractional
		# seconds.
		int64_t duration
		char language[4] # ISO 639 3-letter language code (empty string if undefined)
		# av_read_frame() support
		int need_parsing                  # < 1.full parsing needed, 2.only parse headers dont repack
		AVCodecParserContext *parser
		int64_t cur_dts
		int last_IP_duration
		int64_t last_IP_pts
		# av_seek_frame() support
		#AVIndexEntry *index_entries # only used if the format does not support seeking natively
		int nb_index_entries
		int index_entries_allocated_size
		int64_t nb_frames                 # < number of frames in this Track if known or 0
		uint8_t *cur_ptr
		int cur_len
		AVPacket cur_pkt
		AVRational time_base

	struct AVFormatContext:
		int nb_streams
		AVStream **streams
		int64_t timestamp
		int64_t start_time
		#AVStream *cur_st
		int64_t file_size
		int64_t duration
		# decoding: total Track bitrate in bit/s, 0 if not
		# available. Never set it directly if the file_size and the
		# duration are known as ffmpeg can compute it automatically. */
		int bit_rate
		int64_t data_offset # offset of the first packet
		int index_built

	struct AVInputFormat:
		pass
	struct AVFormatParameters:
		pass	    
	int av_open_input_file(AVFormatContext **ic_ptr,char *filename,AVInputFormat *fmt,int buf_size,AVFormatParameters *ap)
	int av_find_stream_info(AVFormatContext *ic)
	int av_read_frame(AVFormatContext *s, AVPacket *pkt)
	void av_free_packet(AVPacket *pkt)
	int av_seek_frame(AVFormatContext *s, int stream_index, int64_t timestamp, int flags)
	int64_t av_gettime()


cdef extern from "libswscale/swscale.h":
	cdef enum:
		SWS_BICUBIC,
	struct SwsContext:
		pass
	struct SwsFilter:
		pass
	SwsContext *sws_getContext(int srcW, int srcH, int srcFormat, int dstW, int dstH, int dstFormat, int flags,
                                  SwsFilter *srcFilter, SwsFilter *dstFilter, double *param)
	void sws_freeContext(SwsContext *swsContext)
	int sws_scale(SwsContext *context, uint8_t* src[], int srcStride[], int srcSliceY,
				  int srcSliceH, uint8_t* dst[], int dstStride[])



