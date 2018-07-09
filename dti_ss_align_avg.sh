# This script is for DTI preprocessing - run after eddy correction
# It skull strips each scan, generates a transformation between the b0s to align them, applies it, and then averages the two scans together
# Make sure you're running bash!!
# Last updated 20180706 by CLK

#!/bin/bash

# Set path to directory that contains the subjects' folders that contain the nifti files
path=/g5/dcn/JR_Practice/
echo $path
cd $path

ls>filelist

# Grep the subject numbers which we will process
# Note: set "2*" to appropriate wildcard for the contents of the current directory

(egrep "2*" filelist)>subjects_balanced
rm filelist

# For each subject in the list we just made...
cut -c -4 subjects_balanced | while read a
do
fullpath="$path""$a"
echo $fullpath
cd $fullpath

# Skull strip each scan using BET (creates binary masks)
echo Skull stripping each scan

/usr/local/fsl/bin/bet data_1 data_1_ss  -f 0.35 -g 0 -m -F

/usr/local/fsl/bin/bet data_2 data_2_ss  -f 0.35 -g 0 -m -F

echo Skull strip finished!

# Align scan 2 to scan 1
echo Aligning scan 2 to scan 1

# Separate out b0
fslroi data_1_ss data_1_ss_b0 32 1
fslroi data_2_ss data_2_ss_b0 32 1

# Generate linear transformation (a matrix)
#from the b0 of scan 2 to the space of the b0 of scan 1
flirt -in data_2_ss_b0 -ref data_1_ss_b0 -omat data_b0_2_to_1.mat -out 

data_2_ss_b0_aligned
##################

# Apply the transformation matrix to all volumes of scan 2
flirt -in data_2_ss.nii.gz -ref data_1_ss.nii.gz -applyxfm -init 

data_b0_2_to_1.mat -out data_2_ss_aligned.nii.gz

echo Scan 2 is now in the same space as scan 1

# Average the scans together now that they are in the same space
echo Computing mean of the 2 DTI images

fslmaths data_1_ss -add data_2_ss_aligned data_1_2_ss

fslmaths data_1_2_ss -div 2 data_avg_ss

echo Scans for subject ${a} averaged together

echo DTI scans for subject ${a} skull stripped, aligned, and averaged together!

# Go back to the processing directory so we can start again!
cd ../

done
