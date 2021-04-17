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


function [score, TP] = search_m(database, fingerprint)
 
    for i = 1:length(database) %% for each song in the database
        clear m
        [~, m(:,1), m(:,2)] = intersect(database{i}(:,1),fingerprint(:,1)); %% find the cummon hashes between the sample and the processed song on the database
        if ~(isempty(m)) %% if their's a correspondance
            TP = [database{i}(m(:,1),2), fingerprint(m(:,2),2)]; %% get the absolute time in a pair (t1, t1'), knowing that t1' = t1 - offset
            Dt = abs(TP(:,1) - TP(:,2)); %% calculate the Offset = t1 - t1'
            UDt = unique(Dt); %% remove the multiple occurrences of each Offset 
            M = max(histcounts(Dt,UDt(1):UDt(length(UDt))+1)); %% generate a histogram and find the maximum
            if(M>=8) %% if the max is higher than 8, we stop the research and consider the song found
                break; 
            end
        end
    end

    if (i<=length(database))
        score = [M i]; %% if the song has been found, we store its score and id  
    else
        score = [0 0]; %% otherwise, we put zeros
        Tp = 0;
    end
    
end

