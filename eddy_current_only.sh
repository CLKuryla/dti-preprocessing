#!/bin/bash
#Get eddy current correction
#Colleen Buckless 03/09/17

path=/g5/dcn/JR_Practice/
cd $path
ls>filelist
(egrep "283*" filelist)>participants
rm filelist

for value in {1..5}
do
        a=$(sed $value'q;d' participants)
fullpath="$path""$a"
echo $fullpath
cd $fullpath

#this identified the image files that need to be run through eddy_correct
        ls>dti_filelist
        (egrep "*.nii.gz" dti_filelist)>dti_list.txt
        rm dti_filelist

        (sed 1'q;d' dti_list.txt)>get_DTI1
        nii1="$(<get_DTI1)"
        echo $nii1
        rm get_DTI1
        nii1=$fullpath"/"$nii1
        (sed 2'q;d' dti_list.txt)>get_DTI2
        nii2="$(<get_DTI2)"
        echo $nii2
        rm get_DTI2
        nii2=$fullpath"/"$nii2
        partnum=${a:0:4}

#this identifies the output name for scan 1
                        output_eddy_1="$fullpath"/"data_1"
                        echo "Output Name"
                        echo $output_eddy_1
#runs eddy on scan 1
                        echo /usr/local/fsl/bin/eddy_correct $nii1 $output_eddy_1 32
                      /usr/local/fsl/bin/eddy_correct $nii1 $output_eddy_1 32

#this identifies the output name for scan 2
                        output_eddy_2="$fullpath"/"data_2"
                        echo "Output Name"
                        echo $output_eddy_2

#runs eddy on scan 2
                        echo /usr/local/fsl/bin/eddy_correct $nii2 $output_eddy_2 32
                        /usr/local/fsl/bin/eddy_correct $nii2 $output_eddy_2 32

done

rm participants
