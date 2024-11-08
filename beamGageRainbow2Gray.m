function img = beamGageRainbow2Gray(img0)

%读取色阶
OSI_rainbow = get_OSI_rainbow();

%将四通道的tiff图转化为三通道可处理的RGB
img0 = img0(:, :, 1:3);

%使用逆颜色图算法并加入抖动，将RGB图像转换为索引图像，指定的颜色图为OSI_rainbow
img = rgb2ind(img0, OSI_rainbow)*2;

end