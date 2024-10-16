%% 
% 输入：BeamGage 灰度值64 z轴刻度1.01x 颜色栏 禁用光标十字线
% 例图见1_0001.tiff、fiber_0001.tiff
clear
%% 读图
mf_WG_original = imread("1_0001.tiff");
mf_fiber_original = imread("fiber_0001.tiff");

mf_WG = beamGageGray64ImgPrepare(mf_WG_original);
mf_fiber = beamGageGray64ImgPrepare(mf_fiber_original);
figure(1),clf
tiledlayout(1,2,"TileSpacing","tight");
nexttile;imshow(mf_WG);title('WG');
nexttile;imshow(mf_fiber);title('Fiber');
colormap('jet');cb = colorbar;cb.Layout.Tile = 'east';cb.Ticks=linspace(cb.Limits(1),cb.Limits(2),6);

%% 统一中心点位置
warning('off','curvefit:prepareFittingData:removingNaNAndInf');
% 找出二维高斯中心并移动到相同大小的图片中
[size_WG(1),size_WG(2)] = size(mf_WG);
[f,g,gauss2_WG] = gauss2fit(1:size_WG(2),1:size_WG(1),log(double(mf_WG)));
midrc = round([size_WG(1),size_WG(2)]/2);
mid_WG = round([gauss2_WG.X0,gauss2_WG.Y0]);
size1 = max([mid_WG;midrc])*2;

[size_fiber(1),size_fiber(2)] = size(mf_fiber);
[~,~,gauss2_fiber] = gauss2fit(1:size_fiber(2),1:size_fiber(1),log(double(mf_fiber)));
midrc = round([size_fiber(1),size_fiber(2)]/2);
mid_fiber = round([gauss2_fiber.X0,gauss2_fiber.Y0]);
size2 = max([mid_fiber;midrc])*2;

size0 = max([size1;size2]);

im_WG = zeros(size0);im_fiber = im_WG;
shift = size0/2-mid_WG;
im_WG(1:size_WG(1),1:size_WG(2))=mf_WG;im_WG = circshift(im_WG,shift(end:-1:1));
shift = size0/2-mid_fiber;
im_fiber(1:size_fiber(1),1:size_fiber(2))=mf_fiber;im_fiber = circshift(im_fiber,shift(end:-1:1));

figure(1),clf
tiledlayout(2,2,"TileSpacing","tight");
nexttile;imagesc(mf_WG);title('WG');set(gca,'XTickLabel',[],'YColor','b','XColor','b')
nexttile;imagesc(mf_fiber);title('Fiber');set(gca,'YAxisLocation','right','XTickLabel',[],'YColor','b','XColor','b')
nexttile;imagesc(im_WG);set(gca,'YColor','r','XColor','r');
nexttile;imagesc(im_fiber);set(gca,'YAxisLocation','right','YColor','r','XColor','r');
colormap('jet');cb = colorbar;cb.Layout.Tile = 'east';cb.Ticks=linspace(cb.Limits(1),cb.Limits(2),6);
%% 验证统一性
[fitr_WG,~,gauss_WG] = gauss2fit(1:size0(2),1:size0(1),log(double(im_WG)));
[fitr_fiber,~,gauss_fiber] = gauss2fit(1:size0(2),1:size0(1),log(double(im_fiber)));
warning('on','curvefit:prepareFittingData:removingNaNAndInf');
fprintf('WG.X0=%f,fiber.X0=%f\nWG.Y0=%f,fiber.Y0=%f\n',gauss_WG.X0,gauss_fiber.X0,gauss_WG.Y0,gauss_fiber.Y0)

% im_WG = im_WG/gauss_WG.A*255;
% im_fiber = im_fiber/gauss_fiber.A*255;
% [fitr_WG,~,gauss_WG] = gauss2fit(1:size0(2),1:size0(1),log(double(im_WG)));
% [fitr_fiber,~,gauss_fiber] = gauss2fit(1:size0(2),1:size0(1),log(double(im_fiber)));
% warning('on','curvefit:prepareFittingData:removingNaNAndInf');
% fprintf('WG.X0=%f,fiber.X0=%f\nWG.Y0=%f,fiber.Y0=%f\nWG.A=%f,fiber.A=%f\n',gauss_WG.X0,gauss_fiber.X0,gauss_WG.Y0,gauss_fiber.Y0,gauss_WG.A,gauss_fiber.A)

