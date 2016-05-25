close all;
clear;
clc;

%csi_cells = read_bf_file('D:/dataset/wifi/20151028/log3.txt');
csi_cells = read_bf_file('~/rosbag/csi_data/csi_outdoor3.txt');


N = min(3, length(csi_cells) );

n = 0;
for i = 1 : N
	if csi_cells{i}.Nrx == 3
		n = n + 1;
	end
end

csi_all = zeros(3, 30, n); %Nrx*N_subscarrier*n_packets

j = uint32(1);
for i = 1 : N

	if csi_cells{i}.Nrx ~= 3
		continue;
	end
	scaled_csi = get_scaled_csi(csi_cells{i});
	csi_all(:, :, j) =  scaled_csi;
	j = j + 1;

end


cmap = hsv(2*n);


figure(1);

% subplot(2, 1, 1)
hold on;
i = 1;
for j = 1 : n
	csi = reshape(csi_all(i, :, j), 1, 30);
	phase = unwrap(angle(csi), pi, 2);
	plot(phase, 'color', cmap( (i-1)*n + j, :) );
end
i = 2;
for j = 1 : n
	csi = reshape(csi_all(i, :, j), 1, 30);
	phase = unwrap(angle(csi), pi, 2);
	plot(phase, '--', 'color', cmap( (i-1)*n + j, :) );
end
legend('antenna 1 packet 1', 'antenna 1 packet 2', 'antenna 1 packet 3', 'antenna 2 packet 1', 'antenna 2 packet 2', 'antenna 2 packet 3');
xlabel('Subcarrier Index')
ylabel('Unwraped CSI phase')
hold off


figure(2);
% subplot(2, 1, 2)
hold on;
i = 1;
for j = 1 : n
	csi1 = reshape(csi_all(1, :, j), 1, 30);
	csi2 = reshape(csi_all(2, :, j), 1, 30);
	relative_csi = csi1.*conj(csi2);

	relative_phase = unwrap(angle(relative_csi), pi, 2);
	plot(relative_phase, 'color', cmap( (i-1)*n + j, :) );
end
hold off;
legend('packet 1', 'packet 2', 'packet 3');
xlabel('Subcarrier Index')
ylabel('Relative CSI phase')
axis([0 30, -pi, pi])