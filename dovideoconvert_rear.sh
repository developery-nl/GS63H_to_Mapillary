#!/bin/bash
project_folder="/home/michiel/Afbeeldingen/GS63H_to_Mapillary"

for i in ${project_folder}/movies/*.MP4; do if [[ $i == *'B.MP4'* ]]; then python2 nvtk_mp42gpx.py -i $i -o $i.gpx -f; fi; done
sleep 1 
for i in ${project_folder}/movies/*.MP4; do if [[ $i == *'B.MP4'* ]]; then python2 geotag_video.py --make AZDOME --model GS63H --time_offset -1 --use_gps_start_time --image_path "${project_folder}/images_rear/"$(basename $i) --gps_trace $i.gpx --sample_interval 1.002 $i; fi; done
sleep 1
for d in ${project_folder}/images_rear/*/; do echo $d; python2 remove_duplicates.py $d; done
sleep 1
for d in ${project_folder}/images_rear/*/; do python2 interpolate_direction.py --offset_angle -180 $d; done
sleep 1
for d in ${project_folder}/images_rear/*/; do for f in $d*.jpg; do echo $f; convert $f -flop -shave 10x20 $f; done; done
sleep 1
for d in ${project_folder}/images_rear/*/; do echo $d; for f in $d*; do echo $(basename $f); mv -v $f $d/$(basename $d)$(basename $f); done; done
sleep 1
for d in ${project_folder}/images_rear/*/; do echo $d; mv -v  $d* ${project_folder}/upload_rear/; done
sleep 1
python2 sequence_split.py ${project_folder}/upload_rear 240 150
sleep 1
for d in ${project_folder}/upload_rear/*/; do filenum=$(ls -1q $d*.jpg | wc -l); if [ $filenum -lt 10 ]; then echo Hey not enough in $d; rm -r $d; else echo Ok enough files in $d; fi; done