[x,y] = meshgrid(1:size0(2),1:size0(1));
fitr_WG_im = exp(feval(fitr_WG,x,y));
fitr_fiber_im = exp(feval(fitr_fiber,x,y));
fit_erro_WG = abs(im_WG-fitr_WG_im)/255;
fit_erro_fiber = abs(im_fiber-fitr_fiber_im)/255;
figure(2),clf
tiledlayout(3,2,"TileSpacing","tight");
nexttile;mesh(im_WG);title('WG');set(gca,'YColor','b','XColor','b','ZColor','b')
nexttile;mesh(im_fiber);title('Fiber');set(gca,'YColor','r','XColor','r','ZColor','r')
colormap('jet');cb = colorbar;cb.Location = 'eastoutside';cb.Ticks=linspace(cb.Limits(1),cb.Limits(2),6);
nexttile;mesh(fitr_WG_im);set(gca,'YColor','b','XColor','b','ZColor','b');
nexttile;mesh(fitr_fiber_im);set(gca,'YColor','r','XColor','r','ZColor','r');
nexttile;imagesc(fit_erro_WG,[0 1]);title('fit error (%)');set(gca,'YColor','b','XColor','b','ZColor','b')
colormap('jet');cb = colorbar;cb.Location = 'southoutside';
cb.Limits(2)=max(max(fit_erro_WG));
cb.Limits(2)=max(max(fit_erro_WG(fit_erro_WG<0.99*cb.Limits(2))));
cb.Ticks=linspace(cb.Limits(1),cb.Limits(2),6);cb.Color='b';
cb.TickLabels=split(num2str(ceil(cb.Ticks*1000)/1000));
nexttile;imagesc(fit_erro_fiber,[0 1]);title('fit error (%)');set(gca,'YAxisLocation','right','YColor','r','XColor','r','ZColor','r')
colormap('jet');cb = colorbar;cb.Location = 'southoutside';
cb.Limits(2)=max(max(fit_erro_fiber));
cb.Limits(2)=max(max(fit_erro_fiber(fit_erro_fiber<0.99*cb.Limits(2))));
cb.Ticks=linspace(cb.Limits(1),cb.Limits(2),6);cb.Color='r';
cb.TickLabels=split(num2str(ceil(cb.Ticks*1000)/1000));

%% 计算重叠积分
Int2 = sum(sum((im_WG.^0.5).*(im_fiber.^0.5)))^2/sum(sum(im_WG))/sum(sum(im_fiber));
fprintf('重叠积分：%.12f\n损耗：%.4f dB\n',Int2,-10*log10(Int2))
% imwrite(im_WG,'im_WG.bmp');
% imwrite(im_fiber,'im_fiber.bmp');
% imwrite(mf_WG,'mf_WG.bmp');
% imwrite(mf_fiber,'mf_fiber.bmp');
% [r,c]=size(img);
% [fitresult,gof,gauss2] = gauss2fit(1:c,1:r,log(double(img)));
% gauss2.X0
% [x,y]=meshgrid(1:c,1:r);
% aa = feval(gauss2,x,y);
% % mf_WG_sigleChannel = mf_WG_original(:,:,2);
% % mf_WG_256 = img256(mf_WG_sigleChannel);
% % 
% % mf_fiber_sigleChannel = mf_fiber_original(:,:,2);
% % mf_fiber_256 = img256(mf_fiber_sigleChannel);
% 
% a = mf_fiber_256;
% % 按列求和
% A=sum(a);
% main_bar = A~=A(1);
% [~,main_bar_inv_y] = find(~main_bar);
% except_y = [main_bar_inv_y,main_bar_inv_y(end)+1:length(A)];
% b = a;
% b(:,except_y)=0;
% [~,main_first_inexcept] = find(diff(except_y)-1);
% main_end = except_y(main_first_inexcept+1);
% 
% 
% imshow(b)
% 
% mask = a==112;
% % imshow(mask)
% L = bwlabel(mask,4);
% L(L>1)=0;
% Ly = sum(~L);
% L(:,Ly>0.9*max(Ly))=0;
% L = ~L;
% % imshow(L)
% % 中心两侧赋值0
% Ly = sum(L);
% mid = length(Ly)/2;
% fLy = abs(Ly.*((1:length(Ly))-mid));
% L(:,fLy>0.5*max(fLy))=0;
% % imshow(L)
% L = double(L);
% aa = uint8(double(a).*L);
% imshow(aa)
% [r,c,~] = find(aa==max(max(aa)));
% mid = round([sum(r)/length(r) sum(c)/length(c)]);
% [r,c,~] = find(aa==112);
% frc = (r-mid(1)).^2+(c-mid(2)).^2;
% r(frc<3*min(frc))=[];c(frc<3*min(frc))=[];
% bb = aa;
% bb(r,c)=0;
% imshow(bb)

%% function
function img = beamGageGray64ImgPrepare(img0)
[~,~,z] = size(img0);
if z > 3
    img0(:,:,4:end)=[];
end
% 除去非灰度背景
background = logical(double(img0(:,:,1))-double(img0(:,:,2)));
mf_fiber_exceptColor = img0(:,:,1);
mf_fiber_exceptColor(background)=0;
% 找到光斑列范围
C = sum(mf_fiber_exceptColor);
Cd1 = find(diff(C));
% 以间隔10列为基准留下[左预留列 光斑 右预留列 colorbar列]
% 对应Ld1([1:Ld2(1) Ld2(1)+1:Ld2(2) Ld2(3):Ld2(3)+1 Ld2(3)+1:end])
[~,Cd2] = find(diff(Cd1)>10);
col_range = [Cd1(Cd2(1)+1),Cd1(Cd2(2))];

img = mf_fiber_exceptColor(:,col_range(1):col_range(2));
% 找到光斑行范围
R = sum(img,2);
Rd1 = find(diff(R));
img = img(Rd1(1):Rd1(end),:);
% % 依据最大值归一化
% maxA = double(max(max(img)));
% img = uint8(double(img)/maxA*255);
end
