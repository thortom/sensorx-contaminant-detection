clear all;
close all;

path(path,'C:\Work\GIT\testscripts\');

settings.archiveImg.path = 'C:\School\Myndir\Spruce_20190326\1530';
%settings.archiveImg.name = 'MAGNA_4_86.0254CL_2.76924kg.tif';
settings.calData.path = 'C:\School\Myndir\Spruce_20190326\calibration_data';
settings.boneDetection.angle = 0;
%settings.boneDetection.normalThreshold = 16;
%settings.boneDetection.fanThreshold = 12;
%settings.boneDetection.normalArea = 15;
%settings.boneDetection.fanArea = 55;
settings.boneDetection.metalThreshold = 1200;
settings.boneDetection.volumeThreshold = 11;
settings.boneDetection.volume = 13;


images = getNamesOfTifImages(settings.archiveImg.path);
for i = 1 : 1%length(images)
    settings.archiveImg.name = images{i};
    

    [numResults, imageResults] = findBonesOneSXImage(settings);
    
    boneMask = imageResults.boneDetection.normalBoneMask + imageResults.boneDetection.fanBoneMask + imageResults.boneDetection.volumeBoneMask;
    metalMask = imageResults.boneDetection.metalMask;
    mask = uint8(zeros(size(imageResults.plasticImg)));
    mask(imageResults.maskImg ~= 0) = uint8(imageResults.maskImg(imageResults.maskImg ~= 0))*(255/3*1);
    mask(boneMask ~= 0) = uint8(boneMask(boneMask ~= 0))*(255/3*2);
    mask(metalMask ~= 0) = uint8(metalMask(metalMask ~= 0))*(255/3*3);

    %figure;
    %imagesc(imageResults.highImg'); colorbar;
    %minHighImg = min(min(imageResults.highImg))

    figure;
    subplot(2,2,1);
    imshow(imageResults.boneDetection.volumeBoneMask, []);
    title('Bone mask - Volume detection');
    subplot(2,2,2);
    imagesc(imageResults.boneDetection.combImg,[min(min(imageResults.boneDetection.combImg)), max(max(imageResults.boneDetection.combImg))]); colorbar
    title('Combined image');
    subplot(2,2,3);
    imagesc(mask); % colorbar
    title('Plastic image');
    subplot(2,2,4);
    imagesc(imageResults.alImg,[min(min(imageResults.alImg)), max(max(imageResults.alImg))]); colorbar
    title('Aluminium image');
    sgtitle(replace(settings.archiveImg.name, '_', ' '))
%     subplot(2,2,3);
%     imagesc(imageResults.plasticImg,[min(min(imageResults.plasticImg)), max(max(imageResults.plasticImg))]); colorbar
%     title('Plastic image');
%     subplot(2,2,4);
%     imagesc(imageResults.alImg,[min(min(imageResults.alImg)), max(max(imageResults.alImg))]); colorbar
%     title('Aluminium image');
%     sgtitle(replace(settings.archiveImg.name, '_', ' '))

    % imtool(imageResults.boneDetection.combImg,[]);
    %pause;
end
