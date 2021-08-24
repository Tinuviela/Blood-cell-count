clc; clear all; close all
%% Show image
addpath('\blood smear data set\patient_03'); 
%% Load image
he = imread('patient_03_14.jpg'); 
figure
imshow(he)
title('Original image')
prompt = 'How many groups? (2/3)';
nColors = input(prompt);
%% Clustering
lab_he = rgb2lab(he);
ab = lab_he(:,:,2:3);
ab = im2single(ab);

pixel_labels = imsegkmeans(ab,nColors,'NumAttempts',3); 

if(nColors == 3)
mask1 = pixel_labels==1;
c1 = he.* uint8(mask1);

mask2 = pixel_labels==2;
c2 = he .* uint8(mask2);

mask3 = pixel_labels==3;
c3 = he .* uint8(mask3);

figure
subplot(2,2,1);
imshow(c1)
title('Mask 1');
subplot(2,2,2);
imshow(c2)
title('Mask 2');
subplot(2,2,3);
imshow(c3)
title('Mask 3');
else
    mask1 = pixel_labels==1;
c1 = he.* uint8(mask1);

mask2 = pixel_labels==2;
c2 = he .* uint8(mask2);

figure
subplot(2,2,1);
imshow(c1)
title('Mask 1');
subplot(2,2,2);
imshow(c2)
title('Mask 2');
end

SE = strel('disk',1);
if nColors==3
prompt = 'Which mask contains WBC? (mask1/mask2/mask3)';
bwW = input(prompt);
prompt = 'Which mask contains RBC? (mask1/mask2/mask3)';
bwR = input(prompt);

segW = bwmorph(bwW , 'majority'); 
segW = bwmorph(segW , 'fill');
segW = imfill(segW,'holes');

segR = bwmorph(bwR , 'majority'); 
segR = bwmorph(segR , 'fill');
segR = imfill(segR,'holes');



finalRBC = RBC(segR,SE); % watershed
finalRBC = bwmorph(finalRBC , 'fill'); 
finalRBC = imfill(finalRBC,'holes');
%% WBC removal
[labW,numW] = bwlabel(segW,4); 
blobW= regionprops(labW,'Area'); 
allAreasW = [blobW.Area];
%histogram dla WBC
figure
bar(sort(allAreasW))
text(1:length(allAreasW),allAreasW,num2str(allAreasW'),'vert','bottom','horiz','center')
title('Histogram WBC');

prompt = 'What is the threshold?'; 
P1 = input(prompt);
segW = bwareaopen(segW,P1);
[labW,numW] = bwlabel(segW,4);
blobW= regionprops(labW,'Centroid');


temp = finalRBC;
for i=1:numW
    x(i) = blobW(i).Centroid(1);
    y(i) = blobW(i).Centroid(2);
    sel = bwselect(finalRBC,x(i), y(i));
    temp = imsubtract(logical(temp), sel);
end
finalRBC = temp;
segW = sel;

% update
segW = bwareaopen(segW,P1);
[labW,numW] = bwlabel(segW,4);
blobW= regionprops(labW,'Centroid');
blobW= regionprops(labW,'Area');
allAreasW = [blobW.Area];
% figure 
% imshow(segW)
% title('WBC');

% figure 
% imshow(finalRBC)
% title('Maska RBC');
else 
prompt = 'Which mask contains RBC? (mask1/mask2)'; 
bwR = input(prompt);
    
segR = bwmorph(bwR , 'majority');
segR = bwmorph(segR , 'fill');
segR = imfill(segR,'holes');
figure 
imshow(segR)
title('RBC');
finalRBC = RBC( segR,SE);
finalRBC = bwmorph(finalRBC , 'fill');
finalRBC = imfill(finalRBC,'holes');
end

[labR, numR] = bwlabel(finalRBC,4);
blobR= regionprops(labR, 'area', 'Centroid');
allAreasR = [blobR.Area];
allAreasR = sort(allAreasR);
figure
bar(allAreasR)
text(1:length(allAreasR),allAreasR,num2str(allAreasR'),'vert','bottom','horiz','center')
title('Histogram RBC');


prompt = 'What is the threshold?';
P2 = input(prompt);
finalRBC = bwareaopen(finalRBC,P2);

% update
[labR, numR] = bwlabel(finalRBC,4);
blobR= regionprops(labR, 'area', 'Centroid');
allAreasR = [blobR.Area];



bwRGB_R = bsxfun(@times, he, cast(finalRBC, 'like', he)); %There are several ways to do what you want, though bsxfun() is the method I usually use (though it's more cryptic than the .* straightforward method). I first learned that from Sean DeWolski of the Mathworks. However, if bwImage is not the same integer type as colorImage, you will have to modify it.
figure
imshow(bwRGB_R,[])
title('Masked RBC');
if nColors==3
bwRGB_W = bsxfun(@times, he, cast(segW, 'like', he)); %There are several ways to do what you want, though bsxfun() is the method I usually use (though it's more cryptic than the .* straightforward method). I first learned that from Sean DeWolski of the Mathworks. However, if bwImage is not the same integer type as colorImage, you will have to modify it.
figure
imshow(bwRGB_W,[])
title('Masked WBC');
end
%% Stat

% RBC
% avgR = mean(allAreasR);
% sdR = std(allAreasR);
% minR = min(allAreasR);
% maxR = max(allAreasR);
% table(avgR, sdR, minR, maxR)
% WBC

% avgW = mean(allAreasW);
% sdW = std(allAreasW);
% minW = min(allAreasW);
% maxW= max(allAreasW);
% table(avgW, sdW, minW, maxW)