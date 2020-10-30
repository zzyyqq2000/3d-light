clear;
clc;
%------------------------------------------------------------打开串口

delete(instrfindall)   %关闭没用的，这句很重要
s=serial('COM7');  %创建串口（需调整）
set(s,'BaudRate',9600);    %设置波特率
set(s,'InputBufferSize',1024000)   %设置输入缓冲区域为1M
set(s,'Parity','even');
closepreview;

%------------------------------------------------------------摄像头设置

vid = videoinput('winvideo', 2, 'YUY2_640x480');%分辨率为640*480
src = getselectedsource(vid);
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
triggerconfig(vid, 'manual');
vid.ReturnedColorspace = 'grayscale';%采集灰度图像

%----------------------------------------------------------初始图片采集
%path_in1：图片存储路径
%cunchu：图片存储矩阵640*480*200

start(vid);
trigger(vid);
img = getdata(vid);
path_in1='D:\3d_light\raw';%图片存储路径
cunchu=zeros(480,640,200);
n=200;
for i =1:n
    trigger(vid);
    im=getdata(vid);
    cunchu(:,:,i)=im;
    imwrite(im,strcat(path_in1,num2str(i),strcat('.','jpg')),'jpg'); % 保存图dao片（以数字命名dao）
    fopen(s);  %打开串口
    fwrite(s,1);
    fclose(s);
end
stop(vid);

%-----------------------------------------------------------图像处理
%center_cap=rotate;
% img=rgb2gray(rotate);
% g=erzhihua(img);
% h=clean(g);
% imshow(h)
%测得旋转轴横坐标为388，此处直接利用，不再重测
%将cunchu矩阵二值化，滤波，骨化，去毛刺，得到矩阵pro_pic(640*480*200)
%path_in2：图片存储路径

cap_3d=cunchu;
[a,b,c]=size(cap_3d);
pro_pic=zeros(a,b,c);
path_in2='D:\3d_light\process';%图片存储路径
for k=1:c
    f=erzhihua(cap_3d(:,:,k));
    pro_pic(:,:,k)=clean(f);
    imwrite(pro_pic(:,:,k),strcat(path_in2,num2str(k),strcat('.','jpg')),'jpg'); % 保存图dao片（以数字命名dao）
end

%---------------------------------------------------------生成点云
%将pro_pic转化为ptCloud点云并显示
%生成可用meshlab打开的ply文件
%='D:\3d_light\';%文件存储路径

rou=pro_pic;
num=1;
for k=1:c
    for i=1:a
        for j=1:b
            if(rou(i,j,k))
                x(num,1)=(j-388)*sin(-pi/100*(k-1));
                y(num,1)=(j-388)*cos(pi/100*(k-1));
                z(num,1)=a-i;
                rgb(num,1)=255;
                rgb(num,2)=255;
                rgb(num,3)=255;
                num=num+1;
            end
        end
    end
end
xyz=[x,y,z];
ptCloud = pointCloud(xyz);%生成点云
figure;pcshow(ptCloud);%显示点云
pcwrite(ptCloud,'D:\3d_light\cloud.ply','PLYFormat','binary');%生成ply文件

%--------------------------------------------------------------%二值化函数

function f1=erzhihua(f1)
%二值化函数
%阈值c为最大像素与最小像素的平均值
%输入为原图片（f1），要求为灰度图
%输出为二值化图片（f1）
max=0;
min=255;
[a,b]=size(f1);
for i=1:a
    for j=1:b
        if(f1(i,j)<min)
            min=f1(i,j);
        end
        if(f1(i,j)>max)
            max=f1(i,j);  
        end
    end 
end
 c=(min+max)/2;
 for i=1:a
    for j=1:b
        if(f1(i,j)<=c)
            f1(i,j)=0;
        else
            f1(i,j)=255;  
        end
    end 
 end
end 

%----------------------------------------------------------提取中心条纹函数

function out=clean(A)
%提取条纹中心
%中值滤波-低通滤波-骨化-去毛刺
%输入为图片A，要求已被二值化
%输出为out

   %中值滤波
   kernel = 3;
   A= medfilt2(A,[kernel ,kernel ]);
   
   %gaussian低通滤波器
   sigma=1;%滤波器的标准差
   parameters=double(3*sigma*2+1); % 模板尺寸
   H=fspecial('gaussian', parameters, sigma);%滤波算子 
   img=imfilter(A,H,'replicate');
   
   %骨化
   BW=img;
   BW1=bwmorph(BW,'spur',5);
   BW1=bwmorph(BW1,'skel',20);
   BW1=bwmorph(BW1,'spur',5);
   BW1=bwmorph(BW1,'bridge',20);

   %去毛刺(消除噪声)
   BW2=bwmorph(BW1,'spur',10);
   BW2=bwmorph(BW2,'clean',10);

   out=BW2;
end