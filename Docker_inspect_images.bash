#!/bin/bash

docker ps --format "{{.ID}} {{.Names}} {{.Image}}" | while read -r line; do
  container_id=$(echo "$line" | awk '{print $1}')
  container_name=$(echo "$line" | awk '{print $2}')
  image_name=$(echo "$line" | awk '{print $3}')
  tag=$(echo "$image_name" | awk -F':' '{print $2}')
  if [ "$tag" == "$image_name" ]; then
    tag="latest"
  fi
  echo "$container_id $container_name:$image_name:$tag"
done