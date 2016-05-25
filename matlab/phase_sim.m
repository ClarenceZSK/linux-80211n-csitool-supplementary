phi1 = [0 :  1 : 180]*pi/180;
phi2 = [180: -1 : 0]*pi/180;
phi = [phi1, phi2, phi1, phi2, phi1, phi2];
alpha = rand(1)*10;


lambda = 0.05639;
r = 0.8*lambda/2;

n = length(phi);
t = (1 : n)*0.01; 
y = -2*pi*r/lambda*cos(phi - alpha);

y = wrapToPi(y);

plot(t, y);

