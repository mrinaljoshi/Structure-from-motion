% Run and setup the required libraries if not already installed
run('vlfeat-0.9.20/toolbox/vl_setup.m');

%% Input images and camera intrinsic parameters
path = input('Enter the folder in which images are stored : ','s'); 
image1_index = input('Enter first image number : ');
image2_index = input('Enter second image number : ');

I1_orig = imread(strcat('images','/',path,'/',num2str(image1_index),'.JPG'));
I2_orig = imread(strcat('images','/',path,'/',num2str(image2_index),'.JPG'));
figure
imshowpair(I1_orig, I2_orig, 'montage');
title('Original Images');

I1 = rgb2gray(I1_orig);
I2 = rgb2gray(I2_orig);

% Reading the intrinsic parameters for images
result = dlmread(strcat('images/',path,'/','intrinsic.txt.backup'));
K_int = result(1:3,1:3);

img_width = 720;
img_height = 576;
sphD_x = -0.159621;
sphD_y = 0.462953;

% Camera matrixes P1 and P2. P = K_int * [R T]
% Need to compute R, T first from essential matrix E.
% E= TxR . E from fundamental matrix

%% SIFT matches

[f1,d1] = vl_sift((single((I1))));
[f2,d2] = vl_sift((single((I2))));

[matches,scores] = vl_ubcmatch(d1, d2,0.5);

numMatches = size(matches,2) ;

% x,y of each image in homogeneous coordinates
X1 = f1(1:2,matches(1,:)) ; X1(3,:) = 1 ;
X2 = f2(1:2,matches(2,:)) ; X2(3,:) = 1 ;

%% RANSAC for fundamental matrix

[F, bestInliers] = fundamentalMatrixRANSAC(X1, X2);
fMatrix = F;

%% Essential matrix and R,T camera matrix parameters

E = (K_int')*fMatrix*K_int ;

[U D V] = svd( E ); 
D(2,2) = D(1,1);
D(3,3) = 0 ; 
E = U * D * V';

 % Decompose the matrix E by svd
[u, s, v] = svd(E);

w = [0 -1 0; 1 0 0; 0 0 1];
z = [0 1 0; -1 0 0; 0 0 1];

% E = SR where S = [t]_x and R is the rotation matrix.
% E can be factorized as:
%s = u * z * u';
% Two possibilities:
rot1 = u * w  * v';
rot2 = u * w' * v';

% Two possibilities:
t1 = u(:,3) ./max(abs(u(:,3)));
t2 = -u(:,3) ./max(abs(u(:,3)));

% 4 possible choices of the camera matrix P2 based on the 2 possible
% choices of R and 2 possible signs of t.
rot(:,:,1) = rot1; 
t(:,:,1) = t1;

rot(:,:,2) = rot2; 
t(:,:,2) = t2;

rot(:,:,3) = rot1; 
t(:,:,3) = t2;

rot(:,:,4) = rot2; 
t(:,:,4) = t1;

%% Triangulation to compute 3D point location

% triang function computes the 3D point location using 2D camera views
% P1: camera matrix of the first camera.
% m1: pixel location (x1, y1) on the first view. Row vector.
% P2: camera matrix of the second camera
% m2: pixel location (x2, y2) on the second view. Row vector.
% M: the (x, y, z) coordinate of the reconstructed 3D point. Row vector.

 P1 = eye(3);
 col = zeros(3,1);
 P1 = horzcat(P1,col);
 P1 = K_int*P1;
 
 R2 = rot(:,:,4);
 t2 = t(:,:,4) ;
 P2 = [R2 t2];
 P2 = K_int*P2 ; 

M = cell(1,numMatches);

% Write to a 'data.ply'
fileID = fopen('data.ply','w');

% including header for the ply file
fprintf(fileID,'ply\nformat ascii 1.0\nelement vertex %d\nproperty float x\nproperty float y\nproperty float z\nproperty uchar red\nproperty uchar green\nproperty uchar blue\nend_header\n',numMatches);

for i = 1:numMatches
    m1 = (X1(1:2,i))';
    m2 = (X2(1:2,i))';
    r = I1_orig(round(m1(2)),round(m1(1)),1);
    g = I1_orig(round(m1(2)),round(m1(1)),2);
    b = I1_orig(round(m1(2)),round(m1(1)),3);
    data = triang(m1,m2,P1,P2);
    X3(1,i) = data(1);
    Y3(1,i) = data(2);
    Z3(1,i) = data(3);
    M(1,i) = {data'} ;
    fprintf(fileID,'%0.2f %0.2f %0.2f %d %d %d\n',data(1),data(2),data(3),r,g,b);
end
% 
fclose(fileID);

xyz = [X3' Y3' Z3'];
scatter3(X3,Y3,Z3);