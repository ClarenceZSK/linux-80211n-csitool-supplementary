close all;
clear;
clc;


path(path, '~/source/sar/lgtm/csi-code/test-data/line-of-sight-localization-tests--in-room/');
path(path, '~/rosbag/csi_data/');

% log_file = 'los-test-desk-left.dat';
% log_file = 'csi_outdoor.txt';
log_file = 'los-test-jennys-table.dat';


csi_cells = read_bf_file(log_file);



	
N = min(100, length(csi_cells) );

n = 0;
for i = 1 : N
	if csi_cells{i}.Nrx == 3
		n = n + 1;
	end
end

csi_all = zeros(3, 30, n); %Nrx*N_subscarrier*n_packets

j = uint32(1);
for i = 1 : N

	% if csi_cells{i}.Nrx ~= 3
	% 	continue;
	% end
	scaled_csi = get_scaled_csi(csi_cells{i});
	[Ntx, Nrx, nSubcarrer] = size(scaled_csi);
	if Ntx > 1
		csi_all(:, :, j) =  scaled_csi(1, :, :);
	else 
		csi_all(:, :, j) =  scaled_csi;
	end
	
	j = j + 1;

end


cmap = hsv(3);


fig = figure(1);


for j = 1 : n

	clf(fig);
	%amplitute
	subplot(3, 1, 1)
	hold on;
	for i = 1 : 3
		csi = reshape(csi_all(i, :, j), 1, 30);
		amp = abs(angle(csi));
		plot(amp, 'color', cmap( i, :) );
	end

	legend('antenna 1', 'antenna 2', 'antenna 3');
	xlabel('Subcarrier Index')
	ylabel('amplitute CSI phase')
	hold off



	%phase 
	subplot(3, 1, 2)
	hold on;
	for i = 1 : 3 
		csi = reshape(csi_all(i, :, j), 1, 30);
		phase = unwrap(angle(csi), pi, 2);
		plot(phase, 'color', cmap( i, :) );
	end


	legend('antenna 1', 'antenna 2', 'antenna 3');
	xlabel('Subcarrier Index')
	ylabel('Unwraped CSI phase')
	hold off



	%relative phase 
	subplot(3, 1, 3)
	hold on;
	i = 1;
	
	csi1 = reshape(csi_all(1, :, j), 1, 30);
	csi2 = reshape(csi_all(2, :, j), 1, 30);
	csi3 = reshape(csi_all(3, :, j), 1, 30);

	relative_csi12 = csi1.*conj(csi2);
	relative_phase12 = unwrap(angle(relative_csi12), pi, 2);
	plot(relative_phase12, 'color', cmap( 1, :) );


	relative_csi23 = csi2.*conj(csi3);
	relative_phase23 = unwrap(angle(relative_csi23), pi, 2);
	plot(relative_phase23, 'color', cmap( 2, :) );

	
	hold off;
	legend('relative phase of antenna 1 and 2', 'relative phase of antenna 2 and 3');
	xlabel('Subcarrier Index')
	ylabel('Relative CSI phase')
	axis([0 30, -pi, pi])

	filename = sprintf('./plot/%s_%d.png', log_file, j);
	print('-dpng', filename);

end	