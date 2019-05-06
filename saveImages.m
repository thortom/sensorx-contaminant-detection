clc; close all; clear all;

path(path,'/home/thor/GIT/testscripts/');

% settings.archiveImg.path = '/home/thor/School/Myndir/Spruce_20190328/0630/';
% settings.calData.path = '/home/thor/School/Myndir/Spruce_20190328/calibration_data/';
settings.boneDetection.angle = 91.32;
settings.boneDetection.metalThreshold = 1200;
settings.boneDetection.volumeThreshold = 50;
settings.boneDetection.volume = 1000;
% images = getNamesOfTifImages(settings.archiveImg.path);

fileID = fopen('/home/thor/School/Myndir/All_In_Folder_With_Calibration/allImages_07042019.txt', 'r');
data = textscan(fileID,'%s');
images = data{1};
fclose(fileID);
for i = 1 : length(images)
    [filepath,name,ext] = fileparts(images{i});
    [filepath,name,ext]
    settings.archiveImg.name = [name, ext];% images{i};
    settings.archiveImg.path = filepath;
    settings.calData.path = [filepath, '/calibration_data/'];

    [lowImg, highImg] = loadOneImage(settings);

    tic
    [numResults, imageResults] = findBonesOneSXImage(settings);
    toc
    
    boneMask = imageResults.boneDetection.normalBoneMask + imageResults.boneDetection.fanBoneMask + imageResults.boneDetection.volumeBoneMask;
    metalMask = imageResults.boneDetection.metalMask;

    plastImg = uint8(imageResults.plasticImg)*(255/20); % Maybe better to have img*255/10
    alImg = uint8(imageResults.alImg)*(255/1);
    lowImgReg = imageResults.lowImgNormReg;
    highImgReg = imageResults.highImgNorm;

    mask = uint8(zeros(size(plastImg)));         % Belt
    mask(imageResults.maskImg ~= 0) = uint8(1);  % Meat
    mask(boneMask ~= 0) = uint8(2);              % Bone
    mask(metalMask ~= 0) = uint8(3);             % Metal

    productMaskImg = uint8(imageResults.maskImg)*255;
    boneMaskImg = uint8(boneMask)*255;
    metalMaskImg = uint8(metalMask)*255;

    bonesDetected = countDefects(boneMask);
    metalDetected = countDefects(metalMask);

    % Get users verification of metal correctness
%     if (((bonesDetected > 0) && (metalDetected > 0)) || (metalDetected > 0))
%         fullFileName = [filepath,'/',name,ext];
%         if (bonesDetected > 0) && (metalDetected > 0)
%             infoString = "Metal and bone in the same image";
%         elseif (metalDetected > 0)
%             infoString = "Metal detected";
%         end
%         fprintf('\n%s\nNumbBones: %s, NumbMetals: %s\n%s\nIndex: %s\n', ...
%                             [fullFileName, bonesDetected, metalDetected, infoString, i])
% 
%         figure('units','normalized','outerposition',[0 0 1 1]);
%         title('Image name')
%         subplot(2,2,1);
%         imagesc(imageResults.plasticImg); colorbar
%         title('Plastic image');
%         subplot(2,2,2);
%         imagesc(imageResults.alImg); colorbar
%         title('Alumimium image');
%         subplot(2,2,3);
%         imagesc(boneMaskImg);
%         title('boneMask image');
%         subplot(2,2,4);
%         imagesc(metalMaskImg);
%         title('metalMask image');
%         sgtitle([replace(settings.archiveImg.name, '_', ' '), ' nr:', int2str(i)])
% 
%         prompt = {"Mark metal as: "}; %,'Enter colormap name:'};
%         dlgtitle = "Input";
%         dims = [1 35];
%         definput = {'meat'};
%         answer = inputdlg(prompt,dlgtitle,dims,definput);
%         if strcmpi(answer{1}, 'meat') % Then remove any metal
%             mask(metalMask ~= 0) = uint8(1);
%         elseif strcmpi(answer{1}, 'bone')
%             mask(metalMask ~= 0) = uint8(2);
%         end
%         close all;
%         %pause;
%     end

    basePath = ['/home/thor/School/Scripts/out/'];
    imageName = [basePath, 'images/', settings.archiveImg.name, 'f'];
    imwrite(paddImgage(highImg, 255), imageName);
    imwrite(paddImgage(lowImg, 255), imageName, 'writemode', 'append');
    imwrite(paddImgage(plastImg, 255), imageName, 'writemode', 'append');
    imwrite(paddImgage(alImg, 255), imageName, 'writemode', 'append');
    imwrite(paddImgage(lowImgReg, 255), imageName, 'writemode', 'append');
    imwrite(paddImgage(highImgReg, 255), imageName, 'writemode', 'append');

    imwrite(paddImgage(mask, 0), [basePath, 'masks/', settings.archiveImg.name, 'f'],'tiff');

    %pause;
end

fprintf('TODO: Save this output to count the false metal images...\n')


% Functions...
function [count] = countDefects(mask)
    se = strel('square',3);
    mask = imdilate(mask, se);
    maskCC = bwconncomp(mask, 8);
    count = maskCC.NumObjects;
end

function [paddedImg] = paddImgage(image, paddValue)
    [width, height] = size(image);
    paddedImg = padarray(image, [(700-width)/2 (768-height)/2], paddValue, 'both');
end

% loadOneImage: Loads one dual energy image
% ======  Examples: ======
% settings.archiveImg.path  = 'Images\'
% settings.archiveImg.name  = 'leanMeatBlock1.tif'
function [lowImg, highImg] = loadOneImage(settings)
    % Load SX Image, contains both low and high energy images
    sxImg = double(imread(fullfile(settings.archiveImg.path, settings.archiveImg.name)));
    [sxImgLength, sxImgWidth] = size(sxImg);

    % Split SX image into low and high energy images
    % sxImgLength is odd sized if normalization coeffs are at the end of the image
    lowImg  = sxImg(1:end-mod(sxImgLength, 2), 1:sxImgWidth/2);
    highImg = sxImg(1:end-mod(sxImgLength, 2), sxImgWidth/2+1:end);

    lowImg = uint8(lowImg*(255/16384));
    highImg = uint8(highImg*(255/16384));
end

% Plot mask on image
% image = imread('C:\School\Scripts\TestData\images\MAGNA_56_-1CL_0.446517kg.tif');
% mask = imread('C:\School\Scripts\TestData\masks\MAGNA_56_-1CL_0.446517kg.tif');
% imagesc(cat(3,mat2gray(image),mat2gray(image),mat2gray(image)+mat2gray(mask)))
