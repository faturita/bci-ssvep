clear all;
close all;

cleanimagedirectory();

Fs=256;
channelRange=1:128;

%channelRange=[58 59 60 61 62];

%channelRange=58:59;


frequencies = {8,14,28};

labelRange=[];

for subject=1:1
trialfreq=1
for freq=1:3
    for trial=1:5
        % 4 Sujetos
        % 5 Trials para cada sujeto.
        load(sprintf('/Users/rramele/GoogleDrive/BCI.Dataset/SSVEP/SSVEP_%dHz_Trial%d_SUBJ%d.MAT',frequencies{freq},trial,subject))

        eeg = bf(EEGdata',1:128:size(EEGdata,2));
        eeg=detrend(eeg);

        for flash=1:15
            EEG(subject,trialfreq,flash).EEG = eeg(5*Fs+(flash-1)*Fs:5*Fs+(flash-1)*Fs+1*Fs-1,:);
            EEG(subject,trialfreq,flash).label = freq;
            labelRange(end+1)=freq;
            

            % Del segundo 5 al 20 estan los bloques de SSVEP, son 15 segundos
            % Lo ideal entonces es cortar la se?al en 15 para cada combinacion y luego
            % clasificarlas

        end
        trialfreq=trialfreq+1;
    end
end
end


minimagesize=150;
siftdescriptordensity=1;
imagescale=4;
siftscale=[4 4];

channel=1;

%%
qKS=23:233;
% [eegimg, DOTS, zerolevel] = eegimage(channel,EEG(1,11,1).EEG,imagescale,1,false,minimagesize);
%                 
% [frames, desc] = PlaceDescriptorsByImage(eegimg, DOTS, siftscale, siftdescriptordensity,qKS,0,false);
% 
% DisplayDescriptorImageByImage(frames,desc,eegimg,1,false);
epoch=0;
for subject=1:1
    for trial=1:15
        for flash=1:15
            epoch=epoch+1;
            for channel=channelRange
                
                signal = EEG(subject,trial,flash).EEG;
                
                [n,m] = size(signal);
                signal = signal - ones(n,1)*mean(signal,1);
                
                [eegimg, DOTS, zerolevel] = eegimage(channel,signal,imagescale,1,false,minimagesize);
                label=labelRange(epoch);
                saveeegimage(subject,epoch,label,channel,eegimg);
                zerolevel=size(eegimg,1)/2;
                
                zerolevel=0;
                
                qKS=23:233;              
                [frames, desc] = PlaceDescriptorsByImage(eegimg, DOTS, siftscale, siftdescriptordensity,qKS,0,false);
                F(channel,label,epoch).frames = frames;
                F(channel,label,epoch).descriptors = desc;
                %DisplayDescriptorImageByImage(frames,desc,eegimg,1,false);
            end
        end
    end
end

%%
epochRange=1:epoch;
scramble = epochRange(randperm(size(labelRange,2),size(labelRange,2)));

trainingRange=[1:30 76:105 151:180];
testRange=[31:75 106:150 181:225];

for channel=channelRange
    DE(channel) = NBNNFeatureExtractor(F,channel,trainingRange,labelRange,[1 2 3],false); 

    %[DE(channel), ACC, ERR, AUC, SC(channel)] = NBNNClassifier(F,DE,channel,testRange,labelRange,false);
    [ACC, ERR, AUC, SC(channel)] = NBNNClassifier(F,DE(channel),channel,testRange,labelRange,false);

    globalaccij1(subject,channel)=ACC;
    globalsigmaaccij1 = globalaccij1;
    globalaccij2(subject,channel)=AUC;
end  
     


%%
figure;DisplayDescriptorImageFull(F,1,70,1,channel,2,false);
figure;DisplayDescriptorImageFull(F,1,145,2,channel,2,false);
figure;DisplayDescriptorImageFull(F,1,220,3,channel,2,false);