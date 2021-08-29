function freq_data = remove_0(freq_data)
% remove_0 removes the 0Hz frequency from all axes
% input freq_data: frequency data matrix (N x 3)

    %for each axis: find max frequency (will be 0Hz) and make amplitude 0
    for i=2:4
        [~, Index] = max(freq_data(:,i));
        freq_data(Index, i) = 0;
    end
end