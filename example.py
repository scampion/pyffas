from  pyffas import *
fi = indexer("/home/scampion/videos/30.avi","/tmp/30.sql")
fs = seeker("/tmp/30.sql")
for i in range(0,250):
	fs.getframe(framenumber=i).save("/tmp/fn_%i.jpg" % i) 

for i in range(0,25):
	fs.getframe(frametime=i*1000).save("/tmp/ft_%i.jpg" % i) 




