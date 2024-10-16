%主函数：批量读取TIFF图像，进行二维高斯拟合或强度最大值法找到中心，并裁剪图像保存至output文件夹
function batch_crop_tiff1(image_folder, crop_size)

    output_folder = fullfile(image_folder, 'output');
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end%建立output文件夹
    tiff_files = dir(fullfile(image_folder, '*.tiff'));

    for i = 1:length(tiff_files)
        image_path = fullfile(image_folder, tiff_files(i).name);
        img = imread(image_path);
        
        %如果图像是 RGBX (四通道), 转换为 RGB
        if size(img, 3) == 4
            img = img(:, :, 1:3);%忽略第4个通道，保留RGB通道
        end
        
        img_double = double(img);%将图像转换为双精度类型
        gray_img = rgb2gray(img);%转换为灰度图 (处理彩图)
        
        [rows, cols] = size(gray_img);% 获取图像
        
      
        [x, y] = meshgrid(1:cols, 1:rows);
        
        %使用二维高斯拟合找到中心点
       try % AI 纯纯 逆天 z都没有 在try个
            [~, ~, gauss2] = gauss2fit(x, y, z, rows, cols);
            X0 = gauss2.X0;
            Y0 = gauss2.Y0;
        catch
            %若高斯拟合失败，改为寻找图像强度最大值
            [~, idx] = max(img_double(:));
            [Y0, X0] = ind2sub(size(img_double), idx);%通过索引得到最大值的坐标
        end%
        
        %确保拟合中心在图像范围内
        [img_rows, img_cols] = size(img(:,:,1));%使用第一通道的尺寸
        X0 = max(1, min(X0, img_cols));% 修正为图像内
        Y0 = max(1, min(Y0, img_rows));% 修正为图像内  从try到这里是GPT给出的解决办法
        
        half_width = crop_size(1) / 2;
        half_height = crop_size(2) / 2;
        
        x_start = max(round(X0 - half_width), 1);
        y_start = max(round(Y0 - half_height), 1);
        x_end = min(round(X0 + half_width), img_cols);
        y_end = min(round(Y0 + half_height), img_rows);%计算裁剪范围，确保不会超出图像边界
        
        %确保裁剪区域合法
        if x_start < x_end && y_start < y_end
            cropped_img = img(y_start:y_end, x_start:x_end, :);  % 保留RGB通道裁剪
            
            %保存裁剪后的图像到 output 文件夹
            cropped_image_path = fullfile(output_folder, ['cropped_' tiff_files(i).name]);
            imwrite(cropped_img, cropped_image_path, 'tiff');
            
            %显示处理进度
            fprintf('Processed and cropped image: %s\n', tiff_files(i).name);
        else
            warning('裁剪范围无效，跳过图像: %s\n', tiff_files(i).name);
        end
    end
end

%二维高斯拟合函数（确保初始值合理）
function [fitresult, gof, gauss2] = gauss2fit(x, y, z, rows, cols)
    xData = x(:);
    yData = y(:);
    zData = z(:);
    
    % 设置合理初始值和上下限
    initial_guess = [max(z(:)), cols / 2, rows / 2, 10, 10];
    
    ft = fittype('A*exp(-((x-X0).^2/(2*sigmaX^2) + (y-Y0).^2/(2*sigmaY^2)))', ...
        'independent', {'x', 'y'}, 'dependent', 'z');
    
    opts = fitoptions('Method', 'NonlinearLeastSquares', ...
        'StartPoint', initial_guess, ...
        'Lower', [0, 1, 1, 0, 0], ...
        'Upper', [Inf, cols, rows, Inf, Inf]);
    
    [fitresult, gof] = fit([xData, yData], zData, ft, opts);
    
    gauss2 = struct('A', fitresult.A, 'X0', fitresult.X0, 'Y0', fitresult.Y0, ...
                    'sigmaX', fitresult.sigmaX, 'sigmaY', fitresult.sigmaY);
end
