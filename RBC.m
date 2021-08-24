function [I] = RBC(seg_I,SE)

bw =seg_I;
%% WATERSHED
D = -bwdist(~bw); 
Ld = watershed(D);
bw2 = bw; 
bw2(Ld == 0) = 0;
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask); 
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;

bw3 = imclearborder(bw3,8);
bw3 = bwmorph(bw3,'branchpoints');
bw3 = imclose(bw3, SE);
bw4 = imopen(bw3, SE);


I=bw4;


end

