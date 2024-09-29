clc
clear all
inputFolder = 'D:\photo processing\gauss_centre_crop\img123'; 
outputFolder = 'D:\photo processing\gauss_centre_crop\output';
imageFiles = dir(fullfile(inputFolder, '*.tiff'));
numImages = length(imageFiles);
%设定区域大小
crop_width = 200;  
crop_height = 200;
for i = 1:numImages
    img = imread(fullfile(inputFolder, imageFiles(i).name));
    img = double(img);
    [rows, cols] = size(img);
    [xData, yData] = meshgrid(1:cols, 1:rows);
    % 二维高斯参数：幅值，中心x，中心y，宽度（sigma_x 和 sigma_y），偏移量
    Gauss_params= [max(img(:)), cols/2, rows/2, 20, 20, min(img(:))]; 
    % 定义二维高斯函数
    gaussfit= @(params, x, y) params(1) * exp( -((x-params(2)).^2 / (2*params(4)^2) + (y-params(3)).^2 / (2*params(5)^2))) + params(6);
    % 使用'lsqcurvefit'最小二乘拟合进行非线性拟合
    options = optimset('Display', 'off');
    fittedParams = lsqcurvefit(@(params, xy) gaussfit(params, xy(:,1), xy(:,2)), ...
        Gauss_params, [xData(:) yData(:)], img(:), [], [], options);
    center_x = fittedParams(2);
    center_y = fittedParams(3);
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