     function [train_ica_set,train_label,test_ica_set,test_label] = train_test_data()
clear
% close all
dir_name = {'����','����֧����','����֧����','�����粫','�����粫','������'};
train_set_0 = [];
train_label = [];
test_set_0 = [];
test_label = []; 

for dir_index = 1:length(dir_name)
    dir_path = ['C:\Users\gcl\Desktop\[��Ҫ]ECG�������С����ELM\ecg\data\', dir_name{dir_index}];
    files = dir(fullfile(dir_path, '*.mat'));
    num = length(files);
    file_vector = randperm(num);
    figure;
    for i = 1:num%%%%%����һ���ļ����µ�ÿ���ļ�
        out=[];
        file_name = [dir_path, '\',  files(file_vector(i)).name];
        load(file_name);%%%%��ȡ�ļ�    
        out_size=length(RR)-2;
        
        for j=2:out_size+1
            datax=(C{j}-mean(C{j}))/std(C{j});%%%��ע��
            tt=wpdec(datax',3,'haar');   
            wp=wpcoef(tt,8); 
            out=[out;wp];%%%%1������������
        end
        datay=C{ceil(out_size/2)};
        subplot(ceil(num/2),2,i);plot(datay);axis([1 261 -3 3]);title(dir_name{dir_index});

        index_vector = randperm(out_size);%%%%����˳��
        train_size = floor(out_size*.6);%%ѵ��������Ŀ
        test_size = out_size - train_size;%%���Լ�����Ŀ

        train_set_0 = [train_set_0;out(index_vector(1:train_size),:)];%%%ѵ��������������
        test_set_0 = [test_set_0;out(index_vector(train_size+1:out_size),:)];%%%���Լ�����������
       
        train_label = [train_label;dir_index*ones(train_size,1)];%%%ѵ������label 
        test_label = [test_label;dir_index*ones(test_size,1)];%%%���Լ���label 

    end
end

[X,A,~] = fastica([train_set_0;test_set_0]', 'numOfIC',40);%%%ICA�����ɷַ���
train_ica_set = X(:,1:length(train_label));%%%%%%%�õ�ѵ��������
test_ica_set = X(:,length(train_label)+1:end);%%%%%%%�õ����Լ�����