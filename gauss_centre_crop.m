clear
inputFolder = 'D:\WORK\gitfile\SWGModeFieldCropbyGauss2\img'; 
outputFolder = 'D:\WORK\gitfile\SWGModeFieldCropbyGauss2\img\output';
imageFiles = dir(fullfile(inputFolder, '*.tiff'));
numImages = length(imageFiles);

% 设定区域大小
[crop_width, crop_height] = deal(400, 400);

% 设置z轴刻度下限
z_threshold = 5.2;

% 标尺设置
scaleValue = 10; % 标尺表示的实际物理长度
scaleLength = 100; % 标尺在图像中的像素长度
scaleWidth = 20; % 标尺的宽度

%%
for i = 1:numImages
    img0 = imread(fullfile(inputFolder, imageFiles(i).name));
    img = beamGageRainbow2Gray(img0);

    % 将z轴下限以下全部替换为NaN
    img_filtered = double(img);
    img_filtered(img_filtered < z_threshold) = NaN;

    % 二维高斯参数：幅值，中心x，中心y，宽度（sigma_x 和 sigma_y），偏移量
    [~, ~, gauss2] = gauss2fit(1:size(img,2), 1:size(img,1), log(img_filtered));
    [center_x, center_y] = deal(gauss2.X0, gauss2.Y0);

    % 计算裁剪区域的左上角坐标
    x_start = max(1, round(center_x - crop_width / 2));
    y_start = max(1, round(center_y - crop_height / 2));

    % 确保裁剪区域不会超出图像边界
    x_end = min(size(img, 2), round(center_x + crop_width / 2) - 1);
    y_end = min(size(img, 1), round(center_y + crop_height / 2) - 1);

    % 裁剪图像
    cropped_img = img(y_start:y_end, x_start:x_end);

    % 添加标尺 定义标尺起点位置
    x_start_scale = size(cropped_img, 2) - scaleLength - 10;
    y_start_scale = size(cropped_img, 1) - 20;
    x_end_scale = x_start_scale + scaleLength;

    % 绘制标尺条
    cropped_img(y_start_scale:y_start_scale + scaleWidth - 1, x_start_scale:x_end_scale) = 255; % 白色标尺条

    % 在图像上添加标尺数值
    position = [x_start_scale, y_start_scale - 15]; % 标尺数值位置
    cropped_img = insertText(cropped_img, position, sprintf('%d μm', scaleValue), ...
                             'FontSize', 5, 'TextColor', 'white', 'BoxColor', 'black');

    % 保存图像
    outputFileName = fullfile(outputFolder, ['cropped_' imageFiles(i).name]);
    imwrite(uint8(cropped_img), outputFileName);
end


%%

function [fitresult,gof,gauss2] = gauss2fit(x,y,z)

% 利用多项式拟合
[xData,yData,zData] = prepareSurfaceData(x,y,z);
ft = fittype('poly22');
opts = fitoptions('Method','LinearLeastSquares');

% opts.Lower = [-Inf 0 0 -Inf 0 -Inf];
% opts.Upper = [Inf Inf Inf 0 0 0];
opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf];
opts.Upper = [Inf Inf Inf Inf Inf Inf];
[fitresult,gof] = fit([xData,yData],zData,ft,opts);
% 将多项式拟合结果转换为二维高斯结果

ft = fittype('A*exp((-(x-X0).^2/sigmaX2-(y-Y0).^2/sigmaY2)/2)', ...
    independent=["x" "y"],dependent='img', ...
    coefficients=["A" "X0" "Y0" "sigmaX2" "sigmaY2"]);
sigmaX2 = -0.5/fitresult.p20;
sigmaY2 = -0.5/fitresult.p02;
X0 = fitresult.p10*sigmaX2;
Y0 = fitresult.p01*sigmaY2;
A = exp(fitresult.p00+X0^2/(2*sigmaX2)+Y0^2/(2*sigmaY2));
gauss2 = sfit(ft,A,X0,Y0,sigmaX2,sigmaY2);
end

%处理图像
function img = beamGageRainbow2Gray(img0)

%读取色阶
OSI_rainbow = get_OSI_rainbow();

%将四通道的tiff图转化为三通道可处理的RGB
img0 = img0(:, :, 1:3);

%使用逆颜色图算法并加入抖动，将RGB图像转换为索引图像，指定的颜色图为OSI_rainbow
img = rgb2ind(img0, OSI_rainbow)*2;

end



function OSI_rainbow = get_OSI_rainbow()
OSI_rainbow =[
    64    64    64
    40     0    60
    50     0    70
    60     0    80
    70     0    85
    80     0    90
    95     0   100
   105     0   110
   115     0   115
   125     0   115
   140     0   115
   155     0   115
   170     0   115
   185     0   115
   200     0   125
   210     0   135
   220     0   150
   220     0   180
   205     0   200
   205     0   230
   190     0   255
   170     0   255
   150     0   255
   130     0   255
   110     0   255
    80     0   255
    40     0   255
     0     0   255
     0     0   245
     0     0   235
     0     0   225
     0     0   215
     0     0   205
     0    35   205
     0    50   205
     0    65   205
     0    80   205
     0    95   205
     0   105   210
     0   115   220
     0   125   225
     0   125   235
     0   135   240
     0   145   250
     0   155   255
     0   170   255
     0   185   255
     0   195   255
     0   210   255
     0   230   255
     0   245   255
     0   255   235
     0   255   220
     0   255   180
     0   255   140
     0   255    80
     0   255     0
     0   240     0
     0   235     0
     0   230     0
     0   225     0
     0   220     0
     0   215     0
     0   210     0
     0   205     0
     0   200     0
     0   195     0
     0   190     0
    30   195     0
    35   200     0
    40   205     0
    50   210     0
    70   215     0
    90   220     0
   118   225     0
   137   230     0
   156   234     0
   174   238     0
   191   241     0
   207   245     0
   221   248     0
   233   250     0
   242   252     0
   249   254     0
   254   255     0
   255   255     0
   255   254     0
   255   252     0
   255   249     0
   255   244     0
   255   238     0
   255   231     0
   255   223     0
   255   215     0
   255   206     0
   255   196     0
   255   187     0
   255   177     0
   255   168     0
   255   160     0
   255   152     0
   255   145     0
   255   139     0
   255   134     0
   255   131     0
   255   129     0
   255   128     0
   255   127     0
   255   125     0
   255   122     0
   255   117     0
   255   111     0
   255   104     0
   255    96     0
   255    87     0
   255    78     0
   255    69     0
   255    59     0
   255    50     0
   255    41     0
   255    32     0
   255    24     0
   255    17     0
   255    11     0
   255     6     0
   255     3     0
   255     1     0
   255     0     0
   255     0     1
   255   255   255
]/255;
end