clc;
clear;
close all
addpath wavelet;
addpath FastICA_25;
addpath code;
warning off
 
dir_name = {'����','����֧����','����֧����','�����粫','�����粫','������'};
train_set_0 = [];
train_label = [];
test_set_0 = [];
test_label = [];

for dir_index = 1:length(dir_name)
    dir_path = ['data\', dir_name{dir_index}]; % i=1����
    files = dir(fullfile(dir_path, '*.mat')); 
    num = length(files);% �������ļ�������num=5��,mat�ļ�
    file_vector = randperm(num); % 1��5�������
    figure;
    for i = 1:num%%%%%����һ���ļ����µ�ÿ���ļ�
        out=[];
        file_name = [dir_path, '\',  files(file_vector(i)).name];
        load(file_name);%%%%��ȡ�ļ�  RR   
        out_size=length(RR)-2; 
        
        for j=2:out_size+1
            datax=(C{j}-mean(C{j}))/std(C{j});%%%��ע�� ��׼���׼����������������ݷ��ϱ�׼��̬�ֲ�(��׼������ƽ����0��׼��1�����λ�ò���ֲ���״����)
            tt=wpdec(datax',3,'haar'); % һάhaarС���������������㣬���ݳ�����1/(2^n)��n=3
            wp=wpcoef(tt,8); % ĳ���ڵ��С����ϵ���ع����õ����Ǻ�ԭ�ź�һ�����ȵ��źš�
            out=[out;wp];%%%%1������������
        end
        datay=C{ceil(out_size/2)};
        subplot(ceil(num/2),2,i);plot(datay);axis([1 261 -3 3]);title(dir_name{dir_index});
%       ÿһ����һ�����ڣ���һ����������
        index_vector = randperm(out_size);%%%%����˳��1-134�����д���
        train_size = floor(out_size*.6);%%ѵ��������Ŀ80
        test_size = out_size - train_size;%%���Լ�����Ŀ54

        train_set_0 = [train_set_0;out(index_vector(1:train_size),:)];%%%ѵ��������������
        test_set_0 = [test_set_0;out(index_vector(train_size+1:out_size),:)];%%%���Լ�����������
       
        train_label = [train_label;dir_index*ones(train_size,1)];%%%ѵ������label ������==1��
        test_label = [test_label;dir_index*ones(test_size,1)];%%%���Լ���label ������==1��

    end
end
% ICA X���������������Ͼ���A
[X,A,~] = fastica([train_set_0;test_set_0]', 'numOfIC',40);%%%ICA�����ɷַ���,��һ������������ϲ���ת�á�ICA��ָ��ֻ֪������źţ�����֪��Դ�źš������Լ���ϻ��Ƶ�����£��������Ƶط����Դ�źŵ�һ�ַ������̡�
train_set = X(:,1:length(train_label));%%%%%%%�õ�ѵ��������
test_set = X(:,length(train_label)+1:end);%%%%%%%�õ����Լ�����


Tn_train=BP(train_label); % ��ǩ�Ĵ�����������[100000],����֧����[010000]

net=newff(minmax(train_set),[20,6],{'tansig' 'tansig'} ,'traingda'); % ÿ�е������Сֵminmax(train_set)��33��2�У���һ����20����Ԫ���ڶ���6������һ��Ĵ��ݺ�����tan-sigmoid����S�ʹ��ݺ���
net.trainParam.show=500;        %  show: ������ʾ֮���ѵ������
%ѵ������
net.trainParam.lr=1;            % ѧϰ�����½�ֵ
net.trainParam.epochs=5000;      %ѵ������ȡ10000
net.trainParam.goal=0.05;        %�������ȡ0.01
net=train(net,train_set,Tn_train); % ���� �������Q��N������QΪ�����������


%ͳ��ѵ������
YY=sim(net,train_set); % 6 ��1420�У������һ�е�һ�У���ʾ�������ĸ���,...
[maxi,ypred]=max(YY); % ypred�洢����ѵ��֮��ı�ǩ��maxi��Ӧ����׼ȷ��
maxi=maxi';
ypred=ypred';
CC=ypred-train_label; %��ǩ�ľ��롣
n=length(find(CC==0)); % 1290
TrainingAccuracy=n/size(train_set,2); % 0.9085
%ͳ�Ʋ��Ծ���
YY=sim(net,test_set);
[maxi,ypred]=max(YY);
maxi=maxi';
ypred=ypred';
CC=ypred-test_label;
n=length(find(CC==0));
TestingAccuracy=n/size(test_set,2); % 0.8917

end_time_train=cputime;
%  Time_using=end_time_train-start_time_train;

%��ѵ�����Ծ��ȴ�ӡ������command���￴
disp(sprintf('BPѵ������Ϊ%i',TrainingAccuracy));
disp(sprintf('BP���Ծ���Ϊ%i',TestingAccuracy));
 

T_test=test_label;



test_hunxiao=[];
for i=1:6
    for j=1:6
        test_hunxiao(i,j)=length(find(ypred(find(T_test==i))==j))/length(find(T_test==i)); % ��������ļ��㣬1��һ����ԭ����1Ԥ����1�ĸ��ʣ�1��2��ԭ��1Ԥ����2����

    end
end
figure
imagesc(test_hunxiao);%����������
colormap(flipud(gray));  %# ת�ɻҶ�ͼ����˸�value�ǽ���ɫ�ģ���value�ǽ��׵�

textStrings = num2str(test_hunxiao(:),'%0.2f');  
textStrings = strtrim(cellstr(textStrings)); 
[x,y] = meshgrid(1:6); 
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim')); 
textColors = repmat(test_hunxiao(:) > midValue,1,3); 
%�ı�test����ɫ���ں�cell����ʾ��ɫ
set(gca,'xtick',[1:1:6]);
set(gca,'ytick',[1:1:6]);
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'xticklabel',{'����','����֧����','����֧����','�����粫','�����粫','������'},'XAxisLocation','top');
set(gca,'yticklabel',{'����','����֧����','����֧����','�����粫','�����粫','������'},'XAxisLocation','top');
title('ʶ���ʵĻ�������');


   