function [X sfreq]=readdata(groupnum)   %��ȡ�ĵ����� 
%PATH= 'C:\Users\Administrator\Desktop\ecg\myfun\';      %ָ�����ݵĴ���·��
% PATH='C:\Users\gcl\Desktop\[��Ҫ]ECG�������С����ELM\ecg';
datanum=num2str(groupnum);
suffixhead='.hea'; 
suffixdate='.dat';
HEADERFILE=[datanum suffixhead];                  %.hea ��ʽ��ͷ�ļ������ü��±���
DATAFILE=[datanum suffixdate];                     %.dat ��ʽ��ECG ����
SAMPLES2READ=40000;                      %ָ����Ҫ�����������,��.dat�ļ��д洢������ͨ�����ź�:����� 2*SAMPLES2READ ������ 


%��ȡͷ�ļ��е���Ϣ
signalh=fullfile(PATH, HEADERFILE);                   % ͨ������ fullfile ���ͷ�ļ�������·��
fid1=fopen(signalh,'r');                              % ��ͷ�ļ������ʶ��Ϊ fid1 ������Ϊ'r'--��ֻ����
z=fgetl(fid1);                                        % ��ȡͷ�ļ��ĵ�һ�����ݣ��ַ�����ʽ
A=sscanf(z, '%*s %d %d %d',[1,3]);                    % ���ո�ʽ '%*s %d %d %d' ת�����ݲ�������� A ��
nosig=A(1);                                          % �ź�ͨ����Ŀ
sfreq=A(2);                                           % ���ݲ���Ƶ��
clear A;                                              % ��վ��� A ��׼����ȡ��һ������
for k=1:nosig                                         % ��ȡÿ��ͨ���źŵ�������Ϣ
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);           % �źŸ�ʽ; ����ֻ����Ϊ 212 ��ʽ
    gain(k)= A(2);              % ÿ mV ��������������
    bitres(k)= A(3);            % �������ȣ�λ�ֱ��ʣ�
    zerovalue(k)= A(4);         % ECG �ź������Ӧ������ֵ
    firstvalue(k)= A(5);        % �źŵĵ�һ������ֵ (����ƫ�����)
end;
fclose(fid1);
clear A;


%��ȡdata����
if dformat~= [212,212], error('this script does not apply binary formats different to 212.'); end;
signald= fullfile(PATH, DATAFILE);           % ���� 212 ��ʽ�� ECG �ź�����
fid2=fopen(signald,'r');
A= fread(fid2, [3,SAMPLES2READ], 'uint8');  % matrix with 3 rows, each 8 bits long, = 2*12bit ����A����SAMPLES2READ�С�3�У�ÿ�����ݶ�����uint8��ʽ���룬ע����ʱ����ͨ��uint8�Ķ��뷽ʽ�Ѿ���Ϊʮ��������
fclose(fid2);
M2H= bitshift(A(2,:), -4);        % �ֽ���������λ����ȡ�ֽڵĸ���λ�������ź�2�ĸ�4λ
M1H= bitand(A(2,:), 15);          %ȡ�ֽڵĵ���λ
PRL=bitshift(bitand(A(2,:),8),9);     % sign-bit   ȡ���ֽڵ���λ�����λ�������ƾ�λ  ��λ��
PRR=bitshift(bitand(A(2,:),128),5);   % sign-bit   ȡ���ֽڸ���λ�����λ����������λ
M( 1 , :)= bitshift(M1H,8)+ A( 1 , : )-PRL;% ��M1H��M2H�ֱ�����8λ��������2^8���ٷֱ����A(:,1)��A(:,2)��
M( 2 , :)= bitshift(M2H,8)+ A( 2 , : )-PRR;% ��������ʱ�ѷ���λҲ�ƶ��ˣ�Ҫ��ȥ����λ��ֵ
M( 1 , :)= (M( 1 , :)- zerovalue(1))/gain(1);
M( 2 , :)= (M( 2 , :)- zerovalue(2))/gain(2);
clear A M1H M2H PRR PRL;
X=M(1,:);
end


