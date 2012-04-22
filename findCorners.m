function [ corners ] = findCorners( plane )

%Split image into 4 quadrants
%Find 1 point in each quadrant that maximises the distance between
%points in the other quadrants

%Find range in x and y values
tmost = 1000000;
bmost = 0;
lmost = 1000000;
rmost = 0;
for r=1:480
for c=1:640
    if plane(r,c) == 1
        if r > bmost
            bmost = r;
        end
        if r < tmost
            tmost = r;
        end
        if c > rmost
            rmost = c;
        end
        if c < lmost
            lmost = c;
        end
    end
end
end

%center point of the image
center = [round(tmost + (bmost-tmost)/2), round(lmost + (rmost-lmost)/2)];

%top left, top right, bottom left, bottom right
tl = center;
tr = center;
bl = center;
br = center;

%distances between each quadrant and the other 3 quadrants
tld = 0;
trd = 0;
bld = 0;
brd = 0;

%Number of iterations of finding corners algorithm
n = 3;

for i=1:n
for r=1:480
for c=1:640
    if plane(r,c) == 1
        %top-left quadrant
        if (c < center(2)) && (r < center(1))
            distance = (r-tr(1))^2 + (c-tr(2))^2 + (r-bl(1))^2 + (c-bl(2))^2 + (r-br(1))^2 + (c-br(2))^2;
            if distance > tld
                tl = [r, c];
                tld = distance;
            end
        end

        %top-right quadrant
        if (c > center(2)) && (r < center(1))
            distance = (r-tl(1))^2 + (c-tl(2))^2 + (r-bl(1))^2 + (c-bl(2))^2 + (r-br(1))^2 + (c-br(2))^2;
            if distance > trd
                tr = [r, c];
                trd = distance;
            end
        end

        %bottom-left quadrant
        if (c < center(2)) && (r > center(1))
            distance = (r-tr(1))^2 + (c-tr(2))^2 + (r-tl(1))^2 + (c-tl(2))^2 + (r-br(1))^2 + (c-br(2))^2;
            if distance > bld
                bl = [r, c];
                bld = distance;
            end
        end

        %bottom-right quadrant
        if (c > center(2)) && (r > center(1))
            distance = (r-tr(1))^2 + (c-tr(2))^2 + (r-bl(1))^2 + (c-bl(2))^2 + (r-tl(1))^2 + (c-tl(2))^2;
            if distance > brd
                br = [r, c];
                brd = distance;
            end
        end
    end
end
end
end

corners = [tl', tr', br', bl']';

% %show the corners
% figure,imshow(plane);
% 
% bwimage = zeros(480, 640);
% bwimage(corners(1,1), corners(1,2)) = 1;
% bwimage(corners(2,1), corners(2,2)) = 1;
% bwimage(corners(3,1), corners(3,2)) = 1;
% bwimage(corners(4,1), corners(4,2)) = 1;
% 
% figure,imshow(bwimage);
    
end

