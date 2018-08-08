function im2vid(images,fn,framerate)
% creates an mp4 video from a sequence of images
%
% images is a cell array of 2D image frames
% fn is the desired file output name (e.g. 'video.mp4')
% framerate is the video framerate per second (e.g. 30) [optional]


% open video file
output = VideoWriter(fn,'MPEG-4');
output.FrameRate = 30;
if exist('framerate','var')
    output.FrameRate = framerate;
end
open(output)

res = 0;
if size(images{1},1) > 1088 || size(images{1},2) > 1920
    r1 = 1080 / size(images{1},1);
    r2 = 1900 / size(images{1},2);
    res = min([r1,r2]);
end

% write image frames
for i=1:size(images,2)
    if (res > 0) 
        images{i} = imresize(images{i},res);
    end
    writeVideo(output,images{i});
end

% close video file
close(output)


end

