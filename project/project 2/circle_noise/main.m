%% Clearing Existing Data
clc
clear all
close all

%% Robot system Parameters : 
l1 = 0.6;
l2 = 0.4;
m1 = 3;
m2 = 2;
g = 9.81;

%% Simulation parameters 
sample_time=0.03;       % Reducing the sample time can cause higher CPU usage
SimulationTime=6.5;     % Change this if you want to change the simulation duration
counter=0;

%% Initial state and
theta=[0,0];     %Change This if you want the robot to start from special location
theta_dot=[0,0]; %Change This if you want the robot to start from special location
T=[0 0]';               % This is used to solve the ODE for the stationary(initial Point)
[q ,qdot] = forward_kinematics(theta,theta_dot,sample_time);


%% Parameters of the Circular Trajectory
a=0.5;       % Circle Center in meters  (X Axis)
c=0.4;       % Circle Center in meters (Y Axis)
b=0.3;       % Radius in meters
d=0.2;

%% Data for Neural Network Controller
Controller_Input_layer=6;
Controller_Hidden_Layer=4;
Controller_Output_Layer=2;
Controller_Etha=0.1;

%% Dont Change Anything Here ( This part Contains data about Controller Layers )
Controller_Hidden_Layer_Weight=rand(Controller_Hidden_Layer,Controller_Input_layer);
Controller_Bias_Hidden_Layer=rand(Controller_Hidden_Layer,1);
Controller_Output_Layer_Weight=rand(Controller_Output_Layer,Controller_Hidden_Layer);
Controller_Bias_Output_Layer=rand(Controller_Output_Layer,1);


%% Desired Trajectory ( You can Change The Desired Trajectory )
t=0:sample_time:SimulationTime;
q_ref=[a+b*cos(t'),c+d*sin(t')]';

%% Finding The Nearest Point From Initial point and Trajectory
% If you dont Want to Consider This You can Comment it and set the 
% s_t= * what ever you want ; 
for i=1:length(t)
    error_q=q_ref(:,i)-q;
    distance(i,1)=norm(error_q);
end
nearest=min(distance);
for i=1:length(t)
    if distance(i)==nearest
        s_t=sample_time*(i-1);
    end
end
% s_t=0;


data = [];
%% Main Program This Loop Will Identify The Trajectory of Robot and Control 
tic
for t=s_t:sample_time:SimulationTime+s_t
    
    counter=counter+1;
    
    % Here next reference  data will be Calculated Each Sample 
    q_ref=[a+b*cos(t),c+d*sin(t)]';
    qdot_ref=[-b*sin(t),d*cos(t)]';
    
    %% Controller Uses the inputs and dq/dT ( Sensitivity ) to Calculate 
    % the Desired T to control the Robot
    Neural_Controller
    
    %% Calculating The Output of Robot with updated Data
    [theta,theta_dot] = inverse_kinematics(q,qdot,sample_time);
    [t,x]=ode113(@(t,x) manipulator_model(t,x,T),sample_time*[counter-1 counter],[theta;theta_dot]);
    theta=[x(length(t),1) x(length(t),2)]';      % New data
    theta_dot=[x(length(t),3) x(length(t),4)]';   % New dot data
    
    %% add noise in system 
    t1_noise = theta(1) + 0.01*sin(counter/20);
    t2_noise = theta(2) + 0.01*cos(counter/20);
    theta = [t1_noise t2_noise]';

    [q,qdot] = forward_kinematics(theta,theta_dot,sample_time);
    q_joint_l1 = forward_first_joint(theta) ;

    %% online plot
    %plot result
%     figure(5)
%     hold on
%     plot(q_ref(1),q_ref(2),'r.','linewidth',1)
%     plot(q(1),q(2),'go','linewidth',1)
%     plot(q_joint_l1(1),q_joint_l1(2),'bo','linewidth',1)
%     legend('Reference Path','joint l2 xy','joint l1 xy');

    %% Saving Data in every Loop Iteration
    All_theta(:,counter)=theta;
    All_theta_dot(:,counter)=theta_dot;

    All_q_Reference(:,counter)=q_ref;
    All_q(:,counter)=q;
    All_qdot(:,counter)=qdot;
    
    All_T(:,counter)=T;

end
toc 
%% Plotting the Desired Data
PlottingTool





