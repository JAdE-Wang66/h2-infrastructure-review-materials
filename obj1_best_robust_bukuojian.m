function [final_result,final_result2,final_result3,need] = obj1_best_robust()
% D_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2023年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% % D_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2024年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
% %     'C2:KM321');
% D_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2025年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% D_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2026年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% D_list(:,:,3) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2027年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% D_list(:,:,4) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2028年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% D_list(:,:,5) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2029年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
D_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2030年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
%需求列向量,单位为Kg
% Xvqiu_xiaoqu_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2023年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2024年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2025年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2026年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,3) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2027年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,4) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2028年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,5) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2029年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2030年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');

Xvqiu_xiaoqu_list = Xvqiu_xiaoqu_list * 0.95; %最理想情景

% 百公里耗氢量，目标最优最差集合
hund_cosume_list = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\预测结果.xlsx',...
    'K29:P29');


[m,n] = size(D_list(:,:,1)); %需求点的数量为m，加油站的数量为n
price_hydro = 50;%氢气价格，元/kg
e1 = 0.02724865;
e2 = 0.0133200051985;
e = e1 - e2; %e指碳减排系数

len = 1;
for i = 1:1
    disc_rate(1,i)=1/power((1+0.08),i-1);%贴现率
end
%% 多目标鲁棒优化开始
% %自变量定义
% x = sdpvar(n,m,len); %第j需求点在i备选加氢站被满足的加氢量
% on_or_not = binvar(n,len); %第j个加油站是否要改建，二进制变量
% BH = sdpvar(n,len);%第j个油氢合建站的容量
% BH_temp_=0;
% on_or_not_temp_=0;
% OBJ1 = 0;
% OBJ2 = 0;
% OBJ3 = 0;
% b_up = 800;
% b_low = 300;
% C = []; 
%% 多目标鲁棒优化开始
%自变量定义
x = sdpvar(n,m,len); %第j需求点在i备选加氢站被满足的加氢量
on_or_not = binvar(n,len); %第j个加油站是否要改建，二进制变量
% BH = intvar(n,len);%第j个油氢合建站的容量
int = intvar(n,len);
BH = 500*int;
BH_temp_=0;
on_or_not_temp_=0;
OBJ1 = 0;
OBJ2 = 0;
OBJ3 = 0;
b_up = 3000;
b_low =500;
C = [];
%% 各单目标最优值确定
for i = 1:len
    D = D_list(:,:,i);
    D = D'; %转置
    Xvqiu_xiaoqu = Xvqiu_xiaoqu_list(:,:,i);
    Xvqiu_xiaoqu = Xvqiu_xiaoqu';
    average_load = mean(mean(Xvqiu_xiaoqu));
    hund_cosume = hund_cosume_list(i); %第k年平均车型百公里耗氢量
    u = Xvqiu_xiaoqu;       %第i需求点的总氢需求量
    %% 自变量读取
    x_temp = x(:,:,i);
    on_or_not_temp = on_or_not(:,i);
    BH_temp = BH(:,i);
    %% 产销平衡约束
    %COBH可表述为
    C=[C,x_temp>=0];
    %productionbalance可表述为
    C=[C,sum(x_temp,1)==u];
    %COBH可表述为
    C=[C,sum(x_temp,2)<=BH_temp];
    C=[C,BH_temp<=b_up*on_or_not_temp];
    C=[C,BH_temp>=b_low*on_or_not_temp];
    %% 优化目标：多目标最优，参数构造
    %优化目标1 总建设成本本最小，参数构造
    z = [500,3000];
    y = exp((500-z) ./ (4*z)) .* z * 1.5; %单位 万元
    a = (max(y) - min(y)) / 2500;
    b = min(y) - 500 * a;
    %优化目标2 总购氢成本最小
    Price_journey = D.*hund_cosume*price_hydro/(100*average_load);
    %优化目标3：超供氢需求最大
    Price_sum_BH = - e ;
    %优化目标值计算
    OBJ1_tem = a*BH_temp+on_or_not_temp*b;%当前容量对应的总建设成本
    OBJ1_temp = OBJ1_tem - a*BH_temp_-on_or_not_temp_*b;%第一年时为建设成本；后年则为扩建成本
    OBJ1 = OBJ1 + sum(OBJ1_tem*0.03+OBJ1_temp)*disc_rate(1,i); %年运维+投入成本，并贴现
    OBJ2 = OBJ2 + sum(sum(Price_journey.*x_temp));
    OBJ3 = OBJ3 + sum(Price_sum_BH*BH_temp);
    BH_temp_=BH_temp;
    on_or_not_temp_=on_or_not_temp;
end
obj_temp = OBJ1;
%年间只允许扩建约束
% for i = 2:len
%     C=[C,BH(:,i)-BH(:,i-1)>=0];
% end
%调用cplex参数设置
ops = sdpsettings('solver' ,'cplex','verbose',2);
ops.cplex.mip.tolerances.mipgap = 0.1;
% ops=sdpsettings('solver','cplex');
Constraint = C;%约束汇总
% ops.cplex.timelimit = 7200;
result = optimize(Constraint,obj_temp,ops);%调用cplex参数设置
wao_robust = zeros(1,3);
if result.problem ~=1
    on_or_not = value(on_or_not);
    x = value(x);
    true_BH = value(BH);
    OBJ1_robust = value(OBJ1);
    OBJ2_robust = value(OBJ2);
    OBJ3_robust = -value(OBJ3);
    OBJ_robust = [OBJ1_robust;OBJ2_robust;OBJ3_robust];
else
    OBJ_robust = Inf;%未得到最优解，则输出Inf，无穷大
end
final_result = OBJ_robust;
final_result2 = true_BH;
final_result3 = x;
need = zeros(1, 1);
for i = 1:1
    need(i) = sum(Xvqiu_xiaoqu_list(:,:,i), 'all');
end
end
