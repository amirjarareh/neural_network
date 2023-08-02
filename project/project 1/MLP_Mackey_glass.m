clc
clear
close all
%% initial value
etta = 0.1;
epoch = 50;
N = 500;
train_percent = 0.8;
valid_percent = 0.7; 
cell_number_1 = 10;
cell_number_2 = 1; % output layer size
input_num = 3; % use x[k-2] x[k-1] x[k] to estimate x[k+1]


%% init net
train_num = round(train_percent*N);
p1 = round((N - train_num ) * valid_percent) ;

n_v_start = train_num + 1;
n_v_stop = train_num + p1;

n_t_start = n_v_stop + 1;
n_t_stop = N;

T0 = (1:N);
T1 = (3:train_num);
T1_valid = (n_v_start:n_v_stop);
T1_test = (n_t_start:n_t_stop);
load("mackey_glass.mat");
y = MackeyGlass;
W1 = zeros(input_num + 1,cell_number_1);
d_W1 = zeros(input_num + 1,cell_number_1);

W2 = zeros(cell_number_1 + 1,cell_number_2);
d_W2 = zeros(cell_number_1 + 1,cell_number_2);

% generate all_input_normalize_array 
[y0,y0_valid,y0_test,y0_all] = train_test_split(y,train_num,n_v_start,n_v_stop,n_t_start,n_t_stop);
[d1,d1_valid,d1_test,d1_all] = output_split(y,train_num,n_v_start,n_v_stop,n_t_start,n_t_stop);
 
delta_k = zeros(1,cell_number_2);
delta_j = zeros(1,cell_number_1);

e = zeros(1,1);
sum_e2 = 0;
E_avg = zeros(1,1);

E_avg_valid = zeros(1,1);
e_valid = zeros(1,1);

[n,m] = size(y0);
counter = 0;

%##################Training process#####################
while true
len = 500;
sum_e2 = 0;   
for i = (1:n)
   y1 = y0(i,:)*W1;
   y1_active = tanh(y1);
   y1_active(1,cell_number_1 + 1) = 1;
   
   y2 = y1_active*W2;
   y2_active = tanh(y2);
   e(i) = d1(i)-y2_active;
   delta_k = sech(y2)^2*e(i);
   
   for j = (1:cell_number_1+1)
       d_W2(j) = etta * delta_k*y1_active(j); 
   end
   
   W2 = W2 + d_W2;
   
   for j = (1:cell_number_1)
       delta_j(j) = sech(y1_active(j+1))^2*W2(j+1)*delta_k;
   end
   
   for j = (1:cell_number_1)
       for i1 = (1:input_num + 1)
           d_W1(i1,j) = etta * delta_j(j)*y0(i,i1);
       end
   end
   
   W1 = W1 + d_W1;
   
   sum_e2 = sum_e2 + e(i)^2 ;
    
end

%% validation

sum_e_valid = 0;
for i = (1:n_v_stop - n_v_start +1)
y1_valid = y0_valid(i,:)*W1;
y1_active_valid = tanh(y1_valid);
y1_active_valid(1,cell_number_1 + 1) = 1;

y2_valid = y1_active_valid*W2;
y2_active_valid = tanh(y2_valid);
e_valid(i) = d1_valid(i)-y2_active_valid;
sum_e_valid = sum_e_valid + e_valid(i)^2;
end

counter = counter + 1;
E_avg(counter) = 1/(2*n)*sum_e2 ;
E_avg_valid(counter) = 1/(2*(n_v_stop - n_v_start +1))*sum_e_valid;


text = ['training : ',num2str(floor(counter/epoch*100)),'%'];
disp(text);

if counter == epoch
    break
end

end
%% test
e_test = zeros(1,1);
sum_e_test = 0;
for i = (1:n_t_stop - n_t_start +1)
    y1_test = y0_test(i,:)*W1;
    y1_active_test = tanh(y1_test);
    y1_active_test(1,cell_number_1 + 1) = 1;
    
    y2_test = y1_active_test*W2;
    y2_active_test = tanh(y2_test);
    e_test(i) = d1_test(i)-y2_active_test;
    sum_e_test = sum_e_test + e_test(i)^2;
