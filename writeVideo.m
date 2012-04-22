%Prepare to write video
vw = VideoWriter('AV_movie.avi');
vw.FrameRate = 5;
vw.open();

for i=15:25
    image = imread(sprintf('frames/frame_%i.png', i), 'png');
    writeVideo(vw,image);
end

close(vw);