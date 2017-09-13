imagescale=2;
siftscale=[2 2];

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

DisplayDescriptorImageFull(F,subject,epoch,label,channel,2,false);

