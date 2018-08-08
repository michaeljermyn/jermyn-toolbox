function loadimages(location, imtype)
% recursively loads all images in a folder and subfolders, and saves as 
% a .mat file in the same folders
% 
% location is the folder location (e.g. 'C:/testfolder')
% imtype is the image extension (e.g. 'tif')


% find and store all images
listing = dir([location '/*.' imtype]);
if size(listing,1) > 0
    data = {};
    for i=1:size(listing,1)
        temp = imread([location '/' listing(i).name]);
        if size(size(temp),2)==3 && size(temp,3) == 4
            data{end+1} = temp(:,:,1:3); %cmyk
        elseif size(size(temp),2)>1
            data{end+1} = temp;
        end
    end
    save([location '/data.mat'],'data','-v7.3');
end

% recursion on subfolders
listing = dir([location '/']);
for i=1:size(listing,1)
    if listing(i).isdir && ~strcmp(listing(i).name(1),'.')
        loadimages([location '/' listing(i).name], imtype);
    end
end


end