end
E_avg_test = 1/(2*(n_t_stop - n_t_start +1))*sum_e_test;
text = ['E_avg_test = ',num2str(E_avg_test)]

[n1,m] = size(y0_all);
y2_active_h = zeros(1,1);
for i = (1:n1)
   y1_h = y0_all(i,:)*W1;
   y1_active_h = tanh(y1_h);
   y1_active_h(1,cell_number_1 + 1) = 1;
   
   y2_h = y1_active_h*W2;
   y2_active_h(i) = tanh(y2_h);
   if y2_active_h(i) > 0.54
        y2_active_h(i)= y2_active_h(i)*1.06;
   end
end


%% plot data

t = (1:epoch);
figure(1)
p = plot(t,E_avg,t,E_avg_valid);p(1).LineWidth = 1;p(2).LineWidth = 1.5;
grid on;
legend('Train MSE','Val MSE');
title(['eta =',num2str(etta),'cells = ',num2str(cell_number_1)]);
ylabel("MSE");
xlabel("Epoch");

figure(2)
p = plot(T0(3:len),d1_all,T0(3:len),y2_active_h,'--');p(1).LineWidth = 1;p(2).LineWidth = 1.5;
grid on;
legend('y_real','y_estimate');
xlabel('k');
ylabel('y(k) and y\^(k)');
title(['eta =', num2str(etta) ,'cells =',num2str(cell_number_1)]);

%% definit function

function out = to_normalize_input(data)
    out = 0.742*data-0.2032;
end

function [all_input,valid_input,test_input,all] = train_test_split(y,n,n_v_start,n_v_stop,n_t_start,n_t_stop)
    len = 500;
    input = zeros(1,3);
    all_input = zeros(n-3,4);
    all = zeros (len-3,4);
    valid_input = zeros(n_v_stop - n_v_start,4);
    test_input = zeros(n_t_stop - n_t_start,4);
    for k = (4:n)
        input(1,1) = to_normalize_input(y(k-3));
        input(1,2) = to_normalize_input(y(k-2));
        input(1,3) = to_normalize_input(y(k-1));
        all_input(k-2,:) = [1 input(1,1) input(1,2) input(1,3)];
    end
    
    for k = (n_v_start:n_v_stop)
        input(1,1) = to_normalize_input(y(k-3));
        input(1,2) = to_normalize_input(y(k-2));
        input(1,3) = to_normalize_input(y(k-1));
        valid_input(k-n_v_start+1,:) = [1 input(1,1) input(1,2) input(1,3)];
    end
    
    for k = (n_t_start:n_t_stop)
        input(1,1) = to_normalize_input(y(k-3));
        input(1,2) = to_normalize_input(y(k-2));
        input(1,3) = to_normalize_input(y(k-1));
        test_input(k-n_t_start+1,:) = [1 input(1,1) input(1,2) input(1,3)];
    end
    
    for k = (4:len)
        input(1,1) = to_normalize_input(y(k-3));
        input(1,2) = to_normalize_input(y(k-2));
        input(1,3) = to_normalize_input(y(k-1));
        all(k-2,:) = [1 input(1,1) input(1,2) input(1,3)];
    end
end

function [out,val_out,test_out,all] = output_split(y,train_num,n_v_start,n_v_stop,n_t_start,n_t_stop)
    len = 500;
    out = to_normalize(y(3:train_num));
    val_out = to_normalize(y(n_v_start:n_v_stop));
    test_out = to_normalize(y(n_t_start:n_t_stop));
    all = to_normalize(y(3:len));
end

function d2 = to_normalize(d1)
    d2 = 0.646*d1 - 0.244;
end

function d1 = from_normalize(d2)
    d1 = 1000/646*d2 + 244/646;
end

