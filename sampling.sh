#!/bin/bash
#do get frame offset
flag=true
read -r -t 30 -p "confirm frame offset (1-10,second): " offset
while $flag; do
  expr "$offset" + 0 &>/dev/null
  [ $? -eq 0 ] && flag=false || read -r -p "please input an integer:" offset
done
echo "frame offset is: $offset"
#get frame offset done

for videoName in *.mp4; do
  #do get video duration
  duration=$(./ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -i "$videoName")
  #get video duration done

  count=0

  #do check dir
  dir="${videoName%.mp4}"
  if [ ! -d "$dir" ]; then
    mkdir "$dir"
    echo "create directory : $dir"
  else
    rm -rf "$dir"
    mkdir "$dir"
    echo "clear and recreate directory : $dir"
  fi
  #check dir done

  #do sample
  for ((i = 1; i < (${duration//.*/+1}); i = i + offset)); do
    ./ffmpeg -ss "$i" -i "$videoName" -vframes 1 "$dir"/"$i".jpeg
    count=$((count + 1))
  done
  #sample done

  echo video duration: "$duration"
  echo total $count image sampled
done
