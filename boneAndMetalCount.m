clear all;
close all;

path(path,'C:\Work\GIT\testscripts\');

% settings.archiveImg.path = 'C:\Users\Ari.Arnalds\Desktop\SpruceGrove_feb2019\Archive\Archive_13mar19_metalDetected\';
% settings.calData.path = 'C:\Users\Ari.Arnalds\Desktop\SpruceGrove_feb2019\Archive\calibration_data_13mar19\';

settings.archiveImg.path = 'C:\School\Scripts\13mars_copy\MetalImages_13mars\';
settings.calData.path = 'C:\School\Scripts\13mars_copy\calibration_data_13mar19\';
settings.boneDetection.angle = 91.32;
settings.boneDetection.metalThreshold = 1200;
settings.boneDetection.volumeThreshold = 50;
settings.boneDetection.volume = 1000;

% Fillet - Medium sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 15;
% settings.boneDetection.normalArea = 10;
% settings.boneDetection.fanThreshold = 10;
% settings.boneDetection.fanArea = 35;
% settings.boneDetection.metalThreshold = 3000;

% Fillet - High sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 14;
% settings.boneDetection.normalArea = 8;
% settings.boneDetection.fanThreshold = 10;
% settings.boneDetection.fanArea = 27;
% settings.boneDetection.metalThreshold = 6450;

% Thick - Medium sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 18;
% settings.boneDetection.normalArea = 15;
% settings.boneDetection.fanThreshold = 14;
% settings.boneDetection.fanArea = 45;
% settings.boneDetection.metalThreshold = 3000;

% Thick - High sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 18;
% settings.boneDetection.normalArea = 14;
% settings.boneDetection.fanThreshold = 13;
% settings.boneDetection.fanArea = 45;
% settings.boneDetection.metalThreshold = 4050;

% Thigh Meat - Medium sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 12;
% settings.boneDetection.normalArea = 10;
% settings.boneDetection.fanThreshold = 9;
% settings.boneDetection.fanArea = 35;
% settings.boneDetection.metalThreshold = 3000;

% Thigh Meat - High sensitivity
% settings.boneDetection.angle = 91.43;
% settings.boneDetection.normalThreshold = 12;
% settings.boneDetection.normalArea = 8;
% settings.boneDetection.fanThreshold = 8;
% settings.boneDetection.fanArea = 27;
% settings.boneDetection.metalThreshold = 7000;

boneDetection = zeros(1,6);
metalDetection = zeros(1,6);
se = strel('square',3);
images = getNamesOfTifImages(settings.archiveImg.path);
for i = 1 : length(images)
    settings.archiveImg.name = images{i};
    [numResults, imageResults] = findBonesOneSXImage(settings);
    
%     figure(1);
%     boneMask = imageResults.boneDetection.normalBoneMask + imageResults.boneDetection.fanBoneMask;
%     boneMask(boneMask > 1) = 1;
%     imshow(boneMask ,[]);
%     title(['Bone mask - ', settings.archiveImg.name]);
%     pause;
    
    boneMask = imageResults.boneDetection.normalBoneMask + imageResults.boneDetection.fanBoneMask + imageResults.boneDetection.volumeBoneMask;
    boneMask = imdilate(boneMask, se);
    boneCC=bwconncomp(boneMask, 8);
    numBonesDetected = boneCC.NumObjects;
    boneDetection(1) = boneDetection(1) + (numBonesDetected >= 1);
    boneDetection(2) = boneDetection(2) + (numBonesDetected >= 2);
    boneDetection(3) = boneDetection(3) + (numBonesDetected >= 3);
    boneDetection(4) = boneDetection(4) + (numBonesDetected >= 4);
    boneDetection(5) = boneDetection(5) + (numBonesDetected >= 5);
    boneDetection(6) = boneDetection(6) + (numBonesDetected >= 6);
    
    metalMask = imdilate(imageResults.boneDetection.metalMask, se);
    metalCC=bwconncomp(metalMask, 8);
    numMetalDetected = metalCC.NumObjects;
    metalDetection(1) = metalDetection(1) + (numMetalDetected >= 1);
    metalDetection(2) = metalDetection(2) + (numMetalDetected >= 2);
    metalDetection(3) = metalDetection(3) + (numMetalDetected >= 3);
    metalDetection(4) = metalDetection(4) + (numMetalDetected >= 4);
    metalDetection(5) = metalDetection(5) + (numMetalDetected >= 5);
    metalDetection(6) = metalDetection(6) + (numMetalDetected >= 6);
    %%%%
%     if(numMetalDetected < 4)
%         falseNegativeImage = settings.archiveImg.name
%     end
imageName = settings.archiveImg.name
if(numMetalDetected > 0)
    minHigh = min(min(imageResults.highImg))
end
    %%%%
    
    %%%%
    figure(1);
    subplot(2,1,1);
    imagesc(imageResults.plasticImg); colorbar
    title('Plastic image');

    subplot(2,1,2);
    imagesc(imageResults.alImg); colorbar
    title('Alumimium image');
    pause;
    
%     angleImage = atand(imageResults.alImg./imageResults.plasticImg);
%     figure(1);
%     imagesc(angleImage); colorbar
%     title('Angle image');
%     pause;
    %%%%
end

boneDetection
metalDetection

