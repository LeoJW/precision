%rerun with K = 4
function [miVec] = MutualInformationbynoiseuniform(filename, musclename)

tic
%testing noise
filename =[ 'Moth', '2', '_MIdata.mat'];

load(['D:\tenie_data\Desktop\Summer 2019\Moth Motor Timing\TobiasShare\SubmittedDataallmusclesAllareTzWsd/', filename])

musclename = 'LDVM';
musclefortime = [musclename, 'strokes'];
muscleforspike = [musclename, 'spikes'];
numofneighbors = 4;%this was not run before

miVec = [];
noisevec =[];

minnumspike = min(spike_data.(muscleforspike));
maxnumspike = max(spike_data.(muscleforspike));
[j, k] = size(time_data.(musclefortime));
for i = minnumspike:maxnumspike
    if i == 0
        spikestructnorm.(['spike', num2str(i)]).timedata = time_data.(musclefortime)(spike_data.(muscleforspike) == i, :);
    else
        if k<=i
            spikestructnorm.(['spike', num2str(i)]).timedata = time_data.(musclefortime)(spike_data.(muscleforspike) == i, 1:k);
        else
            spikestructnorm.(['spike', num2str(i)]).timedata = time_data.(musclefortime)(spike_data.(muscleforspike) == i, 1:i);
        end
    end
        spikestructnorm.(['spike', num2str(i)]).PCAedtorque = Tz_WSd(spike_data.(muscleforspike) == i, :);
        spikestructnorm.(['spike', num2str(i)]).probability = length(spikestructnorm.(['spike', num2str(i)]).timedata)/length(spike_data.(muscleforspike));
        
        
    end
    
    noise = (0:.05:6);
    
    miVec = zeros(150, length(noise));
    [a,b] = size(miVec);
    fn =  fieldnames(spikestructnorm);
    
    for x = 1:b
        
        
        for y = 1:a
            
            % Add noise to spike data to prevent weird estimations when spike counts
            % are the same for many wing strokes.
            %spike_data_noised = spike_data + 0.0001*randn(size(spike_data,1),size(spike_data,2));
            for ffn = fn'
                ffn;
                dbstop if error
                numwordsnoised = spikestructnorm.(ffn{1}).timedata + (noise(x).*rand(size(spikestructnorm.(ffn{1}).timedata,1),size(spikestructnorm.(ffn{1}).timedata,2)));
                %USE 2*noise(x)*rand - noise(x) FOR TWO SIDED WINDOW
                [j, k] = size(numwordsnoised);
                if j > numofneighbors && j+1 > str2num(ffn{1}(end))
                    wMI = MIxnyn(numwordsnoised,spikestructnorm.(ffn{1}).PCAedtorque,numofneighbors);
                    wMI = wMI./log(2); % convert from nats to bits, since C code gives all values in nats.
                else
                    
                    wMI = 0;
                    
                end
                miVec(y, x) = wMI*spikestructnorm.(ffn{1}).probability+miVec(y, x);
                
            end
        end
    end
    noisevec = noise;
    
    
    mimean = mean(miVec);
    
     figure
     mseb(noisevec, mimean, std(miVec, 1));
    %
     title(['Mutual Information vs uniform Noise Added', filename(1:5), musclename])
     xlabel('Noise added to timing')
     ylabel('Mutual Information rate')
     saveas(gcf, ['D:\tenie_data\Desktop\Summer 2019\Moth Motor Timing\',['Mutual Information vs uniform Noise Added', filename(1:5), musclename, '.fig']])
    toc
end