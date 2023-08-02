clc
clear
close all
%% init rbf network
N = 305;
train_percent = 0.8;
test_percent = 1 - train_percent;
num_centers = 6; % تعداد مراکز RBF


%% init data
N_Test  = test_percent *N;
N_Train = train_percent*N;
t = linspace(1, N, N);
load('sunspot.mat')
x_data = sunspot(:,2)';
x = x_data(N_Test:N_Train+N_Test);
% تعریف ماتریس ورودی و خروجی
X = zeros(N_Train-1, 2); % ماتریس ورودی
Y = zeros(N_Train-1, 1); % ماتریس خروجی
for i = 1:N_Train-1
    X(i,:) = [x(i), x(i+1)]; % ورودی شامل لحظه فعلی و لحظه بعدی
    Y(i) = x(i+1); % خروجی متناظر با لحظه بعدی
end

%% train RBF
% آموزش مدل
centers = linspace(min(x), max(x), num_centers); % مراکز با استفاده از تابع linspace
width = (max(x)-min(x))/(num_centers-1); % پهنای تابع Gaussian در RBF
phi = zeros(N_Train-1, num_centers); % ماتریس طراحی
for i = 1:N_Train-1
    for j = 1:num_centers
        phi(i,j) = exp(-(norm(X(i,:)-centers(j))^2)/(2*width^2)); % محاسبه تابع Gaussian در RBF
    end
end
w = pinv(phi)*Y; % محاسبه وزن‌های مدل با استفاده از روش پایه تقویت شده
%% test RBF
% تست مدل RBF
x_test = x_data;
y_test = zeros(1, N);
for i = 1:N-1
    x_now = x_test(i);
    x_next = x_test(i+1);
    phi_test = zeros(1, num_centers);
    for j = 1:num_centers
        phi_test(j) = exp(-(norm([x_now, x_next]-centers(j))^2)/(2*width^2)); % محاسبه تابع Gaussian در RBF برای هر داده تست
    end
    y_test(i+1) = phi_test*w; % تخمین خروجی برای داده تست با استفاده از وزن‌های یاد
end
length(x_data)
length(t)
% رسم نمودار تخمینی سری زمانی
figure;
plot(t, x_data, 'b', 'LineWidth', 1); % خطوط آبی نشان دهنده داده های واقعی هستند
hold on;
plot(t, y_test, 'r--', 'LineWidth', 1.5); % خطوط قرمز پر تیر نشان دهنده تخمین مدل RBF هستند
xlabel('زمان');
ylabel('داده های سری زمانی');
title('مقایسه داده های واقعی با تخمین مدل RBF');
legend('داده های واقعی', 'تخمین مدل RBF');