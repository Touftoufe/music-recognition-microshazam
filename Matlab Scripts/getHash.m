%% File : main
%  Author : Sofiane AOUCI
%  Date : Dec 2018
% ------------------------------------------%
% Licence :
% Copyright 2018 Sofiane AOUCI
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%       http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%%


function [fingerprint, S, peaks, F, T,SDilated] = getHash(Opath,varargin)
    narginchk(1,2);  
    if(isempty(varargin)) 
        id = 0; 
    else
        id = varargin{1}; 
    end
    
    %% signal frequency in Hz
    fs = 11025; 
    %% the widh of the aquisition window
    NWindow = 1024; 
    %% generate a hamming window
    Window = hamming(NWindow); 
    %% number of points in the fft function
    NFFT = NWindow; 
    %% overlap de 50 %
    NOverlap = NWindow/2; 
     %% the size of the structural element
    ED_size = [20 20];
    %% max pairs for a targeted zone
    Npairs_a = 10; 
    
    if(isnumeric(Opath))
    	%% data acquisition when recording at a frequency fs = 11025 Hz 16 bit mono
        S = Opath; 
    else
    	%% Readig a mono audio file on the machine
        [S Ofs] = audioread(Opath);
        %% resampling at at fs = 11025 hz  
        S = resample(S,fs,Ofs);  
    end

    %% calculate the spectrogram. F represents the frequences and T the time
    [S, F, T] = spectrogram(S, Window, NOverlap, NFFT, fs); 
    %% calculate the power in dB
    S = 10*log10(abs(S));  
    
    % ------------------------------- Research of energy pics --------------------------------%
    
    %% Building if a 20 px * 20 px square structual element 
    MSE = strel('rectangle', ED_size);
    %% Dilation of th spectrogram 
    SDilated = imdilate(S,MSE); 
    
    %% Superposition of the 2 spectrograms and saving the energy pics indexes
    [i_freqP, i_tP] = find(SDilated == S);  
    %% save the pairs (freq,time) that corresponds to the pics in a matrix
    peaks = [F(i_freqP), T(i_tP)'];  
    
    %--------------------------- Hashes and footprints generation ----------------------------%
    i_pair = 0; %% counter
    fingerprint = zeros(length(peaks)*Npairs_a,3); %% init
    
    %% Every energy pic is an anchor point
    for i = 1:length(peaks)-1  
        i_anchorF = i_freqP(i);
        i_anchorT = i_tP(i);

        %% research for the 10 first neghibors of each anchor point in a trageted zone of 4s height and 1000 Hz widh
        [row, col] = find((abs(i_freqP - i_anchorF) < 46) & ((i_tP - i_anchorT) > 0) & ((i_tP - i_anchorT) < 43), Npairs_a);
        
        %% Hash encoding = [f1 (10 bits), f2 (10 bits), Dt (12 bits)]
        for j = 1:length(row)
        	%% 22 bits shift to the left
            currentFreq = uint32(i_anchorF * 2^22); 
            currentTime = i_anchorT;
            %% 12 bits shift to the left
            targetFreq = uint32(i_freqP(row(j)) * 2^12); 
            Dt = uint32(i_tP(row(j)) - i_anchorT);
            i_pair = i_pair + 1;
            %footprints generation = [Hash,t1,id]
            fingerprint(i_pair,:) = [currentFreq + targetFreq + Dt, currentTime, id];    
        end 
    end
    %% get rid of the nonused data
    fingerprint = fingerprint(1:i_pair,:); 
end
