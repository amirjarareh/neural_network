% Plotting Q Qref
figure(1)
grid on
hold on
plot(All_q(1,:),All_q(2,:),'b','linewidth',1);
hold on
plot(All_q_Reference(1,:),All_q_Reference(2,:),'r--','linewidth',1.5);
legend('Controller Trajectory' ,'Reference Trajectory');
% plotting the  X and Y and Theta
Tim=0:sample_time:SimulationTime ;


figure(2)
grid on
subplot(2,1,1)
hold all
plot(Tim,All_q_Reference(1,:),'r--','linewidth',1.5)
plot(Tim,All_q(1,:),'b','linewidth',1)
legend('Reference Trajectory','Controller Trajectory');
grid on
subplot(2,1,2)
hold on
plot(Tim,All_q_Reference(2,:),'r--','linewidth',1.5)
plot(Tim,All_q(2,:),'b','linewidth',1)
legend('Reference Trajectory','Controller Trajectory');
grid on

% Plotting Error 
Error_All_Controlled = All_q_Reference - All_q ;
Cost_Controlled = 0.5* (Error_All_Controlled.*Error_All_Controlled) ; 


figure(3)
grid on
subplot(2,1,1)
hold on
plot(Tim,Cost_Controlled(1,:),'b','linewidth',1)
legend('Controller X Error')
grid on
subplot(2,1,2)
hold on
plot(Tim,Cost_Controlled(2,:),'b','linewidth',1)
legend('Controller Y Error')
grid on

figure(4)
subplot(2,1,1)
plot(Tim,All_T(1,:),'b','linewidth',1)
legend('Torque Applied Joint l1')
grid on
subplot(2,1,2)
plot(Tim,All_T(1,:),'b','linewidth',1)
legend('Torque Applied Joint l2')
grid on


figure(6)
subplot(2,1,1)
plot(Tim,All_theta(1,:),'b','linewidth',1)
legend('theta 1')
grid on
subplot(2,1,2)
plot(Tim,All_theta(2,:),'b','linewidth',1)
legend('theta 2')
grid on
