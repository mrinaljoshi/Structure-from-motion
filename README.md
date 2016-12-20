# Structure-from-motion
Mrinal Joshi

Contents:  
1. SfM2.m  
2. fundamentalMatrix.m (function)  
3. fundamentalMatrixRANSAC.m (function)  
4. triang.m  
5. normalizePoints2d.m  
6. sampsonError.m  
7. vlfeat-0.9.20 (library that needs to be in the same folder as the code)  
8. README.txt  
9. images  
  
Contents of images (folder) :  
1. fountain  
i. input images   
ii. final ply file (for above pair of input images)  
iii. intrinsic.txt.backup file (camera intrinsic parameters)  
2. medusa  
i. input images  
ii. final ply file (for above pair of input images)  
iii. intrinsic.txt.backup file (camera intrinsic parameters)  
3. church3  
i. input images  
ii. final ply file (for above pair of input images)  
iii. intrinsic.txt.backup file (camera intrinsic parameters)  
4. handprint  
i. input images  
ii. final ply file (for above pair of input images)  
iii. intrinsic.txt.backup file (camera intrinsic parameters)  
4. wine bottle  
i. input images  
ii. final ply file (for above pair of input images)  
iii. intrinsic.txt.backup file (camera intrinsic parameters)  
  
Instructions to run the code :  
  
1. Run ‘SfM2.m’  
It will prompt you to input the folder in which images are stored (for eg. fountain, medusa etc) and the name of the two images (I have numbered them 1 and 2)  
2. A data.ply file will the created which can be run in MeshLab to view the output  
3. The image directory and all .m files have to be in the same folder   
4. intrinsic.txt.backup file should be in the same directory as the corresponding input images. dlmread function reads the parameters.  
5. vlfeat-0.9.20 folder should be in the same folder as the code  


