function [ bwimage ] = thresholdImage( image )
bwimage = zeros(480,640);

%loop over frame image
for r=1:480
for c=1:640
    red = image(r,c,1);
    green = image(r,c,2);
    blue = image(r,c,3);
    
    %threshold by colour, and ignore all values in top half of image
    if (blue < 0.3) & (green < 0.3) & (red > 0) & (r > 280)
        bwimage(r,c) = 1;
    else
        bwimage(r,c) = 0;
    end
end
end

%bwimage = imopen(bwimage, strel('disk',5));
%figure,imshow(bwimage);

end

