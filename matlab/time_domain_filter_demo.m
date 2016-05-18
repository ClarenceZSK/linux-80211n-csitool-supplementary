%use ifft to filter the non-LOS signal

close all;
%clear;
clc;

%csi_cells = read_bf_file('D:/dataset/wifi/20151028/log3.txt');
csi_cells = read_bf_file('~/rosbag/csi_data/csi_outdoor3.txt');

K = length(csi_cells);

cmap = hsv(3); 
fig = figure;

%show csi phase 
for i = 1 : length(csi_cells)
	csi = csi_cells{i}.csi;
	scaled_csi = get_scaled_csi(csi_cells{i});
	[Ntx, Nrx, N] = size(csi);
	if Nrx ~= 3
		continue;
	end
	
	
	
	for j = 1 : Nrx
		csi_f = reshape(csi(1, j, :), 1, N);
		csi_t = ifft(csi_f);
		csi_t_filtered = time_domain_filter(csi_t);
		csi_f_filtered = fft(csi_t_filtered);
		
		ax1 = subplot(3, Nrx, j);
		cla(ax1, 'reset');
		hold on;
		plot(abs(csi_f),'Color', cmap(j, :));
		%bar(abs(csi_f));
		plot(abs(csi_f_filtered),'Color', cmap(j, :));
		title('frequency response')
		hold off;
		
		
		ax2 = subplot(3, Nrx, j + Nrx);
		cla(ax2, 'reset');
		hold on
		bar(abs(csi_t));
		title('channle impulse response');
		hold off;
		
		
		ax3 = subplot(3, Nrx, j + Nrx*2);
		cla(ax3, 'reset');
		hold on
		bar(abs(csi_t_filtered));
		title('channle impulse response');
		hold off;
		
	end
	
	
	pause(0.5);
end