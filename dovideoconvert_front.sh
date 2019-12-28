#!/bin/bash

echo This bash file will generate geolocated images from a GS63H dashcam video which can be used to upload to Mapillary, or create your own time-lapse at a 1 sec interval
echo It assumes you turned on GPS on the dashcam when driving, so no need for external recorded gps files
echo Process will remove duplicate images , gps distances within 7 meters, add compass direction, and split sets of images into folders of complete trips
echo Copy dashcam movies in the folder movies in your project folder to start
echo After conversion you can find the time lapse images in the folder upload with a subfolder for each detected trip
echo Although automated uploading to Mapillary is possible, I recommend to manually upload your files per trip, and check and correct geopositions by hand
echo Note that rear cam recordings, filename contains B, are ignored
echo Note that dashcam GPS fix can take upto 3 minutes, so first video recording 3, 5, 10 minutes, look at your dashcam setting, of a trip may be lost

# CHANGE YOUR SETTINGS:
# ----------------------------
# project_folder : "path/to/project" and should contain the subfolders movies, images and upload. You should delete the contents of these folders afterwards 
# video_format : "FHD" or "4K"
# image_view : valid values "car" (will crop a bit to remove dashboard), "bicycle" (no crop assuming unrestricted view)
# brightness_contrast : used by imagemagick to generate images and correct brightness and contrast. 5x0 means +5 more brighter and 0 contrast change

project_folder="/home/michiel/Afbeeldingen/GS63H_to_Mapillary"
video_format="4K"
image_view="car"
brightness_contrast="2x0"







#----------------- start conversion into images
echo "" 
echo "Poject folder" $project_folder 
echo "Your conversion settings are" $video_format $image_view

#----------------- step 1. get gpx trace from video
for i in ${project_folder}/movies/*.MP4; do if [[ $i == *'B.MP4'* ]]; then echo 'ignore B rear cam'; else python2 nvtk_mp42gpx.py -i $i -o $i.gpx -f; fi; done
sleep 1

#----------------- step 2. get geotagged images from video and gpx
for i in ${project_folder}/movies/*.MP4; do if [[ $i == *'B.MP4'* ]]; then echo 'ignore B rear cam' $i; else echo 'geotag' $i; python2 geotag_video.py --make AZDOME --model GS63H --time_offset -1 --use_gps_start_time --image_path ${project_folder}"/images/"$(basename $i) --gps_trace $i.gpx --sample_interval 1.002 $i; fi; done
sleep 1

#----------------- step 3. remove duplicates
for d in ${project_folder}/images/*/; do echo $d; python2 remove_duplicates.py $d; done
sleep 1

#----------------- step 4. add directions
for d in in ${project_folder}/images/*/; do python2 interpolate_direction.py --offset_angle -1 $d; done
sleep 1

#----------------- step 5. crop images, brightness, quality


# Car recording: Video in FHD, store as cropped to 1600 × 900
if [ $image_view="car" ] && [ $video_format="FHD" ]
then
  for d in ${project_folder}/images/*/; do for f in $d*.jpg; do echo $f; convert $f -shave 160x90 -quality 90 $f; done; done
fi

# Car recording: Video in 4k [2880x2160] plays as 16:9 although 4:3 ratio when exported as image-> resample [2880x1620], store as cropped to 2560 × 1440
if [ $image_view="car" ] && [ $video_format="4K" ]
then
  for d in ${project_folder}/images/*/; do for f in $d*.jpg; do echo $f; convert $f -distort barrel "0 0 -0.05" -resize 2880x1620\! -shave 160x90 -brightness-contrast 5x0 -quality 86 $f; done; done
fi

# Bicycle recording / Car when no dashboard crop needed: Video 4k, full, only stretch to 3830x2160
if [ $image_view="bicycle" ] && [ $video_format="4K" ]
then
  for d in ${project_folder}/images/*/; do for f in $d*.jpg; do echo $f; convert $f -resize 3830x2160\! -brightness-contrast $brightness_contrast -quality 86 $f; done; done
fi

sleep 1

#----------------- step 6. rename and move files with unique name
for d in ${project_folder}/images/*/; do echo $d; for f in $d*; do echo $(basename $f); mv -v $f $d/$(basename $d)$(basename $f); done; done
sleep 1
for d in ${project_folder}/images/*/; do echo $d; mv -v  $d* ${project_folder}/upload/; done
sleep 1

#----------------- step 7. combine all moved images to full trips, correct creation datetime, and remove very small trip folders
python2 sequence_split.py ${project_folder}/upload 240 150
sleep 1
for d in ${project_folder}/upload/*/*; do exiftool '-filemodifydate<datetimeoriginal' $d; done
for d in ${project_folder}/upload/*/; do filenum=$(ls -1q $d*.jpg | wc -l); if [ $filenum -lt 10 ]; then echo Hey not enough in $d; rm -r $d; else echo Ok enough files in $d; fi; done
