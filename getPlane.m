function [ plane, error, consensus_set ] = getPlane( frame )
%GETPLANE Summary of this function goes here
%   Detailed explanation goes here

image = getImage(frame);
%figure,imshow(image);
bwimage = zeros(480,640);

xyz = reshape(frame(:,1:3), 640, 480, 3);
xyz = flipdim(imrotate(xyz, -90), 2);

points = [];

%loop over frame image
for r=1:480
for c=1:640
    red = image(r,c,1);
    green = image(r,c,2);
    blue = image(r,c,3);
    
    %threshold by colour, and ignore all values in top half of image
    if (blue < 0.2) & (green < 0.2) & (red > 0) & (r > 280)
        bwimage(r,c) = 1;
        points = [points; [r,c]];
    else
        bwimage(r,c) = 0;
    end
end
end

%bwimage = imopen(bwimage, strel('disk',5));

%figure,imshow(bwimage);

%RANSAC
n = 3;
k = 100;
t = 0.006;
dmin = 9000;
dmax = 16000;

iterations = 1;
best_error =  100000000;
best_model = 0;
best_consensus_set = 0;

points = reshape(points, numel(points)/2, 2);

while iterations <= k
    %Select n random points
    indices=ceil(rand(1,n)*numel(points)/2);
    consensus_set = reshape(points(indices,:), n, 2);
    
    %Get xyz data for points
    xyz_points = zeros(n, 3);
    for i=1:n
        xyz_points(i,:) = reshape(xyz(consensus_set(i,1),consensus_set(i,2),:), 1, 3);
    end
    
    %fit plane to points
    [maybe_model, fit] = fitplane(xyz_points);
    
    %fit rest of the points to model
    for i=1:numel(points)/2
        if any(indices == i)
            continue;
        end
        
        current_point = reshape(points(i,:), 1, 2);
        current_xyz = reshape(xyz(current_point(1), current_point(2), :), 1, 3);
        error = abs(current_xyz(1)*maybe_model(1) + current_xyz(2)*maybe_model(2) + current_xyz(3)*maybe_model(3) + maybe_model(4));
        if error < t
            %error is low enough, add to consensus set
            consensus_set = [consensus_set; current_point];
        end
    end
    
    if (numel(consensus_set) > dmin) & (numel(consensus_set) < dmax)
        %recompute model based on entire consensus set
        %Get xyz data for points
        xyz_points = zeros(n, 3);
        for i=1:numel(consensus_set)/2
            xyz_points(i,:) = reshape(xyz(consensus_set(i,1),consensus_set(i,2),:), 1, 3);
        end

        %fit plane to points
        [this_model, this_error] = fitplane(xyz_points);
        
        %compare error with best error so far
        if this_error < best_error
            best_model = this_model;
            best_error = this_error;
            best_consensus_set = consensus_set;
        end
    end
    
    iterations = iterations + 1;
end


plane = best_model;
error = best_error;
consensus_set = best_consensus_set;

end