% 从文件夹中选择多张图片
[filename, path] = uigetfile({'*.tif'}, 'Select images', 'MultiSelect', 'on');
if ~iscell(filename)
    filename = {filename};
end
num_files = numel(filename);

% 输入裁剪后图片的横向与纵向像素尺寸大小
width = input('Enter the width of the cropped image: ');
height = input('Enter the height of the cropped image: ');

% 依次展示每一张原图片，并手动选择图片上的一点
for i = 1:num_files
    % 读取图片
    img = imread(fullfile(path, filename{i}));
    
    % 去掉第四层数据
    img = img(:,:,1:3);
    
    % 展示图片
    figure('units','normalized','outerposition',[0 0 1 1])
    imshow(img)
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
    
    % 手动选择图片上的一点
    title('Select the center point of the cropped image')
    [x, y] = ginput(1);
    x = round(x);
    y = round(y);
    
    % 裁剪图片
    x_start = x - floor(width/2);
    x_end = x_start + width - 1;
    y_start = y - floor(height/2);
    y_end = y_start + height - 1;
    cropped_img = img(max(1, y_start):min(size(img, 1), y_end), max(1, x_start):min(size(img, 2), x_end), :);
    
    % 如果裁剪后图片的边界超过了原图片的边界，移动图片中心
    while size(cropped_img, 1) < height || size(cropped_img, 2) < width
        if y_start < 1
            y_end = y_end - y_start + 1;
            y_start = 1;
        elseif y_end > size(img, 1)
            y_start = y_start - (y_end - size(img, 1));
            y_end = size(img, 1);
        end
        
        if x_start < 1
            x_end = x_end - x_start + 1;
            x_start = 1;
        elseif x_end > size(img, 2)
            x_start = x_start - (x_end - size(img, 2));
            x_end = size(img, 2);
        end
        
        cropped_img = img(max(1, y_start):min(size(img, 1), y_end), max(1, x_start):min(size(img, 2), x_end), :);
    end
    
    % 保存裁剪后的图片
    [~, name, ext] = fileparts(filename{i});
    new_filename = ['cut_', name, '.tiff'];
    imwrite(cropped_img, fullfile(path, new_filename), 'Compression', 'none');

    close all
end
