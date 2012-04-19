function [ all_points ] = growRegion( frame, starting_point )
%GROWREGION Summary of this function goes here
%   Detailed explanation goes here
xyz = reshape(frame(:,1:3), 640, 480, 3);
xyz = flipdim(imrotate(xyz, -90), 2);

%grow region here


end

