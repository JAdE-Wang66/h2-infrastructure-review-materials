function [final_result,final_result2,final_result3,need] = obj1_best_sce3()
% D_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2023年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
% D_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2024年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'C2:KM321');
D_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2025年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
D_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2026年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
D_list(:,:,3) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2027年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
D_list(:,:,4) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2028年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
D_list(:,:,5) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2029年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
D_list(:,:,6) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2030年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'C2:KM321');
%需求列向量,单位为Kg
% Xvqiu_xiaoqu_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2023年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
% Xvqiu_xiaoqu_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2024年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
%     'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,1) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2025年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,2) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2026年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,3) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2027年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,4) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2028年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,5) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2029年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');
Xvqiu_xiaoqu_list(:,:,6) = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\2030年\步骤3 - 计算网格化需求中心点与加油站距离.xlsx',...
    'KO2:KO321');

Xvqiu_xiaoqu_list = Xvqiu_xiaoqu_list * 0.95; %最理想情景

% 百公里耗氢量，目标最优最差集合
hund_cosume_list = xlsread('D:\Desktop\氢能重卡\爬虫\最终结果\预测结果.xlsx',...
    'k29:P29');


[m,n] = size(D_list(:,:,1)); %需求点的数量为m，加油站的数量为n
price_hydro = 50;%氢气价格，元/kg
e1 = 0.02724865;
e2 = 0.0133200051985;
e = e1 - e2; %e指碳减排系数
len = 6;
for i = 1:6
    disc_rate(1,i)=1/power((1+0.08),i-1);%贴现率
end

%% 多目标鲁棒优化开始
%自变量定义
x = sdpvar(n,m,len); %第j需求点在i备选加氢站被满足的加氢量
% BH_mid = sdpvar(n,len); %第j个中型油氢合建站的容量
% BH_large = sdpvar(n,len); %第j个大型油氢合建站的容量
int_mid = intvar(n,len);
int_large = intvar(n,len);
BH_mid = 500*int_mid;
BH_large = 500*int_large;
on_mid = binvar(n,len); %第j个加油站是否要改建为中型油氢合建站，二进制变量
on_large = binvar(n,len); %第j个加油站是否要改建为大型油氢合建站，二进制变量
subsidy_mid_every_year = sdpvar(n,len);%各年的中型油氢合建站的补贴
subsidy_large_every_year = sdpvar(n,len);%各年的大型油氢合建站的补贴
more_or_less = binvar(n,len);%判断累计补贴是否超过当年补贴的上限，0为超过，1为未超过
subsidy_mid = 0;%中型油氢合建站累计总补贴
subsidy_large = 0;%大型油氢合建站累计总补贴
OBJ1 = 0;
OBJ2 = 0;
OBJ3 = 0;
BH_mid_temp_ = 0;%前一年的中型油氢合建站装机容量
on_mid_temp_ = 0;
BH_large_temp_ = 0;%前一年的大型油氢合建站装机容量
on_large_temp_ = 0;
b_up = 3000;%大型加氢站的容量上限
b_mid = 2000;%中型加氢站的容量上限；大型加氢站的容量下限
b_low = 500;%中型加氢站的容量下限
sub_rate_mid=0.3;%中型加氢站的补贴比例
sub_max_mid=[200;150;100;50;0;0;];%中型加氢站的补贴上限
sub_rate_large=0.3;%大型加氢站的补贴比例
sub_max_large=[500;400;300;200;100;0];%大型加氢站的补贴上限
subsidy=zeros(n,1);
sub_mid_tem=0;
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
    BH_mid_temp = BH_mid(:,i);
    BH_large_temp = BH_large(:,i);
    on_mid_temp = on_mid(:,i);
    on_large_temp = on_large(:,i);
    more_or_less_temp = more_or_less(:,i);
    %% 产销平衡约束
    %COBH可表述为
    C=[C,x_temp>=0];
    %productionbalance可表述为
    C=[C,sum(x_temp,1)==u];%供需平衡
    %COBH可表述为
    C=[C,on_mid_temp+on_large_temp<=ones(n,1)];%一个加油站只能改建为一个油氢合建站
    C=[C,BH_mid_temp<=(b_mid-0.00000001)*on_mid_temp];%中型油氢合建站装机容量为300<=,<500;
    C=[C,BH_mid_temp>=b_low*on_mid_temp];
    C=[C,BH_large_temp<=b_up*on_large_temp];%大型油氢合建站装机容量为500-800
    C=[C,BH_large_temp>=b_mid*on_large_temp];
    C=[C,sum(x_temp,2)<=BH_mid_temp+BH_large_temp]; %j加氢站的需求小于总容量
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
    OBJ1_mid_tem=a*BH_mid_temp+on_mid_temp*b;%当前容量对应的总建设成本
    OBJ1_large_tem=a*BH_large_temp+on_large_temp*b;
    OBJ1_mid_temp=OBJ1_mid_tem-(a*BH_mid_temp_+on_mid_temp_*b); %第一年时为建设成本；后年则为扩建成本
    OBJ1_large_temp=OBJ1_large_tem-(a*BH_large_temp_+on_large_temp_*b);
    subsidy_mid_temp=subsidy_mid_every_year(:,i); %第j个中型油氢合建站的当年应获装机补贴
    subsidy_large_temp=subsidy_large_every_year(:,i); %第j个大型油氢合建站的当年应获装机补贴
    C=[C,subsidy_large_temp>=0];%补贴大于0
    C=[C,subsidy_mid_temp<=OBJ1_mid_temp*sub_rate_mid];%按比例补贴
    C=[C,subsidy_large_temp<=OBJ1_large_temp*sub_rate_large];
    subsidy_temp=subsidy_large_temp+subsidy_mid_temp;%当期补贴
    sub_max=sub_max_large(i,1)*on_large_temp+sub_max_mid(i,1)*on_mid_temp;%当年对应机组累计装机补贴上限
    for j = 1:n
        %标志为0，则在不计入当年补贴时，累计补贴已超过当年补贴上限，则当年补贴=0
        C=[C,implies(more_or_less_temp(j,1)==0,[subsidy(j,1)>=sub_max(j,1)])];
        C=[C,implies(more_or_less_temp(j,1)==0,[subsidy_temp(j,1)<=0])];
        %标志为1，则在不计入当年补贴时，累计补贴未超过当年补贴上限，则当年补贴最大值为差额
        C=[C,implies(more_or_less_temp(j,1)==1,[subsidy(j,1)<=sub_max(j,1)])];
        C=[C,implies(more_or_less_temp(j,1)==1,[subsidy_temp(j,1)<=sub_max(j,1)-subsidy(j,1)])];
    end
    subsidy=subsidy+subsidy_temp;%累计装机补贴
    sub_mid_tem=subsidy_mid_temp+sub_mid_tem;%中级累计补贴
    C=[C,sub_mid_tem>=0];
    OBJ1_mid_true_temp=OBJ1_mid_temp-subsidy_mid_temp;%考虑当年补贴后，当年实际投入建设、扩建成本
    OBJ1_large_true_temp=OBJ1_large_temp-subsidy_large_temp;
    OBJ1 = OBJ1 + disc_rate(1,i) * sum((OBJ1_mid_tem+OBJ1_large_tem)*0.03 + (OBJ1_mid_true_temp+OBJ1_large_true_temp)); %年运维成本+实际投入成本年金）*贴现率
    OBJ2 = OBJ2 + sum(sum(Price_journey.*x_temp));
    OBJ3 = OBJ3 + sum(Price_sum_BH*(BH_mid_temp+BH_large_temp));
    %信息迭代
    BH_mid_temp_ = BH_mid_temp;
    on_mid_temp_ = on_mid_temp;
    BH_large_temp_ = BH_large_temp;
    on_large_temp_ = on_large_temp;
