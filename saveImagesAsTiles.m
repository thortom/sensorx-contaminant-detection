clc; close all; clear all;

path(path,'C:\Work\GIT\testscripts\');

settings.archiveImg.path = 'C:\School\Myndir\Spruce_20190328\0630\';
settings.calData.path = 'C:\School\Myndir\Spruce_20190328\calibration_data\';
settings.boneDetection.angle = 91.32;
settings.boneDetection.metalThreshold = 1200;
settings.boneDetection.volumeThreshold = 50;
settings.boneDetection.volume = 1000;


images = getNamesOfTifImages(settings.archiveImg.path);
for i = 1 : length(images)
    settings.archiveImg.name = images{i};
    

    [lowImg, highImg] = loadOneImage(settings);
    
    [numResults, imageResults] = findBonesOneSXImage(settings);
    
    boneMask = imageResults.boneDetection.normalBoneMask + imageResults.boneDetection.fanBoneMask + imageResults.boneDetection.volumeBoneMask;
    metalMask = imageResults.boneDetection.metalMask;
    
    bonesDetected = countDefects(boneMask);
    metalDetected = countDefects(metalMask);

    settings.archiveImg.name, bonesDetected, metalDetected
    
    plastImg = uint8(imageResults.plasticImg)*(255/20);
    alImg = uint8(imageResults.alImg)*(255/1);
    lowImg = imageResults.lowImgNormReg;%uint8();%*255;    % TODO: Find the correct low and high images
    highImg = imageResults.highImgNorm;%*255;

    mask = uint8(zeros(size(plastImg)));
    mask(imageResults.maskImg ~= 0) = uint8(1);%uint8(imageResults.maskImg(imageResults.maskImg ~= 0))*(255/3*1);
    mask(boneMask ~= 0) = uint8(2);%uint8(boneMask(boneMask ~= 0))*(255/3*2);
    mask(metalMask ~= 0) = uint8(3);%uint8(metalMask(metalMask ~= 0))*(255/3*3);

    productMaskImg = uint8(imageResults.maskImg)*255;
    boneMaskImg = uint8(boneMask)*255;
    metalMaskImg = uint8(metalMask)*255;

    % metalMaskImg(metalMaskImg ~= 0)

    basePath = ['C:\School\Scripts\out\'];
    %imwrite(plastImg, [baseFilename, '_plastic.png'],'png');
    %imwrite(alImg, [baseFilename, '_aluminium.png'],'png');
    %imwrite(lowImg, [baseFilename, '_low.png'],'png');
    %imwrite(highImg, [baseFilename, '_high.png'],'png');
    
    % TODO: If there is both metal and bone detected then I need to verify
    % the image if the metal is really metal
%     lowImg = lowImg * 255/max(lowImg, [], 'all');
%     highImg = highImg * 255/max(highImg, [], 'all');

    % %% Load SX Image, contains both low and high energy images
    % sxImg = double(imread(fullfile(settings.archiveImg.path, settings.archiveImg.name)));
    % [sxImgLength, sxImgWidth] = size(sxImg);
    % imwrite(sxImg, [basePath, settings.archiveImg.name, '.png'],'png');
    %imwrite(lowImg, [baseFilename, '_low.png'],'png');
    [width, height] = size(highImg);
    paddedHighImg = padarray(highImg,[(700-width)/2 (768-height)/2],255,'both');
    imwrite(paddedHighImg, [basePath, 'images\', settings.archiveImg.name],'png');
    %imwrite(imageResults.lowImgNormReg, [baseFilename,'_lowImgNormReg.png'],'png');
    %imwrite(imageResults.highImgNorm, [baseFilename,'_highImgNorm.png'],'png');
    [width, height] = size(mask);
    paddedMask = padarray(mask,[(700-width)/2 (768-height)/2],0,'both');
    imwrite(paddedMask, [basePath, 'masks\', settings.archiveImg.name],'png');

    %imwrite(productMaskImg, [baseFilename, '_productMask.png'],'png');
    %imwrite(boneMaskImg, [baseFilename, '_boneMask.png'],'png');
    %imwrite(metalMaskImg, [baseFilename, '_metalMask.png'],'png');

%     figure(1);
%     title('Image name')
%     subplot(2,2,1);
%     imagesc(imageResults.plasticImg); colorbar
%     title('Plastic image');
% 
%     subplot(2,2,2);
%     imagesc(imageResults.alImg); colorbar
%     title('Alumimium image');
% 
%     subplot(2,2,3);
%     imagesc(boneMaskImg);
%     title('boneMask image');
% 
%     subplot(2,2,4);
%     imagesc(metalMaskImg);
%     title('metalMask image');
    %pause;
end


% Functions...
function [count] = countDefects(mask)
    se = strel('square',3);
    mask = imdilate(mask, se);
    maskCC = bwconncomp(mask, 8);
    count = maskCC.NumObjects;
end

% imageData{i}.maskImg = productMaskImg;
% imageData{i}.imageName = settings.archiveImg.name;
% imageData{i}.plasticImg = imageResults.plasticImg;
% imageData{i}.alImg = imageResults.alImg;
% saveImagesAsPng('C:\School\Scripts\out\', imageData, 768, 490, true, false) %useBoneMask, useMetalMask);
function saveImagesAsTiles(baseFolder, imageData, tileSizeWidth, tileSizeHeight, useBoneMask, useMetalMask)
strideSize = 50;

for i = 1 : length(imageData)
    i
    emptyMask = uint8(zeros(tileSizeWidth, tileSizeHeight));
    emptyBelt = uint8(255*ones(tileSizeWidth, tileSizeHeight));
    for j = 0 : (size(imageData{i}.maskImg,1)/tileSizeHeight)*(tileSizeHeight/strideSize)
        heightSteps = (size(imageData{i}.maskImg,1)/tileSizeHeight)*(tileSizeHeight/strideSize)
        for k = 0 : (size(imageData{i}.maskImg,2)/tileSizeWidth)*(tileSizeWidth/strideSize)
            widthSteps = (size(imageData{i}.maskImg,2)/tileSizeWidth)*(tileSizeWidth/strideSize)
            j
            k
            lineBegin = j*strideSize + 1
            lineEnd = lineBegin + tileSizeHeight - 1
            if(lineEnd > size(imageData{i}.maskImg,1))
                lineEnd = size(imageData{i}.maskImg,1)
            end
            columnBegin = k*strideSize + 1
            columnEnd = columnBegin + tileSizeWidth - 1
            if(columnEnd > size(imageData{i}.maskImg,2))
                columnEnd = size(imageData{i}.maskImg,2)
            end
            baseFilename = [baseFolder,imageData{i}.imageName,'_',num2str(j),'_',num2str(k)];
            
            plastImg = emptyMask;
            plastImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.plasticImg(lineBegin:lineEnd,columnBegin:columnEnd)*(255/20));
            imwrite(plastImg, [baseFilename, '_plastic.png'],'png');

            alImg = emptyMask;
            alImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.alImg(lineBegin:lineEnd,columnBegin:columnEnd)*(255/1));
            imwrite(alImg, [baseFilename, '_aluminium.png'],'png');
            
            productMaskImg = emptyMask;
            productMaskImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.maskImg(lineBegin:lineEnd,columnBegin:columnEnd)*255);
            imwrite(productMaskImg, [baseFilename, '_productMask.png'],'png');
            
            boneMaskImg = emptyMask;
            if(useBoneMask)
                boneMaskImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.boneMask(lineBegin:lineEnd,columnBegin:columnEnd)*255);%uint8(imageData{i}.volumeBoneMask(lineBegin:lineEnd,columnBegin:columnEnd)*255);
                imwrite(boneMaskImg, [baseFilename, '_boneMask.png'],'png');
            end
            
            metalMaskImg = emptyMask;
            if(useMetalMask)
                metalMaskImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.metalMask(lineBegin:lineEnd,columnBegin:columnEnd)*255);
                imwrite(metalMaskImg, [baseFilename, '_metalMask.png'],'png');
            end
            
            maskImg = zeros(tileSizeWidth,tileSizeHeight,3);
            maskImg(:,:,1) = boneMaskImg;
            maskImg(:,:,2) = metalMaskImg;
            maskImg(:,:,3) = productMaskImg;
            imwrite(maskImg, [baseFilename, '_masks.png'],'png');
            
            lowImg = emptyBelt;
            lowImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.lowImgNormReg(lineBegin:lineEnd,columnBegin:columnEnd)*255);
            imwrite(lowImg, [baseFilename, '_low.png'],'png');
            
            highImg = emptyBelt;
            highImg(1:(lineEnd-lineBegin+1),1:(columnEnd-columnBegin+1)) = uint8(imageData{i}.highImgNorm(lineBegin:lineEnd,columnBegin:columnEnd)*255);
            imwrite(highImg, [baseFilename, '_high.png'],'png');
            
% %             imwrite(uint8(imageData{i}.alImg*(255/1)), [baseFolder,imageData{i}.imageName,'_aluminium.png'],'png');
% %             imwrite(imageData{i}.maskImg, [baseFolder,imageData{i}.imageName,'_mask.png'],'png');
% %             %imwrite(uint8(imageData{i}.lowImg*(255/16384)), [baseFolder,imageData{i}.imageName,'_low.png'],'png');
% %             %imwrite(uint8(imageData{i}.highImg*(255/16384)), [baseFolder,imageData{i}.imageName,'_high.png'],'png');
% %             imwrite(imageData{i}.volumeBoneMask, [baseFolder,imageData{i}.imageName,'_boneMask.png'],'png');
% %             imwrite(imageData{i}.metalMask, [baseFolder,imageData{i}.imageName,'_metalMask.png'],'png');
% %             imwrite(imageData{i}.lowImgNormReg, [baseFolder,imageData{i}.imageName,'_lowImgNormReg.png'],'png');
% %             imwrite(imageData{i}.highImgNorm, [baseFolder,imageData{i}.imageName,'_highImgNorm.png'],'png');
        end
    end
end
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
end