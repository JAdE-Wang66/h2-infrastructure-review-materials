% 设定参数  
c_base = 15000;  
b_l = 3000; % 这是常数，代表 b 的 L 次方  
  
% 创建 b_j 的取值范围  
b_j = linspace(500, 3000, 500); % 生成500个点以平滑曲线  
  
% 计算对应的 c_j 值  
c_j = c_base * exp((b_l - b_j) ./ (4 * b_j)); % 注意这里没有使用 b^L，而是 b_l  
  
% 绘制图像  
figure; % 创建一个新的图形窗口  
plot(b_j, c_j, 'LineWidth', 2); % 绘制曲线，设置线宽为2  
xlabel('b_j'); % x轴标签  
ylabel('c_j'); % y轴标签  
title('Function c_j = c_base * exp((b_l - b_j) / (4 * b_j))'); % 标题  
grid on; % 打开网格线  
  
% 显示图像