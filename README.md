# GS63H_to_Mapillary
Tool to convert dashcam video GS63H for Mapillary images ready for (manual website) upload

## Purpose

This tool will generate geolocated images from a GS63H dashcam video which can be used to upload to Mapillary, or create your own time-lapse at a 1 sec interval. (The one-second is hardcoded to prevent annoying subsecond format issues).
It assumes you turned on GPS on the dashcam when driving, so no need for external recorded gps files: gps trace is recorded inside MP4 video.

The process will remove duplicate images (gps distances within 7 meters), add compass direction, and split sets of images into folders of complete trips


## Prerequisites

The tool requires Python 2.7 (v3 will not work) and following external tools/library:
* FFmpeg to be installed and accessible at command line
* ExifTool to be installed and accessible at command line
* ImageMagick to be installed and accessible at command line
* Python Imaging Library (PIL) to be installed ( pip install pillow )


## How to use
* Copy of clone this repos to a project folder such as GS63H_to_Mapillary
* Copy your dashcam movies in a newly created folder 'movies' in this project folder
* Create empty folders 'images' and 'upload' in this project folder
* edit the batch file to suit your project, make it executable (chmod u+x dovideoconvert_front.sh) and run (./do_videoconvert_front.sh)

After conversion of video files you can find the time lapse images in the folder upload with a subfolder for each detected trip

Although automated uploading to Mapillary is possible, I recommend to manually upload your files per trip, and check and correct geopositions by hand

Note that rear dual channel cam recordings, e.g. rear cam with filename containing the letter B, are ignored (use separate script for processing)

Note that dashcam GPS fix can take upto 3 minutes, so first video recording (3, 5, 10 minutes, look at your dashcam setting), of a trip may be lost


