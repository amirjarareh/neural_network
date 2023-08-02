%% Neural Network Controller Program

%% Scale & Offset for input
 % First Input
if counter>1
     high=max(q_ref,pre_qref);
     low=min(q_ref,pre_qref);
     
    max_q=max(q(1),pre_q(1));
    min_q=min(q(1),pre_q(1));
    s_in=(high(1)-low(1))/(max_q-min_q);
    o_in=(max_q*low(1)-min_q*high(1))/(max_q-min_q);
    q(1)=s_in*q(1)+o_in;

% Second Input
    max_q=max(q(2),pre_q(2));
    min_q=min(q(2),pre_q(2));
    s_in=(high(2)-low(2))/(max_q-min_q);
    o_in=(max_q*low(2)-min_q*high(2))/(max_q-min_q);
    q(2)=s_in*q(2)+o_in;

% Third Input 
    high=max(qdot_ref,pre_qdot_ref);
    low=min(qdot_ref,pre_qdot_ref);
    max_q=max(qdot(1),pre_qdotc(1));
    min_q=min(qdot(1),pre_qdotc(1));
    s_in=(high(1)-low(1))/(max_q-min_q);
    o_in=(max_q*low(1)-min_q*high(1))/(max_q-min_q);
    qdot(1)=s_in*qdot(1)+o_in;
% Fourth Input    
    max_q=max(qdot(2),pre_qdotc(2));
    min_q=min(qdot(2),pre_qdotc(2));
    s_in=(high(2)-low(2))/(max_q-min_q);
    o_in=(max_q*low(2)-min_q*high(2))/(max_q-min_q);
    qdot(2)=s_in*qdot(2)+o_in;

end
% -------------- END of Preventing Input Saturation
% Torque
pre_T=T;
% pre_Torq=Torq;
% phiJPrime_cont=zeros(Controller_Hidden_Layer,1);
input_cont=[q_ref;qdot_ref;qdot];
VJ_cont=Controller_Hidden_Layer_Weight*input_cont+Controller_Bias_Hidden_Layer ; % 10*1
YJ_cont=phi(VJ_cont) ; % 10*1
VK_cont=Controller_Output_Layer_Weight*YJ_cont+Controller_Bias_Output_Layer; % 3*1
T=VK_cont ; % 3*1
% yh=tansig(Controller_Hidden_Layer_Weight*input_cont+Controller_Bias_Hidden_Layer);
% T=(Controller_Output_Layer_Weight*yh+Controller_Bias_Output_Layer);
e=q_ref-q;

dif_q_T = 1;

for j=1:Controller_Hidden_Layer
    phiJPrime_cont(j,1)=(1-YJ_cont(j,1)*YJ_cont(j,1));
end

deltao=(e'*dif_q_T)';
deltah=(deltao'*Controller_Output_Layer_Weight)'.*phiJPrime_cont;

Dwo=Controller_Etha*deltao*YJ_cont';
Dwh=Controller_Etha*deltah*input_cont';

Controller_Output_Layer_Weight=Controller_Output_Layer_Weight+Dwo;
Controller_Hidden_Layer_Weight=Controller_Hidden_Layer_Weight+Dwh;

Dwob=Controller_Etha*deltao;
Dwhb=Controller_Etha*deltah;

Controller_Bias_Output_Layer=Controller_Bias_Output_Layer+Dwob;
Controller_Bias_Hidden_Layer=Controller_Bias_Hidden_Layer+Dwhb;

for p=1:2
    error_cont(p,counter)=mse(e(p));
end

% Scale & Offset for output
if T(1,1)>1
    T(1,1)=1;
end
if T(1,1)<-1
    T(1,1)=-1;
end
if T(2,1)>1
    T(1,1)=1;
end
if T(2,1)<-1
    T(1,1)=-1;
end
pre_qref=q_ref;
pre_qdot_ref=qdot_ref;
pre_q=q;
pre_qdotc=qdot;