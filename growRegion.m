function [ bwimage ] = growRegion( frame, starting_point )

xyz = reshape(frame(:,1:3), 640, 480, 3);
xyz = flipdim(imrotate(xyz, -90), 2);

image = thresholdImage(getImage(frame));
bwimage = zeros(480,640);


%queue of points to visit
queue = [starting_point];
bwimage(starting_point(1), starting_point(2)) = 1;

%keep track of points added to region
visited = [];

threshold = 1;

while size(queue, 1)
    ix = queue(1,1);
    iy = queue(1,2);
    
    cx = xyz(ix, iy, 1);
    cy = xyz(ix, iy, 2);
    cz = xyz(ix, iy, 3);
    visited(end+1,:) = [cx, cy, cz, ix, iy];
    
    queue(1,:) = [];
    
    %Loop through all surrounding pixels
    for i = -1:1
        for j = -1:1
            newx = ix + i;
            newy = iy + j;
            
            if newx < 280
                continue;
            end
            
            if newx>0 && newx<=480 && newy>0 && newy<=640
                %Ignore visited pixels
                if bwimage(newx, newy) == 1
                    continue;
                end
                
                %Ignore pixels not in thresholded image
                if image(newx, newy) == 0
                    continue;
                end

                x = xyz(newx, newy, 1);
                y = xyz(newx, newy, 2);
                z = xyz(newx, newy, 3);
                
                %check difference in depth
                distance = ((cx-x)^2 + (cy-y)^2 + (cz-z)^2) * 10000;
                if distance < threshold
                    bwimage(newx, newy) = 1;
                    queue(end+1,:) = [newx, newy];
                    visited(end+1,:) = [x, y, z, newx, newy];
                end
            end
        end
    end
end
%figure,imshow(bwimage);

%fit plane on region growing points to filter out hand points
threshold = 2;
[plane, fit] = fitplane(visited(:,1:3));
for i=1:numel(visited)/5
    x = visited(i, 1);
    y = visited(i, 2);
    z = visited(i, 3);
    ix = visited(i, 4);
    iy = visited(i, 5);
    
    error = abs(x*plane(1) + y*plane(2) + z*plane(3) + plane(4)) * 100;
    if error > threshold
        bwimage(ix, iy) = 0;
    end
end

bwimage = imopen(bwimage, strel('disk',4));
%figure,imshow(bwimage);

%use a matlab corner detection algorithm to just get the points on the
%edges
%this doesn't really affect the accuracy, but makes next step faster since
%there are less points to check
C = corner(bwimage, 'MinimumEigenValue');

bwimage = zeros(480, 640);
for i=1:numel(C)/2
    bwimage(C(i,2), C(i,1)) = 1;
end

%figure,imshow(bwimage);

end


