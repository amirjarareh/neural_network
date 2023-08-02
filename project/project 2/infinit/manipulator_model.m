function state=manipulator_model(t,x,T)
% Robot system Parameters : 
l1 = 0.6;
l2 = 0.4;
m1 = 3;
m2 = 2;
g = 9.81;

% calculate [q;qdot]
state=zeros(4,1);

M=[l1^2*(m1+m2)+l2^2*m2+2*l1*l2*m2*cos(x(2))  l2^2*m2+l1*l2*m2*cos(x(2));
   l2^2*m2+l1*l2*m2*cos(x(2))                 l2^2*m2];

C=[-m2*l1*l2*sin(x(2))*x(4)^2-2*m2*l1*l2*sin(x(2))*x(3)*x(4);
    m2*l1*l2*sin(x(2))*x(3)^2];

G=[m2*l2*g*cos(x(1)+x(2))+(m1+m2)*l1*g*cos(x(1));
    m2*l2*g*cos(x(1)+x(2))];
Equation = M\(T-C-G);

state(1)=x(3) ;
state(2)=x(4) ;
state(3)=Equation(1,1);
state(4)=Equation(2,1) ;

end