end
obj_temp = OBJ1;
%年间只允许扩建约束
BH = BH_mid + BH_large;
C=[C,BH<=b_up];
for i = 2:len
    C=[C,BH_large(:,i)-BH_large(:,i-1)>=0];
    C=[C,BH(:,i)-BH(:,i-1)>=0];
end
%调用cplex参数设置
ops = sdpsettings('solver' ,'cplex','verbose',2);
ops.cplex.mip.tolerances.mipgap = 0.15;
% ops=sdpsettings('solver','cplex');
Constraint = C;%约束汇总
% ops.cplex.timelimit = 7200;
result = optimize(Constraint,obj_temp,ops);%调用cplex参数设置
wao_robust = zeros(1,3);
if result.problem ~=1
    x = value(x);
    on_large = value(on_large);
    on_mid = value(on_mid);
    true_BH_mid = value(BH_mid);
    true_BH_large = value(BH_large);
    true_BH = value(BH);
    subsidy_mid_every_year = value(subsidy_mid_every_year);
    subsidy_large_every_year = value(subsidy_large_every_year);
    subsidy_every=subsidy_mid_every_year+subsidy_large_every_year;
    for i =1:len
        sub_max_every(1:n,i)=sub_max_mid(i,1)*on_mid(:,i)+sub_max_large(i,1)*on_large(:,i);
    end
    subsidy_sumcol=cumsum(subsidy_every,2);
    more_or_less=value(more_or_less);
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
need = zeros(1, 6);
for i = 1:6
    need(i) = sum(Xvqiu_xiaoqu_list(:,:,i), 'all');
end
save('obj1_sce3_all');
end

