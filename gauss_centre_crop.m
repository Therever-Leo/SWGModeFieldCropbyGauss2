clear
inputFolder = 'D:\photo processing\gauss_centre_crop\img123'; 
outputFolder = 'D:\photo processing\gauss_centre_crop\output';
imageFiles = dir(fullfile(inputFolder, '*.tiff'));
numImages = length(imageFiles);
%设定区域大小
[crop_width,crop_height] = deal(200,200);
for i = 1:numImages
    img0 = imread(fullfile(inputFolder, imageFiles(i).name));
    img = beamGageRainbow2Gray(img0);

    % 二维高斯参数：幅值，中心x，中心y，宽度（sigma_x 和 sigma_y），偏移量
    [~,~,gauss2] = gauss2fit(1:size(img,2),1:size(img,1),log(img));
    [center_x,center_y] = deal(gauss2.X0,gauss2.Y0);
    % 计算裁剪区域的左上角坐标
    x_start = max(1, round(center_x - crop_width / 2));
    y_start = max(1, round(center_y - crop_height / 2));
    % 确保裁剪区域不会超出图像边界
    x_end = min(cols, round(center_x + crop_width / 2) - 1);
    y_end = min(rows, round(center_y + crop_height / 2) - 1);
    
    cropped_img = img(y_start:y_end, x_start:x_end);
    
    outputFileName = fullfile(outputFolder, ['cropped_' imageFiles(i).name]);
    imwrite(uint8(cropped_img), outputFileName);
end

function img = beamGageRainbow2Gray(img0)
% beamGageColor2Gray  将彩虹色tiff文件转为灰度图，灰度值对应光强大小
%   img = beamGageRainbow2Gray(img0)
%
% Syntax: (这里添加函数的调用格式, `[]`的内容表示可选参数)
%	[img] = beamGageRainbow2Gray(img0);
%
% Params:
%   - img0    [namevalue]  [numeric; size=:,:,4] 输入图片
%
% Return:
%   - img 绘图图像
%
% Matlab Version: R2024b
%
% Author: Therever-Leo
%

end