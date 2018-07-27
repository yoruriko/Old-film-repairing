function output = labs3(path, prefix, first, last, digits, suffix)

%
% Read a sequence of images and correct the film defects. This is the file 
% you have to fill for the coursework. Do not change the function 
% declaration, keep this skeleton. You are advised to create subfunctions.
% 
% Arguments:
%
% path: path of the files
% prefix: prefix of the filename
% first: first frame
% last: last frame
% digits: number of digits of the frame number
% suffix: suffix of the filename
%
% This should generate corrected images named [path]/corrected_[prefix][number].png
%
% Example:
%
% mov = labs3('../images','myimage', 0, 10, 4, 'png')
%   -> that will load and correct images from '../images/myimage0000.png' to '../images/myimage0010.png'
%   -> and export '../images/corrected_myimage0000.png' to '../images/corrected_myimage0010.png'
%

% Your code here

frames = load_sequence(path, prefix, first, last, digits, suffix);

% Detect cuts in the footage
% labs3('footage','footage_',1,657,3,'png');
disp('Detecting footage cuts...'); 
cuts = detect_cuts(frames,0.5);


for k=1:size(cuts,2)
    
    disp(['Processing cut ',num2str(k),' ...']);
    cut_frame = cuts{k};
    
    disp(['Removing gobal flicker of cut ',num2str(k),' ...']);
    % remove global flicker that occurs in the footage
    cut_frame = remove_flicker(cut_frame,11);
    
    % remove vertical strip artefacts in last cuts
    if k==size(cuts,2)
        disp(['Removing vectical strip of cut ',num2str(k),' ...']);
        cut_frame = correct_strip(cut_frame,8:-2:2,5);
    end
    
    if k~=size(cuts,2)
        % remove the blotches in the two cuts
        disp(['Removing blotches in cut ',num2str(k),' ...']);
        cut_frame = remove_blotch(cut_frame,0.06,400);
        
        % remove the camera shake of first two cuts
        disp(['Correcting camera shake of cut ',num2str(k),' ...']);
        cut_frame = remove_camera_shake(cut_frame,150,10,10);
        
        % add transiiton hints for each cuts
        disp(['Adding transition text of cut ',num2str(k),' ...']);
        cut_frame = add_transition(cut_frame,'Next Flim Is Coming...',20);
    end
    
    cuts{k}=cut_frame;
end

result_frames = cat(3,cuts{:});
%save_sequence(uint8(result_frames), 'result', 'image', 1, 3);
name = 'result';
filename = ['resultVideo/' name '.avi'];
v = VideoWriter(filename,'Uncompressed AVI');
open(v) ;
for k=1:size(result_frames,3)
    combineFrame = [frames(:,:,k),result_frames(:,:,k)];
    imshow(combineFrame);
    writeVideo(v,combineFrame) ;
end
close(v);

end
