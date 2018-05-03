%% Miroir in

%%test miroir signal imposee

taille = 100000;
Amp_piezo = 4.18;
periode = 20;
l_sin = periode*pi;
mu = taille/2;

%%freq_pure
path = 'C:\Users\User1\Desktop\miroir in';
cd(path);
mkdir freq_pure
amp = 0.5;
for ii = 10:10:80

    periode = ii;
    l_sin = periode*pi;
    
    x = linspace(0,l_sin,taille);
    a = amp*sin(x);
%     
%     figure
%     plot(a)
%     fft_test = abs(fft(a));
%     
%     figure
%     plot(fft_test(2:50))
    
    name = [int2str(periode), '.mat'];
    save(fullfile(path,'freq_pure',name), 'a');
end


%% Melange freq
path = 'C:\Users\User1\Desktop\miroir in';
cd(path)
amp=0.5;
mkdir freq_mel
for ii = 10:10:80
    path_save = [path,'\','freq_mel'];
    cd(path_save)
    mkdir(int2str(ii));
    periode_1 = ii;
    for jj = ii:10:80
        periode_2 = jj;
        l_sin_1 = periode_1*pi;
        l_sin_2 = periode_2*pi;
        
        x_1 = linspace(0,l_sin_1,taille);
        a_1 = amp/2*sin(x_1);
        x_2 = linspace(0,l_sin_2,taille);
        a_2 = amp/2*sin(x_2);
        
        a = a_1+a_2;

        
        
        name = [int2str(periode_2), '.mat'];
        save(fullfile(path_save,int2str(ii),name), 'a');
        
        
%     figure
%     plot(a)
%     fft_test = abs(fft(a));
%     
%     figure
%     plot(fft_test(2:50))
    end
end

%% gauss_pulse 
path = 'C:\Users\User1\Desktop\miroir in';
cd(path)
mkdir pulse
mu = taille/2;
x = linspace(0,80*pi,taille);
b = 0.5*sin(x);

figure
plot(b), title('sin')
path_save = fullfile(path,'pulse');
for ii = 10:10:80

    sigma = taille/ii;
    
c = normpdf(1:1:taille,mu,sigma);
c = c/max(c);
% figure
% plot(c), title('gauss')

a = b.*c;
figure
plot(a), title('pulse')

a_fft = abs(fft(a));

figure
plot(a_fft(2:200)), title('fft pulse')

        name = [int2str(ii), '.mat'];
        save(fullfile(path_save,name), 'a');

end

%%
pathload = 'Z:\res test miroir\pulse\50\direct.mat';
test = load(pathload);
test = squeeze(test.im);

fft_test = abs(squeeze(mean(mean(fft(test,[],3),1),2)));

figure
plot(fft_test(2:end/2+1))
%%
[x, y] = ginput(2);
x=floor(x);
y=floor(y);
miroir_new = miroir(y(1):y(2), x(1):x(2),:);
%%
clear test
pathload = 'Z:\res test miroir\pulse\50_tris\direct.mat';
test = load(pathload);
test = squeeze(test.im);
L=512;
%%
figure
imagesc(test(:,:,1))
[x, y] = ginput(1);
x=floor(x);
y=floor(y);
miroir_new = test(y, x,:);

%  miroir_new = test(y(1):y(2), x(1):x(2),:);

fft_test = fft(miroir_new,[],3)./L;
fft_test = abs(fft_test);
fft_test = fft_test(:,:,1:L/2+1);
fft_test (:,:,2:end-1) = 2*fft_test(:,:,2:end-1);
fft_test_mean = squeeze(mean(mean(fft_test,1),2));

figure
plot(fft_test_mean(3:end)), title('Signal OUT perso')