#!/bin/bash

ls | grep -v $1 | while read DIR
do
   rm -rf $DIR
done
