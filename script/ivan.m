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
for ii = 10:10:40

    periode = ii;
    l_sin = periode*pi;
    
    x = linspace(0,l_sin,taille);
    a = amp*sin(x);
    figure
        plot(a)

%     
%     figure
%     plot(a)
figure
    fft_test = abs(fft(a));
%     
    plot(fft_test(2:50))
    
    name = [int2str(periode), '.mat'];
    save(fullfile(path,'freq_pure',name), 'a');
end


%% Melange freq
path = 'C:\Users\User1\Desktop\miroir in';
cd(path)
amp1=0.5;
mkdir freq_mel_amp_colle
periode_1 = 20;
periode_2 = 30;
    path_save = [path,'\','freq_mel_amp_colle'];

for ii=1:0.2:2
    amp2=amp1*ii;
    l_sin_1 = periode_1*pi;
    l_sin_2 = periode_2*pi;
    
    x_1 = linspace(0,l_sin_1,taille);
    a_1 = amp1*sin(x_1);
    x_2 = linspace(0,l_sin_2,taille);
    a_2 = amp2*sin(x_2);
    
    a = a_1+a_2;
            name = [int2str(amp2*10), '.mat'];
                    save(fullfile(path_save,name), 'a');


        figure
        plot(a)
        fft_test = abs(fft(a));
        
        figure
        plot(fft_test(2:50))
end
%%
for ii = 10:10:10
    path_save = [path,'\','freq_mel_collee'];
    cd(path_save)
    mkdir(int2str(ii));
    periode_1 = ii;
    for jj = ii:2:20
        periode_2 = jj;
        l_sin_1 = periode_1*pi;
        l_sin_2 = periode_2*pi;
        
        x_1 = linspace(0,l_sin_1,taille);
        a_1 = amp1*sin(x_1);
        x_2 = linspace(0,l_sin_2,taille);
        a_2 = amp2*sin(x_2);
        
        a = a_1+a_2;

        
        
        name = [int2str(periode_2), '.mat'];
        save(fullfile(path_save,int2str(ii),name), 'a');
        
        
        figure
        plot(a)
        fft_test = abs(fft(a));
        
        figure
        plot(fft_test(2:50))
    end
end

%% gauss_pulse 
path = 'C:\Users\User1\Desktop\miroir in';
cd(path)
mkdir pulse
taille = 100000;
Amp_piezo = 4.18;
mu = taille/2;
periode = 40;
l_sin = periode*pi;

x = linspace(0,l_sin,taille);
d = amp*sin(x);


path_save = fullfile(path,'pulse');
for ii = 5:5:40

    sigma = taille/ii;
    
c = normpdf(1:1:taille,mu,sigma);
c = c/max(c);
figure
plot(c), title('gauss')

a = d.*c;
figure
plot(a), title('pulse')

a_fft = abs(fft(a));

figure
plot(a_fft(2:60)), title('fft pulse')

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
pathload = 'F:\kassandra_avec_K\miroir out\gauss\80\direct.mat';
test = load(pathload);
test = squeeze(test.im);
L=512;

figure
imagesc(test(:,:,1))
%%
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

%% read miroir in
close all
pathload ='C:\Users\User1\Desktop\miroir in\freq_mel\10_1';
name = '20.mat';

sign = load(fullfile(pathload,name));
sign = sign.a;

sign = sign-mean(sign);

fft_sign = abs(fft(sign));
fft_sign = fft_sign(2:100);

figure
plot(fft_sign(1:30))