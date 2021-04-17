%% File : main
%  Author : Sofiane AOUCI
%  breif : Music/song recognition algorithm
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



%% A database must already exist along with a list of the songs titles 
%% You can import the "vars.mat" file into your workingspace where the necessary variables
%% are stored : the database "database" and the songs list "songdir"

%% Create a new object "Rudio Recorder"
recObj = audiorecorder(11025,16,1);
 n = 0;
 s(1,1) = 0;
 % Record 2s samples and try to indentify the song
 % if the algorithm doesn't find the result after 5 itterations
 % then it was unable to find a correspondance
 disp('Start recording...')
 tic
 while (s(1,1) <= 8 && n < 5)
    recordblocking(recObj, 2); % start recording (2s)
    sample = getaudiodata(recObj); %get data
    H = getHash(sample); % generate footprints
    s = search_m(database,H); % research in the database
    n = n + 1;
 end
toc
 if (s(1,1) > 8)
 	%% display the score and the title of the song recognized
 	fprintf("%d --> %s\n",s(1,1),songdir(s(1,2)).name)
 else
 	fprintf("I coudn't find this song, does it exist in the DATABASE?\n")
 end
