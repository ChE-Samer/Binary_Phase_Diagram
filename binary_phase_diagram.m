%% clear environment
% 3D interactive model: https://skfb.ly/o6DoI
clear
clf('reset')
clc


%% vapor pressure relations
% ethanol
p_e = @(T) 10 .^ (4.92531 - 1432.526 ./ (T - 61.819));

% water
p_w = @(T) 10 .^ (3.55959 - 643.748 ./ (T - 198.043));


%% figure configurations
% create figure
fig = figure(1);
view(3)
grid on
hold on
axis([0 1 300 400 0 5])
xticks(0:0.1:1)
xlabel('Composition x-y [-]')
ylabel('Temperature, T [K]')
zlabel('Pressure, P [bar]')

% prepare composition, temperature, pressure grids
[x, T_mesh] = meshgrid(0:0.1:1, 300:10:400);
[x, P_mesh] = meshgrid(0:0.1:1, 0:0.5:5);


%% calculate parameters
% define ranges
n = 11;
T_range = linspace(300, 400, n);

% calculate Antoine for water (@x=0)
ant_w = p_w(T_range);

% calculate antoine for ethanol (@x=1)
ant_e = p_e(T_range);

% plot antoine relation for pure components
plot3(zeros(1, 11), T_range, ant_w);
plot3(ones(1, 11), T_range, ant_e);

% iso-therm
iso_therm = mesh(x, 390*ones(n), P_mesh, 'FaceAlpha', 1);

% generate phase diagrams at different isotherms
for i = 1:n

  % temperature
  T_i = T_range(i);
  
  % liquidus line
  P(i, :) = p_w(T_i) + x(i, :) * (p_e(T_i) - p_w(T_i));

  % vaporous curve
  y(i, :) = x(i, :) .* p_e(T_i) ./ P(i, :);

  % plot liquidus line
  plot3(x(i, :), T_i * ones(1, 11), P(i, :), 'b');

  % plot vaporous curve
  plot3(y(i, :), T_i * ones(1, 11), P(i, :), 'r');

  
  
end

% iso-bar
iso_bar = mesh(x, T_mesh, ones(n), 'FaceAlpha', 1);

% generate phase diagram at atmospheric isobar
for i = 1:n

  x_bp(i) = (i-1)/(n-1);
  T_bp(i) = fsolve(@(T) (1 - p_e(T).*x_bp(i) - p_w(T).*(1-x_bp(i))), 350);
  y_bp(i) = p_e(T_bp(i)).*x_bp(i);
  
end

plot3(x_bp, T_bp, ones(1, 11), 'b--');
plot3(y_bp, T_bp, ones(1, 11), 'r--');


%% plot surfaces
% liquidus surface
liq_surf = surf(x, T_mesh, P);
liq_surf.FaceAlpha = 0.5;
liq_surf.LineStyle = 'none';
liq_surf.FaceColor = 'blue';

% vaporus surface
vap_surf = surf(y, T_mesh, P);
vap_surf.FaceAlpha = 0.5;
vap_surf.LineStyle = 'none';
vap_surf.FaceColor = 'red';
