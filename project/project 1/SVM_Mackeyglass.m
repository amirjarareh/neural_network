clc
clear
close all


%% hyperparam
N = 500;
train_percent = 0.8;
kernel = "rbf"; % rbf or linear

%%
load('mackey_glass.mat')
y = MackeyGlass';
N_Train = N*train_percent;
% Calculate the minimum and maximum value of the set
min_number = min(y);
max_number = max(y);
% Normalize the set
y = mapminmax(y, 0, 1);


%%
X = [y(1:N_Train-2)' y(2:N_Train-1)']; % x[k-1] x[k] and current data
Y = y(3:N_Train)'; % x[k+1] data as label


%% select kernel
if kernel == "rbf"
    % RBF Kernel
    gamma = 0.1; % RBF kernel width controller parameter
    distances = pdist2(X, X, 'euclidean');
    K = exp(-gamma * distances.^2);

elseif kernel == "linear"
    % Creating kernel matrix with linear kernel
    K = X*X';
end

%% 

H = (Y'*Y) .* K;
f = -ones(size(Y));
A = [];
b = [];
Aeq = Y';
beq = 0;
lb = zeros(size(Y));
ub = ones(size(Y)) .* (1/size(Y,1));

% Solving the optimization problem
alpha = quadprog(H, f, A, b, Aeq, beq, lb, ub);

% Calculate W
W = (alpha .* Y') * X;

% Calculate and predict data
xTest = [y(1:end-2)' y(2:end-1)']; % Current and previous moment data
yPred = xTest * W'; % Multiply the data by the obtained W
yPred = max(yPred, [], 2); % Extracting the maximum element of each row
yPred = mapminmax(yPred', 0, 1)';
%%
yPred = mapminmax(yPred', min_number, max_number)';
y = mapminmax(y, min_number, max_number);
y = y(2:end-1);
t = 2:1:N-1;
%%
% Resualts
MSE = mse(yPred,y)

%% plot
title("Sunspot with SVM")
plot(t, y, t, yPred,"r--",'LineWidth',1.5)
legend("y_real","y_estimate")
xlabel('k');
ylabel('y(k) and y\^(k)');