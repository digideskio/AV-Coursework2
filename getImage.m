function [ image ] = getImage( frame )
%GETIMAGE Returns a 2D image given a 3D point cloud

color = reshape(frame(:,4:6), 640, 480, 3) / 255;
image = flipdim(imrotate(color, -90), 2);

end

