xyzrgb = xyzrgb_frame_0001;
first_frame = getImage(xyzrgb);
first_xyz = reshape(xyzrgb(:,1:3), 640, 480, 3);
first_xyz = flipdim(imrotate(first_xyz, -90), 2);

% data = reshape(xyzrgb, 480, 640, 6);
%x = reshape(xyzrgb(:,1), 1, 307200);
%y = reshape(xyzrgb(:,2), 1, 307200);
%z = reshape(xyzrgb(:,3), 1, 307200);
%r = reshape(xyzrgb(:,4), 1, 307200);
%g = reshape(xyzrgb(:,5), 1, 307200);
%b = reshape(xyzrgb(:,6), 1, 307200);


%calculate background plane
% 128,39
% 429,39
% 453,473
% 90,473
% point1 = reshape(data(39,128,1:3), 1, 3);
% point2 = reshape(data(39,429,1:3), 1, 3);
% point3 = reshape(data(473,452,1:3), 1, 3);
% point4 = reshape(data(473,90,1:3), 1, 3);
% normal = cross(point1-point2, point1-point3);



%estimate homography matrix for first frame, use same value in rest of the
%frames
UV = zeros(4, 2); %target
XY = zeros(4, 2); %source
UV=[[41,128]', [40,429]', [473,453]', [476,90]']';
XY=[[1,338]', [1,1]', [450,1]', [450,338]']';

P=esthomog(UV,XY,4);


%iterate over all frames
background = imread('field.jpg', 'jpg');
[IR,IC,D]=size(background);

%mvp keen esthomog values
XY2=[[1,400]', [1,1]', [225,1]', [225,400]']';


%Prepare to write video
vw = VideoWriter('AV_movie.avi');
vw.FrameRate = 6;
vw.open();

for i=15:25
    frame = sprintf('xyzrgb_frame_00%i', i);
    eval(sprintf('current_frame = %s;', frame));
    
    current_xyz = reshape(current_frame(:,1:3), 640, 480, 3);
    current_xyz = flipdim(imrotate(current_xyz, -90), 2);
    image = getImage(current_frame); %Iterate frames here, replace this line

    %loop over frame image to insert background
    for r=1:480
    for c=1:640
        v = P*[r,c,1]';
        y=round(v(1)/v(3));
        x=round(v(2)/v(3));

        current_point = current_xyz(r,c,:);
        background_point = first_xyz(r,c,:);

        distance = (current_point(1)-background_point(1))*(current_point(1)-background_point(1)) + ...
                   (current_point(2)-background_point(2))*(current_point(2)-background_point(2)) + ...
                   (current_point(3)-background_point(3))*(current_point(3)-background_point(3));
        if distance > 0.1
            continue;
        end

        if (x >= 1) & (x <= IC) & (y >= 1) & (y <= IR) & (distance < 0.1)
            image(r,c,:) = double(background(y,x,:)) / 255.0;
        end
    end
    end
    
    %Find rectangular plane
    [plane, fit_error, consensus_set] = getPlane(current_frame);
    
    %Find center of consensus set to get a starting point to grow region
    totalx = 0;
    totaly = 0;
    for p=1:numel(consensus_set)/2

        totalx = totalx + consensus_set(p,1);
        totaly = totaly + consensus_set(p,2);
    end
    averagex = round(totalx / (numel(consensus_set)/2));
    averagey = round(totaly / (numel(consensus_set)/2));
    
    %Grow the region and find the rectangle
    plane = growRegion(current_frame, [averagex, averagey]);
    
    
    %Find corners of the rectangle
    corners = findCorners(plane);
    
    %mvpkeen esthomog
    mvpkeen = imread(sprintf('mvpkeen/mvpkeen_%i.gif', i-1));
    mvpkeen = flipdim(mvpkeen, 2);
    [IR2,IC2,D2]=size(mvpkeen);
    UV2=[corners(1,:)', corners(2,:)', corners(3,:)', corners(4,:)']';

    P2=esthomog(UV2,XY2,4);
    
    %insert mvp keen
    for r=1:480
    for c=1:640
        v = P2*[r,c,1]';
        y=round(v(1)/v(3));
        x=round(v(2)/v(3));

        if (x >= 1) & (x <= IC2) & (y >= 1) & (y <= IR2)
            image(r,c,:) = double(mvpkeen(y,x,:)) / 255.0;
        end
    end
    end

    imshow(image);
    writeVideo(vw,getframe(gcf));
end


close(vw);
