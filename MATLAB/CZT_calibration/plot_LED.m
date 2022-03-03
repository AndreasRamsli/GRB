% function takes a pixel string and maps it on physical LED
% input: pixel_string - array with [16384,n] size
% if n>1 it will sum the array up along second dimension
% first 4096 pixels are from DAU0, then from DAU1 and so on
% ouptut: graphical plot
% usage: plot_LED(zeros([16384,1]));

function plot_LED(pixel_string)

% sum up along each pixel
if size(pixel_string,2) > 1
       pixel_string = sum(pixel_string,2);
end

% reshape and map 16384 pixel string to 128x128 square
pixels = map2D(pixel_string);

% plot 2D
b = imagesc(pixels);
% b = imagesc(imgaussfilt(pixels,3));
        % plot 3D
%         B = imgaussfilt(pixels,3);
%         b = imagesc(B);
% axis off
% square axis
daspect([1,1,1]);
axis([0.5 128.5 0.5 128.5]);box
set(gca,'Xtick',[],'Ytick',[])

if exist('vars.mat','file')
    load('vars.mat','LEDcolormap')
    colormap(LEDcolormap)
end


% label DAUs
text(130,35,'DAU2','FontSize',10)
text(130,95,'DAU1','FontSize',10)
text(-15,35,'DAU4','FontSize',10)
text(-15,95,'DAU3','FontSize',10)
