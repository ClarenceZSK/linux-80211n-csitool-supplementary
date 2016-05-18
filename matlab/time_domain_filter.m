function y = time_domain_filter(x)
	N = length(x);
	x2 = abs(x);
	[max_val, max_val_id] = max(x2);
	id = find(x2 <= max_val*0.2 & (1 : N) > max_val_id);
	x(id) = 0i;
	y = x;
end
	
	

