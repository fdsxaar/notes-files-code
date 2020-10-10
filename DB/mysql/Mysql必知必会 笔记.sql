msyql必知必会

第三章

source /js/path/xx.sql;  执行全路径下的脚本
CREATE DATABASE <name>; 创建数据库
USE <name>; 使用数据库

SHOW TABLES; 显示表

show columns from customers; 显示表分列信息
describe customers; 同上

SHOW STATUS，用于显示广泛的服务器状态信息
SHOW CREATE DATABASE和SHOW CREATE TABLE，分别用来显示创建特定数据库或表的MySQL语句；
SHOW GRANTS，用来显示授予用户（所有用户或特定用户）的安全权限；
SHOW ERRORS和SHOW WARNINGS，用来显示服务器错误或警告消息。


第4 章 检 索 数 据

SELECT prod_name FROM products; 
SELECT prod_id, prod_name, prod_price FROM products;
SELECT * FROM products;

select distinct vend_id from products;  distinct 关键字

DISTINCT关键字应用于所有列
SELECT DISTINCT vend_id, prod_price，

select prod_price from products limit 5; 返回前几行
select prod_price from products limit 5,5; 返回5行，从第六行开始（mysql中第一行是0行
select prod_price from products limit 5 offset 5; 同上

select products.prod_name from products;完全限定的表名
select products.prod_name from crashcourse.products;

第5章 排序检索数据 

select prod_name from products order by prod_name; 排序输出 
select prod_id, prod_name, prod_price from products order by prod_name, prod_price; 按多列排序

默认升序排列ASC（ASCENDING）， 降序DESC；DESC关键字只应用到直接位于其前面的列名；
在给出ORDER BY子句时，应该保证它位于FROM子句之后。如果使用LIMIT，它必须位于ORDER BY之后。使用子句的次序不对将产生错误消息；
在字典（dictionary）排序顺序中，A被视为与a相同，这是MySQL（和大多数数据库管理系统）的默认行为；
select prod_id, prod_price, prod_name from products order by prod_price limit 1; 

第6章 过 滤 数 据 
在SELECT语句中，数据根据WHERE子句中指定的搜索条件进行过滤。WHERE子句在表名（FROM子句）之后给出；

WHERE子句的位置：在同时使用ORDER BY和WHERE子句时，应该让ORDER BY位于WHERE之后，否则将会产生错误

WHERE子句操作符
= 等于
<> 不等于
!= 不等于
< 小于
<= 小于等于
> 大于
>= 大于等于
BETWEEN 在指定的两个值之间 

select prod_name from products where prod_name = 'fuses'; 不区分大小写

select prod_name , prod_price from products where prod_price BETWEEN 5 and 10; between a and b 范围查询

在创建表时，表设计人员可以指定其中的列是否可以不包含值。在一个列不包含值时，称其为包含空值NULL
select cust_id from customers where cust_email is NULL; 空值检查

第7 章 数 据 过 滤 

为了进行更强的过滤控制，MySQL允许给出多个WHERE子句。这些子
句可以两种方式使用：以AND子句的方式或OR子句的方式使用

AND操作符,用在WHERE子句中的关键字，用来指示检索满足所有给定条件的行。可以添加多个过滤条件，每添加一条就要使用一个AND
select prod_id, prod_price, prod_name from products where vend_id = 1003 and prod_price <= 10; 

OR操作符,指示MySQL检索匹配任一条件的行
select prod_name, prod_price from products where vend_id = 1002 or vend_id = 1003;

计算次序：在WHERE子句中使用圆括号 任何时候使用具有AND和OR操作符的WHERE子句，都应该使用圆括号明确地分组操作符
WHERE可包含任意数目的AND和OR操作符;AND在计算次序中优先级更高
select prod_name, prod_price from products where vend_id = 1002 or vend_id = 1003 and prod_price >= 10;
加圆括号改变优先级
select prod_name, prod_price from products (where vend_id = 1002 or vend_id = 1003) and prod_price >= 10;

IN操作符用来指定条件范围，范围中的每个条件都可以进行匹配
select prod_name, prod_price from products where vend_id in (1002,1003) order by prod_price;

select prod_name, prod_price from products where vend_id = 1002 or vend_id = 1003 order by prod_price;
IN操作符完成与OR相同的功能
在使用长的合法选项清单时，IN操作符的语法更清楚且更直观。
 在使用IN时，计算的次序更容易管理（因为使用的操作符更少）。
 IN操作符一般比OR操作符清单执行更快。
 IN的最大优点是可以包含其他SELECT语句，使得能够更动态地建
立WHERE子句

NOT操作符:WHERE子句中的NOT操作符有且只有一个功能，那就是否定它之后所跟的任何条件。
select prod_name,prod_price from products where vend_id not in (1002,1003);

第 8 章 用通配符进行过滤 
LIKE是谓词而不是操作符

百分号（%）通配符:%表示任何字符出现任意次数。
select prod_id, prod_name from products where prod_name like 'jet%';

虽然似乎%通配符可以匹配任何东西，但有一个例外，即NULL。即使是WHERE prod_name LIKE '%'也不能匹配
用值NULL作为产品名的行;

下划线（_）通配符:只匹配单个字符
select prod_id, prod_name from products where prod_name like '_ ton anvil';

使用通配符要记住:
 不要过度使用通配符。如果其他操作符能达到相同的目的，应该
使用其他操作符。
 在确实需要使用通配符时，除非绝对有必要，否则不要把它们用
在搜索模式的开始处。把通配符置于搜索模式的开始处，搜索起
来是最慢的。
 仔细注意通配符的位置。如果放错地方，可能不会返回想要的数据。

第 9 章 用正则表达式进行搜索
REGEXP在列值内进行匹配，如果被匹配的文本在列值中出现，REGEXP将会找到它，相应的行将被返回;

基本字符匹配
MySQL中的正则表达式匹配（自版本3.23.4后）不区分大小写（即，大写和小写都匹配）。为区分大
小写，可使用BINARY关键字
select prod_name from products where prod_name regexp binary 'JetPack .000'; .是正则表达式语言中一个特殊
的字符。它表示匹配任意一个字符

进行OR匹配
select prod_name from products where prod_name regexp '1000|2000';

匹配几个字符之一
select prod_name from products where prod_name REGEXP '[123] Ton' order by prod_name;
[]是另一种形式的OR语句。事实上，正则表达式[123]Ton为[1|2|3]Ton的缩写
select prod_name from products where prod_name REGEXP '1|2|3 Ton' order by prod_name;
匹配的是 1 或 2 或 3 Ton

[^123]匹配除这些字符外的任何东西
select prod_name from products where prod_name REGEXP '[^123] Ton' order by prod_name;

匹配范围 [1-9] [a-z]
select prod_name from products where prod_name REGEXP '[1-9] Ton' order by prod_name;

匹配特殊字符-转义
select prod_name from products where prod_name REGEXP '\\.' order by prod_name;

\\f 换页
\\n 换行
\\r 回车
\\t 制表
\\v 纵向制表

匹配字符类
[:alnum:] 任意字母和数字（同[a-zA-Z0-9]）
[:alpha:] 任意字符（同[a-zA-Z]）
[:blank:] 空格和制表（同[\\t]）
[:cntrl:] ASCII控制字符（ASCII 0到31和127）
[:digit:] 任意数字（同[0-9]）
[:graph:] 与[:print:]相同，但不包括空格
[:lower:] 任意小写字母（同[a-z]）
[:print:] 任意可打印字符
[:punct:] 既不在[:alnum:]又不在[:cntrl:]中的任意字符
[:space:] 包括空格在内的任意空白字符（同[\\f\\n\\r\\t\\v]）
[:upper:] 任意大写字母（同[A-Z]）
[:xdigit:] 任意十六进制数字（同[a-fA-F0-9]）

匹配连在一起的4位数字
select prod_name from products where prod_name REGEXP '[[:digit:]]{4}' order by prod_name;

定位符
^ 文本的开始
$ 文本的结尾
[[:<:]] 词的开始
[[:>:]] 词的结尾
select prod_name from products where prod_name REGEXP '^[0-9\\.]' order by prod_name; 行内文本的开始处开始匹配
^匹配串的开始。因此，^[0-9\\.]只在.或任意数字为串中第一个字符时才匹配它们

^有两种用法。在集合中（用[和]定义），用它来否定该集合，否则，用来指串的开始处；

LIKE和REGEXP的不同在于，LIKE匹配整个串而REGEXP匹配子串。利用定位
符，通过用^开始每个表达式，用$结束每个表达式，可以使REGEXP的作用与LIKE一样

//测试正则表达式
select 'hello' regexp [0-9]; mysql 8.0 报错

第 10 章 创建计算字段
在MySQL的SELECT语句中，可使用Concat()函数来拼接两个列。
多数DBMS使用+或||来实现拼接，MySQL则使用Concat()函数来实现。当把SQL语句转换成
MySQL语句时一定要把这个区别铭记在心；

select Concat(vend_name, ' (', vend_country, ') ')
from vendors
order by vend_name;

RTrim()函数去掉值右边的所有空格
select Concat(RTrim(vend_name), ' (', RTrim(vend_country), ') ')
from vendors
order by vend_name;

as 别名
select Concat(vend_name, ' (', vend_country, ') ') as vend_title
from vendors
order by vend_name;

执行算术计算
select prod_id, quantity, item_price, quantity*item_price AS expanded_price 
from orderitems 
where order_num = 20005;

MySQL算术操作符:
+ 加
- 减
* 乘
/ 除

测试计算：
select 3*2;

第 11 章
使用数据处理函数:

表11-1 常用的文本处理函数
Left() 返回串左边的字符
Length() 返回串的长度
Locate() 找出串的一个子串
Lower() 将串转换为小写
LTrim() 去掉串左边的空格
Right() 返回串右边的字符
RTrim() 去掉串右边的空格
Soundex() 返回串的SOUNDEX值
SubString() 返回子串的字符
Upper() 将串转换为大写

日期和时间处理函数
AddDate() 增加一个日期（天、周等）
AddTime() 增加一个时间（时、分等）
CurDate() 返回当前日期
CurTime() 返回当前时间
Date() 返回日期时间的日期部分
DateDiff() 计算两个日期之差
Date_Add() 高度灵活的日期运算函数
Date_Format() 返回一个格式化的日期或时间串
Day() 返回一个日期的天数部分
DayOfWeek() 对于一个日期，返回对应的星期几
Hour() 返回一个时间的小时部分
Minute() 返回一个时间的分钟部分
Month() 返回一个日期的月份部分
Now() 返回当前日期和时间
Second() 返回一个时间的秒部分
Time() 返回一个日期时间的时间部分
Year() 返回一个日期的年份部分

不管是插入或更新表值还是用WHERE子句进行过滤，日期必须为
格式yyyy-mm-dd

如果你想要的仅是日期，
则使用Date()是一个良好的习惯，即使你知道相应的列只包
含日期也是如此。这样，如果由于某种原因表中以后有日期和
时间值，你的SQL代码也不用改变。当然，也存在一个Time()
函数，在你只想要时间时应该使用它
select cust_id, order_num 
from orders 
where Date(order_date) = '2005-09-01';

检索出2005年9月下的所有订单:
select cust_id, order_num 
from orders 
where Date(order_date) between '2005-09-01' and '2005-09-30';

select cust_id, order_num 
from orders 
where Year(order_date) = 2005 and Month(order_date)=9;

数值处理函数
Abs() 返回一个数的绝对值
Cos() 返回一个角度的余弦
Exp() 返回一个数的指数值
Mod() 返回除操作的余数
Pi() 返回圆周率
Rand() 返回一个随机数
Sin() 返回一个角度的正弦
Sqrt() 返回一个数的平方根
Tan() 返回一个角度的正切

第12 章汇 总 数 据
聚集函数
AVG() 返回某列的平均值
COUNT() 返回某列的行数
MAX() 返回某列的最大值
MIN() 返回某列的最小值
SUM() 返回某列值之和

select avg(prod_price) AS avg_price 
from products
where vend_id = 1003;

COUNT()函数有两种使用方式。
􀂉 使用COUNT(*)对表中行的数目进行计数，不管表列中包含的是空
值（NULL）还是非空值。
􀂉 使用COUNT(column)对特定列中具有值的行进行计数，忽略
NULL值。

select COUNT(*) as cust_num from customers; 
select COUNT(cust_email) as cust_num from customers;

select MAX(prod_price) as  max_price from products;

SUM()用来返回指定列值的和（总计）。
select SUM(quantity) as item_ordered 
from orderitems
where order_num = 20005;

用于计算
select SUM(item_price * quantity) as total_price 
from orderitems
where order_num = 20005;

聚集不同值
select avg(distinct prod_price) AS avg_price 
from products
where vend_id = 1003;

第13 章 分 组 数 据
select vend_id, count(*)  as num_prods
from products
group by vend_id;

with rollup 汇总各分组的和
select vend_id, count(*)  as num_prods
from products
group by vend_id WITH ROLLUP;

在具体使用GROUP BY子句前，需要知道一些重要的规定。
 GROUP BY子句可以包含任意数目的列。这使得能对分组进行嵌套，
为数据分组提供更细致的控制。
 如果在GROUP BY子句中嵌套了分组，数据将在最后规定的分组上
进行汇总。换句话说，在建立分组时，指定的所有列都一起计算
（所以不能从个别的列取回数据）。
 GROUP BY子句中列出的每个列都必须是检索列或有效的表达式
（但不能是聚集函数）。如果在SELECT中使用表达式，则必须在
GROUP BY子句中指定相同的表达式。不能使用别名。
 除聚集计算语句外，SELECT语句中的每个列都必须在GROUP BY子
句中给出。
 如果分组列中具有NULL值，则NULL将作为一个分组返回。如果列
中有多行NULL值，它们将分为一组。
 GROUP BY子句必须出现在WHERE子句之后，ORDER BY子句之前。

过滤分组
除了能用GROUP BY分组数据外，MySQL还允许过滤分组，规定包括
哪些分组，排除哪些分组；
WHERE没有分组的概念；

HAVING非常类似于WHERE。事实上，目前为止所
学过的所有类型的WHERE子句都可以用HAVING来替代。唯一的差别是
WHERE过滤行，而HAVING过滤分组。

WHERE在数据分组前进行过滤，HAVING在数据分组后进行过滤
select vend_id, COUNT(*) as num_prods 
from products
where prod_price >=10 
group by vend_id 
having count(*) >=2;

一般在使用GROUP BY子句时，应该也给
出ORDER BY子句。这是保证数据正确排序的唯一方法。千万
不要仅依赖GROUP BY排序数据
select order_num, sum(quantity*item_price) as ordertotal
from orderitems
group by order_num 
having sum(quantity*item_price) >= 50
order by ordertotal;

SELECT子句及其顺序
子 句          说 明               是否必须使用
SELECT   要返回的列或表达式           是
FROM    从中检索数据的表        仅在从表选择数据时使用
WHERE     行级过滤                     否
GROUP BY   分组说明           仅在按组计算聚集时使用
HAVING     组级过滤                   否
ORDER BY  输出排序顺序                否
LIMIT    要检索的行数                 否


第 14 章

14.2 利用子查询进行过滤
select cust_name, cust_contact 
from customers
where cust_id in (select cust_id 
                  from orders
                  where order_num in (select order_num
                                      from orderitems 
                                      where prod_id = 'TNT2') );

相关子查询:比较orders表中的cust_id与当前正从customers表中检索的cust_id
select cust_name, cust_state,
       (select COUNT(*) 
        from orders 
        where orders.cust_id = customers.cust_id  ) as orders 
        from customers 
        order by cust_name;

逐渐增加子查询来建立查询 用子查询测试和调试查询很有
技巧性，特别是在这些语句的复杂性不断增加的情况下更是如
此。用子查询建立（和测试）查询的最可靠的方法是逐渐进行，
这与MySQL处理它们的方法非常相同。首先，建立和测试最
内层的查询。然后，用硬编码数据建立和测试外层查询，并且
仅在确认它正常后才嵌入子查询。这时，再次测试它。对于要
增加的每个查询，重复这些步骤。这样做仅给构造查询增加了
一点点时间，但节省了以后（找出查询为什么不正常）的大量
时间，并且极大地提高了查询一开始就正常工作的可能性。


第15 章  联 结 表
联结是SQL中最重要最强大的特性，有效地使用联结需要对关系数据
库设计有基本的了解

完全限定列名
创建联结
联结的创建非常简单，规定要联结的所有表以及它们如何关联即可。
select vend_name, prod_name, prod_price 
from vendors, products
where vendors.vend_id = products.vend_id
order by vend_name, prod_name; 

在联结两个表时，你实际上做的是将第一个表中的每一行与第二个表中的每一行配对;
WHERE子句作为过滤条件，它只包含那些匹配给定条件（这里是联结条件）的行。没有
WHERE子句，第一个表中的每个行将与第二个表中的每个行配对，而不管
它们逻辑上是否可以配在一起。

笛卡儿积（cartesian product） 由没有联结条件的表关系返回
的结果为笛卡儿积。检索出的行的数目将是第一个表中的行数乘
以第二个表中的行数。
select vend_name, prod_name, prod_price 
from vendors, products
order by vend_name, prod_name; 

等值联结（equijoin），它基于两个表之间的
相等测试。这种联结也称为内部联结;
联结条件用特定的ON子句而不是WHERE子句给出;
ANSI SQL规范首选INNER JOIN语法;
select vend_name, prod_name, prod_price 
from vendors inner join products
on vendors.vend_id = products.vend_id;


第16 章
创建高级联结

16.1 使用表别名
select cust_name, cust_contact 
from customers as c, orders as o, orderitems as oi 
where c.cust_id = o.cust_id
   and oi.order_num = o.order_num 
   and prod_id = 'TNT2';

16.2 使用不同类型的联结
16.2.1 自联结
select p1.prod_id, p1.prod_name 
from products as p1, products as p2
where p1.vend_id = p2.vend_id
and p2.prod_id = 'DTNTR';

用自联结而不用子查询 自联结通常作为外部语句用来替代
从相同表中检索数据时使用的子查询语句。虽然最终的结果是
相同的，但有时候处理联结远比处理子查询快得多。应该试一
下两种方法，以确定哪一种的性能更好;

16.2.2 自然联结
自然联结排除多次出现，使每个列只返回一次。
select c.*, o.order_num, o.order_date, oi.prod_id, oi.quantity,oi.item_price
from customers as c, orders as o, orderitems as oi 
where c.cust_id = o.cust_id 
and oi.order_num = o.order_num 
and prod_id ='FB';

16.2.3 外部联结
联结包含了那些在相关表中没有关联行的行。这种
类型的联结称为外部联结。

为了检索所有客户，包括那些没有订单的客户，
可如下进行：
select customers.cust_id, orders.order_num 
from customers inner join orders 
on customers.cust_id = orders.cust_id;

select customers.cust_id, orders.order_num 
from customers left outer join orders 
on customers.cust_id = orders.cust_id;

select customers.cust_id, orders.order_num 
from customers right outer join orders 
on customers.cust_id = orders.cust_id;
在使用OUTER JOIN语法时，必须使用RIGHT或LEFT关键字
指定包括其所有行的表（RIGHT指出的是OUTER JOIN右边的表，而LEFT
指出的是OUTER JOIN左边的表）。

16.3 使用带聚集函数的联结
select customers.cust_name, customers.cust_id, COUNT(orders.order_num) as num_ord
from customers inner join orders 
on customers.cust_id = orders.cust_id
group by customers.cust_id;


第17 章 组 合 查 询
17.1 组合查询
有两种基本情况，其中需要使用组合查询：
 在单个查询中从不同的表返回类似结构的数据；
 对单个表执行多个查询，按单个查询返回数据。

多数情况下，组合相同表的两个
查询完成的工作与具有多个WHERE子句条件的单条查询完成的
工作相同。换句话说，任何具有多个WHERE子句的SELECT语句
都可以作为一个组合查询给出，在以下段落中可以看到这一点。
这两种技术在不同的查询中性能也不同。因此，应该试一下这
两种技术，以确定对特定的查询哪一种性能更好。

17.2 创建组合查询
17.2.1 使用UNION
select vend_id, prod_id, prod_price 
from products
where prod_price <=5
union 
select vend_id, prod_id, prod_price
from productsf 
where vend_id in (1001,1002);

select vend_id, prod_id, prod_price 
from products
where prod_price <=5
    or vend_id in (1001,1002);

但在进行并时有几条规则需要注意。
 UNION必须由两条或两条以上的SELECT语句组成，语句之间用关
键字UNION分隔（因此，如果组合4条SELECT语句，将要使用3个
UNION关键字）。
 UNION中的每个查询必须包含相同的列、表达式或聚集函数（不过
各个列不需要以相同的次序列出）。
 列数据类型必须兼容：类型不必完全相同，但必须是DBMS可以
隐含地转换的类型（例如，不同的数值类型或不同的日期类型）。

17.2.3 包含或取消重复的行
UNION从查询结果集中自动去除了重复的行,这是UNION的默认行为，但是如果需要,
可使用UNION ALL而不是UNION;
select vend_id, prod_id, prod_price 
from products
where prod_price <=5
union all
select vend_id, prod_id, prod_price
from products 
where vend_id in (1001,1002);

UNION几乎总是完成与多个
WHERE条件相同的工作。UNION ALL为UNION的一种形式，它完成
WHERE子句完成不了的工作。如果确实需要每个条件的匹配行全
部出现（包括重复行），则必须使用UNION ALL而不是WHERE。

17.2.4 对组合查询结果排序
对于结果集，不存在用一种方式排序一部分，而又用另一种方式排序另一
部分的情况，因此不允许使用多条ORDER BY子句
select vend_id, prod_id, prod_price 
from products
where prod_price <=5
union all
select vend_id, prod_id, prod_price
from products 
where vend_id in (1001,1002)
order by vend_id,prod_price;

第18 章 全文本搜索
18.1 理解全文本搜索
并非所有引擎都支持全文本搜索 正如第21章所述，MySQL
支持几种基本的数据库引擎。并非所有的引擎都支持本书所描
述的全文本搜索。两个最常使用的引擎为MyISAM和InnoDB，
前者支持全文本搜索，而后者不支持。这就是为什么虽然本书
中创建的多数样例表使用InnoDB ， 而有一个样例表
（productnotes表）却使用MyISAM的原因。如果你的应用中需
要全文本搜索功能，应该记住这一点。

18.2 使用全文本搜索
18.2.1 启用全文本搜索支持
create table t(
    note_text  int  not NULL,
    FULLTEXT(note_text)
)ENGINE=MyISM;

为了进行全文本搜索，
MySQL根据子句FULLTEXT(note_text)的指示对它进行索引。这里的
FULLTEXT索引单个列，如果需要也可以指定多个列;

不要在导入数据时使用FULLTEXT 更新索引要花时间，虽然
不是很多，但毕竟要花时间。如果正在导入数据到一个新表，
此时不应该启用FULLTEXT索引。应该首先导入所有数据，然
后再修改表，定义FULLTEXT。这样有助于更快地导入数据（而
且使索引数据的总时间小于在导入每行时分别进行索引所需
的总时间）。

select note_text 
from productnotes
where Match(note_text) Against('rabbit');
使用完整的Match() 说明 传递给Match() 的值必须与
FULLTEXT()定义中的相同。如果指定多个列，则必须列出它
们（而且次序正确）。

搜索不区分大小写 除非使用BINARY方式（本章中没有介绍），
否则全文本搜索不区分大小写。

select note_text 
from productnotes
where note_text LIKE '%rabbit%';

Mysql 8.0 执行失败
select note_text , Match(note_text) Against('rabbit') AS rank
from productnotes;

18.2.3 使用查询扩展
在使用查询扩展时，MySQL对数据和
索引进行两遍扫描来完成搜索：
 首先，进行一个基本的全文本搜索，找出与搜索条件匹配的所有
行；
 其次，MySQL检查这些匹配行并选择所有有用的词（我们将会简
要地解释MySQL如何断定什么有用，什么无用）。p137
 再其次，MySQL再次进行全文本搜索，这次不仅使用原来的条件，
而且还使用所有有用的词。

select note_text 
from productnotes
where Match(note_text) Against('rabbit' with query expansion);

18.2.4 布尔文本搜索
MySQL支持全文本搜索的另外一种形式，称为布尔方式（boolean
mode）。

以布尔方式，可以提供关于如下内容的细节：

 要匹配的词；
 要排斥的词（如果某行包含这个词，则不返回该行，即使它包含
其他指定的词也是如此）；
 排列提示（指定某些词比其他词更重要，更重要的词等级更高）；
 表达式分组；
 另外一些内容。

 布尔方式不同于迄今为止使用的全文本搜索语法的地方在于， 即使没有定义
FULLTEXT索引，也可以使用它。但这是一种非常缓慢的操作
（其性能将随着数据量的增加而降低）。
select note_text 
from productnotes
where Match(note_text) Against('rabbit' in boolean mode);

select note_text 
from productnotes
where Match(note_text) Against('heavy -ropes' in boolean mode);

//必须出现在同一行
select note_text from productnotes where match(note_text) against('+rabbit +bait' in boolean mode);

全文本布尔操作符
+ 包含，词必须存在
- 排除，词必须不出现
> 包含，而且增加等级值
< 包含，且减少等级值
() 把词组成子表达式（允许这些子表达式作为一个组被包含、
排除、排列等）
~ 取消一个词的排序值
* 词尾的通配符
"" 定义一个短语（与单个词的列表不一样，它匹配整个短语以
便包含或排除这个短语）

排列而不排序 在布尔方式中，不按等级值降序排序返回的
行。

在结束本章之前，给出关于全文本搜索的某些重要的说明。
 在索引全文本数据时，短词被忽略且从索引中排除。短词定义为
那些具有3个或3个以下字符的词（如果需要，这个数目可以更改）。
 MySQL带有一个内建的非用词（stopword）列表，这些词在索引
全文本数据时总是被忽略。如果需要，可以覆盖这个列表（请参
阅MySQL文档以了解如何完成此工作）。
 许多词出现的频率很高，搜索它们没有用处（返回太多的结果）。
因此，MySQL规定了一条50%规则，如果一个词出现在50%以上
的行中，则将它作为一个非用词忽略。50%规则不用于IN BOOLEAN MODE。
 如果表中的行数少于3行，则全文本搜索不返回结果（因为每个词
或者不出现，或者至少出现在50%的行中）。
 忽略词中的单引号。例如，dont索引为dont。
 不具有词分隔符（包括日语和汉语）的语言不能恰当地返回全文
本搜索结果。
 如前所述，仅在MyISAM数据库引擎中支持全文本搜索


第19 章 插 入 数 据

19.2 插入完整的行

如果某个列没有值（如上面的cust_contact和cust_email列），应该使用NULL
值（假定表允许对该列指定空值）。各个列必须以它们在表定义中出现的
次序填充。
insert into customers
values(NULL,
    'Pep E. LaPew',
    '100 Main Street',
    'Los Angels',
    'CA',
    '90046',
    'USA',
    NULL,
    NULL
);

VALUES必须以其指定的次序匹配指定的列名，不
一定按各个列出现在实际表中的次序。其优点是，即使表的结构改变，
此INSERT语句仍然能正确工作;
insert into customers(
    cust_address,
    cust_city,
    cust_state,
    cust_zip,
    cust_country,
    cust_contact,
    cust_email
)
values(NULL,
    'Pep E. LaPew',
    '100 Main Street',
    'Los Angels',
    'CA',
    '90046',
    'USA',
    NULL,
    NULL
);


如果数据检索是最重要的（通常是这样），则你可以通过在
INSERT和INTO之间添加关键字LOW_PRIORITY，指示MySQL
降低INSERT语句的优先级
insert low_priority into 

19.3 插入多个行
insert into customers(

)
values(

),
values(

);

单条INSERT语句有多组值，每组值用一对圆括号括起来，
用逗号分隔。
提高INSERT的性能 此技术可以提高数据库处理的性能，因
为MySQL用单条INSERT语句处理多个插入比使用多条INSERT
语句快。

19.4 插入检索出的数据
insert into customers(

)
select col1,col2,..,coln 
from t;

事实上，MySQL甚至不关心SELECT返回的列名。它使用的是
列的位置，因此SELECT中的第一列（不管其列名）将用来填充
表列中指定的第一个列，第二列将用来填充表列中指定的第二
个列，如此等等。这对于从使用不同列名的表中导入数据是非
常有用的。


第 20 章 更新和删除数据
20.1 更新数据
update customers 
set cust_email = 'elmer@fudd.com'
where cust_id = 10005;

更新多个列：
update customers 
set cust_email = 'elmer@fudd.com',
    cust_name = 'The Fudds'
where cust_id = 10005;

IGNORE关键字 如果用UPDATE语句更新多行，并且在更新这些
行中的一行或多行时出一个现错误，则整个UPDATE操作被取消
（错误发生前更新的所有行被恢复到它们原来的值）。为即使是发
生错误，也继续进行更新，可使用IGNORE关键字，如下所示：
UPDATE IGNORE customers…

为了删除某个列的值，可设置它为NULL（假如表定义允许NULL值）。
update customers 
set cust_email = NULL 
where cust_id = 10005;

20.2 删除数据
delete from customers 
where cust_id = 10006;

更快的删除 如果想从表中删除所有行，不要使用DELETE。
可使用TRUNCATE TABLE语句，它完成相同的工作，但速度更
快（TRUNCATE实际是删除原来的表并重新创建一个表，而不
是逐行删除表中的数据）。

20.3 更新和删除的指导原则
下面是许多SQL程序员使用UPDATE或DELETE时所遵循的习惯。
 除非确实打算更新和删除每一行，否则绝对不要使用不带WHERE
子句的UPDATE或DELETE语句。
 保证每个表都有主键（如果忘记这个内容，请参阅第15章），尽可能
像WHERE子句那样使用它（可以指定各主键、多个值或值的范围）。
 在对UPDATE或DELETE语句使用WHERE子句前，应该先用SELECT进
行测试，保证它过滤的是正确的记录，以防编写的WHERE子句不
正确。
 使用强制实施引用完整性的数据库（关于这个内容，请参阅第15
章），这样MySQL将不允许删除具有与其他表相关联的数据的行。

小心使用 MySQL没有撤销（undo）按钮。应该非常小心地
使用UPDATE和DELETE，否则你会发现自己更新或删除了错误
的数据。


第21 章 创建和操纵表
21.1 创建表
为利用CREATE TABLE创建表，必须给出下列信息：
 新表的名字，在关键字CREATE TABLE之后给出；
 表列的名字和定义，用逗号分隔。

在表名后给出IF NOT EXISTS。这样做不检查已有表的模式是否与你打算创建
的表模式相匹配。它只是查看表名是否存在，并且仅在表名不存在时创建它。

create table t(
    col1  int not NULL AUTO_INCREMENT,
    col2  int  not NULL,
    col3  int  null,
    col4  int  not null DEFAULT 1,
    primary key(col1,col2)
)ENGINE = Innodb;

NULL值就是没有值或缺值。允许NULL值的列也允许在
插入行时不给出该列的值。不允许NULL值的列不接受该列没有值的行，
换句话说，在插入或更新行时，该列必须有值;

主键中只能使用不允许NULL值的列。允许NULL值的列不能作为唯一标识;

AUTO_INCREMENT告诉MySQL，本列每当增加一行时自动增量;

每个表只允许一个AUTO_INCREMENT列，而且它必须被索引（如，通
过使它成为主键）。

覆盖AUTO_INCREMENT 如果一个列被指定为AUTO_INCREMENT，
则它需要使用特殊的值吗？你可以简单地在INSERT语句
中指定一个值，只要它是唯一的（至今尚未使用过）即可，该
值将被用来替代自动生成的值。后续的增量将开始使用该手工
插入的值。（相关的例子请参阅本书中使用的表填充脚本。）

那么，如何在使用AUTO_INCREMENT列时获得这个值呢？可使
用last_insert_id()函数获得这个值，如下所示：
select last_insert_id()
此语句返回最后一个AUTO_INCREMENT值，然后可以将它用于
后续的MySQL语句。

如果在插入行时没有给出值，MySQL允许指定此时使用的默认值。
默认值用CREATE TABLE语句的列定义中的DEFAULT关键字指定

show engines; 查看数据库引擎
 以下是几个需要知道的引擎：
 InnoDB是一个可靠的事务处理引擎（参见第26章），它不支持全文
本搜索；
 MEMORY在功能等同于MyISAM，但由于数据存储在内存（不是磁盘）
中，速度很快（特别适合于临时表）；
 MyISAM是一个性能极高的引擎，它支持全文本搜索（参见第18章），
但不支持事务处理。

引擎类型可以混用；外键（用于强制实施引用完整性，如第1章所述）不能跨引擎，即使用一
个引擎的表不能引用具有使用不同引擎的表的外键；

21.2 更新表
为更新表定义，可使用ALTER TABLE语
alter table vendors 
add vend_phone CHAR(20);

alter table vendors
drop column vendors;

添加外键约束 
alter table products
add constraint fk_products_vendors
foreign key (vend_id) references vendors (vend_id);
复杂的表结构更改一般需要手动删除过程，它涉及以下步骤：
 用新的列布局创建一个新表；
 使用INSERT SELECT语句（关于这条语句的详细介绍，请参阅第
19章）从旧表复制数据到新表。如果有必要，可使用转换函数和
计算字段；
 检验包含所需数据的新表；
 重命名旧表（如果确定，可以删除它）；
 用旧表原来的名字重命名新表；
 根据需要，重新创建触发器、存储过程、索引和外键

21.3 删除表
drop table t 

21.4 重命名表
rename table t1 to t1',
       t2 to t2';


第22 章 使 用 视 图
视图是虚拟的表。与包含数据的表不一样，视图只包含使用时动态
检索数据的查询

22.2 使用视图
 视图用CREATE VIEW语句来创建。
 使用SHOW CREATE VIEW viewname；来查看创建视图的语句。
 用DROP删除视图，其语法为DROP VIEW viewname;。
 更新视图时，可以先用DROP再用CREATE，也可以直接用CREATE OR
REPLACE VIEW。如果要更新的视图不存在，则第2条更新语句会创
建一个视图；如果要更新的视图存在，则第2条更新语句会替换原
有视图。

22.2.1 利用视图简化复杂的联结
create view productcustomers as 
select cust_name, cust_contact, prod_id
from customers, orders, orderitems 
where customers.cust_id = orders.cust_id 
     and  orderitems.order_num = orders.order_num; 

select cust_name, cust_contact
from productcustomers
where prod_id = 'TNT2';

22.2.2 用视图重新格式化检索出的数据
22.2.3 用视图过滤不想要的数据

WHERE子句与WHERE子句 如果从视图检索数据时使用了一条
WHERE子句，则两组子句（一组在视图中，另一组是传递给视
图的）将自动组合。

22.2.4 使用视图与计算字段

22.2.5 更新视图
通常，视图是可更新的（即，可以对它们使用INSERT、UPDATE和
DELETE）。更新一个视图将更新其基表

但是，并非所有视图都是可更新的。基本上可以说，如果MySQL不
能正确地确定被更新的基数据，则不允许更新（包括插入和删除）。这实
际上意味着，如果视图定义中有以下操作，则不能进行视图的更新：
 分组（使用GROUP BY和HAVING）；
 联结；
 子查询；
 并；
 聚集函数（Min()、Count()、Sum()等）；

将视图用于检索 一般，应该将视图用于检索（SELECT语句）
而不用于更新（INSERT、UPDATE和DELETE）


第23 章 使用存储过程
存储过程简单来说，就是为以后的使用而保存
的一条或多条MySQL语句的集合。可将其视为批文件，虽然它们的作用
不仅限于批处理。

23.3 使用存储过程
23.3.1 执行存储过程
MySQL称存储过程的执行为调用，因此MySQL执行存储过程的语句
为CALL。CALL接受存储过程的名字以及需要传递给它的任意参数。
call productpricing(@pricelow,
                    @pricehigh,
                    @priceaverage);
               
23.3.2 创建存储过程
delimiter //


create procedure prodprice()
begin
    select avg(prod_price) as avgprice
    from products;
end//

delimiter ;

默认的MySQL语句分隔符为;（正如你已经在迄今为止所使用
的MySQL语句中所看到的那样）。mysql命令行实用程序也使
用;作为语句分隔符。如果命令行实用程序要解释存储过程自
身内的;字符，则它们最终不会成为存储过程的成分，这会使
存储过程中的SQL出现句法错误。
解决办法是临时更改命令行实用程序的语句分隔符，

23.3.3 删除存储过程
drop procedure prodprice;
当过程存在想删除它时（如果过程不存在也
不产生错误）可使用DROP PROCEDURE IF EXISTS

23.3.4 使用参数
一般，存储过程并不显示结果，而是把结果返回给你指定的变量。
变量（variable）是内存中一个特定的位置，用来临时存储数据。

delimiter //
create procedure prodrice(
    out pl decimal(8,2),
    out ph decimal(8,2),
    out pa decimal(8,2)
)
begin 
    select min(prod_price)
    into pl
    from products;
    select max(prod_price)
    into ph 
    from products;
    select avg(prod_price)
    into pa 
    from products;
END //

delimiter ;

call prodrice(@prl,@prh,@ra);

select @prl;

参数的数据类型 存储过程的参数允许的数据类型与表中使用
的数据类型相同

关键字OUT指出相应的参数用来从存储过程传出
一个值（返回给调用者）。MySQL支持IN（传递给存储过程）、OUT（从存
储过程传出，如这里所用）和INOUT（对存储过程传入和传出）类型的参
数

23.3.5 建立智能存储过程

-----this is comment 
create procedure proctemp(
    out p1 INT,
    in b boolean
)COMMENT 'when use show procedure, display this line'
begin
    ---局部变量
    declare var DECIMAL(8,2);
    select x 
    from t 
    into var;

    if b then 
       select t + 10 into p1;
    END if;
END;

COMMENT值。它不是必需的，但如果给出，将
在SHOW PROCEDURE STATUS的结果中显示

显示用来创建一个存储过程的CREATE语句
show create procedure prodrice;

SHOW PROCEDURE STATUS列出所有存储过
程。
show procedure status;

为限制其输出，可使用LIKE指定一个过滤模式
show procedure status like 'prodrice';

第24 章 使 用 游 标 
24.1 游标
游标（cursor）是一个存储在MySQL服务器上的数据库查询，
它不是一条SELECT语句，而是被该语句检索出来的结果集;

在存储了游标之后，应用程序可以根据需要滚动或浏览其中的数据。
游标主要用于交互式应用，其中用户需要滚动屏幕上的数据，并对
数据进行浏览或做出更改。

不像多数DBMS，MySQL游标只能用于存储过程（和函数）。

24.2 使用游标
 在能够使用游标前，必须声明（定义）它。这个过程实际上没有
检索数据，它只是定义要使用的SELECT语句。
 一旦声明后，必须打开游标以供使用。这个过程用前面定义的
SELECT语句把数据实际检索出来。
 对于填有数据的游标，根据需要取出（检索）各行。
 在结束游标使用时，必须关闭游标。
在声明游标后，可根据需要频繁地打开和关闭游标。在游标打开后，
可根据需要频繁地执行取操作

create procedure processorders()
BEGIN
    --declare local variables 局部变量
    declare done boolean DEFAULT 0;
    declare o int ;
    declare t decimal(8,2);

    --declare the cursor 游标
    declare ordernumbers CURSOR 
    for 
    select order_num from orders;

    --declare continue handler 句柄
    declare continue handler for sqlstate '020000' set done=1;

    --create a table to store the results 
    create table if not EXISTS ordertotals 
    (order_num INT, total DECIMAL(8,2));

    --open cursor
    OPEN ordernumbers;

    --loop through all rows 
    REPEAT 
        --get order number 
        FETCH ordernumbers INTO o;

        --get the total for this order 
        CALL ordertotal(o,1,t) ---注意参数t

        insert into ordertotals(order_num,total)
        values(0,t)
    UNTIL done END REPEAT 

    close ordernumbers;

END;

除这里使用的REPEAT语句外，MySQL还支持
循环语句，它可用来重复执行代码，直到使用LEAVE语句手动
退出为止。通常REPEAT语句的语法使它更适合于对游标进行循
环。

DECLARE语句的次序 DECLARE语句的发布存在特定的次序。
用DECLARE语句定义的局部变量必须在定义任意游标或句柄
之前定义，而句柄必须在游标之后定义。不遵守此顺序将产
生错误消息。
布局变量 游标 句柄 

如果你不明确关闭游标，MySQL将会在到达END语
句时自动关闭它

在一个游标关闭后，如果没有重新打开，则不能使用它。但是，使
用声明过的游标不需要再次声明，用OPEN语句打开它就可以了。


第25 章 使用触发器
25.1 触发器
触发器是MySQL响应以下任意语句而
自动执行的一条MySQL语句（或位于BEGIN和END语句之间的一组语
句）：
 DELETE；
 INSERT；
 UPDATE。
其他MySQL语句不支持触发器。

25.2 创建触发器
在创建触发器时，需要给出4条信息：
 唯一的触发器名；
 触发器关联的表；
 触发器应该响应的活动（DELETE、INSERT或UPDATE）；
 触发器何时执行（处理之前或之后）

create trigger tg after insert on products
for each row select "done message";

只有表才支持触发器，视图不支持（临时表也不
支持）。

每个表最多支持6个触发器（每条INSERT、UPDATE
和DELETE的之前和之后）

如果BEFORE触发器失败，则MySQL将不执行请
求的操作。此外，如果BEFORE触发器或语句本身失败，MySQL
将不执行AFTER触发器（如果有的话）。

25.3 删除触发器
DROP TRIGGER <trigname>;
触发器不能更新或覆盖。为了修改一个触发器，必须先删除它，
然后再重新创建。

25.4 使用触发器
25.4.1 INSERT触发器
INSERT触发器在INSERT语句执行之前或之后执行。需要知道以下几
点：
 在INSERT触发器代码内，可引用一个名为NEW的虚拟表，访问被
插入的行；
 在BEFORE INSERT触发器中，NEW中的值也可以被更新（允许更改
被插入的值）；
 对于AUTO_INCREMENT列，NEW在INSERT执行之前包含0，在INSERT
执行之后包含新的自动生成值。

create TRIGGER neworder after insert on orders
for each row select new.order_num;

通常，将BEFORE用于数据验证和净化（目
的是保证插入或更新表中的数据确实是需要的数据）

25.4.2 DELETE触发器
DELETE触发器在DELETE语句执行之前或之后执行。需要知道以下两
点：
 在DELETE触发器代码内，你可以引用一个名为OLD的虚拟表，访
问被删除的行；
 OLD中的值全都是只读的，不能更新。

create trigger deleteorder before delete on orders 
for each row 
begin 
   ----
END;

25.4.3 UPDATE触发器
UPDATE触发器在UPDATE语句执行之前或之后执行。需要知道以下几
点：
 在UPDATE触发器代码中，你可以引用一个名为OLD的虚拟表访问
以前（UPDATE语句前）的值，引用一个名为NEW的虚拟表访问新
更新的值；
 在BEFORE UPDATE触发器中，NEW中的值可能也被更新（允许更改
将要用于UPDATE语句中的值）；
 OLD中的值全都是只读的，不能更新

create trigger updatevendor before update on vendors
for each row set new.vend_state = Upper(New.vend_state);

25.4.4 关于触发器的进一步介绍
在结束本章之前，我们再介绍一些使用触发器时需要记住的重点。
 与其他DBMS相比，MySQL 5中支持的触发器相当初级。未来的
MySQL版本中有一些改进和增强触发器支持的计划。
 创建触发器可能需要特殊的安全访问权限，但是，触发器的执行
是自动的。如果INSERT、UPDATE或DELETE语句能够执行，则相关
的触发器也能执行。
 应该用触发器来保证数据的一致性（大小写、格式等）。在触发器
中执行这种类型的处理的优点是它总是进行这种处理，而且是透
明地进行，与客户机应用无关。
 触发器的一种非常有意义的使用是创建审计跟踪。使用触发器，
把更改（如果需要，甚至还有之前和之后的状态）记录到另一个
表非常容易。
 遗憾的是，MySQL触发器中不支持CALL语句。这表示不能从触发
器内调用存储过程。所需的存储过程代码需要复制到触发器内


第26 章 管理事务处理
26.1 事务处理
MyISAM和InnoDB是两种最常使用
的引擎。前者不支持明确的事务处理管理，而后者支持

26.2 控制事务处理
管理事务处理的关键在于将SQL语句组分解为逻辑块，并明确规定数
据何时应该回退，何时不应该回退。

标识事务开始
start transaction 

26.2.1 使用ROLLBACK
MySQL的ROLLBACK命令用来回退（撤销）MySQL语句

rollback;
ROLLBACK只能在一个事务处理内使用（在执行一条START
TRANSACTION命令之后）。

事务处理用来管理INSERT、UPDATE和
DELETE语句。你不能回退SELECT语句。（这样做也没有什么意
义。）你不能回退CREATE或DROP操作。事务处理块中可以使用
这两条语句，但如果你执行回退，它们不会被撤销。

26.2.2 使用COMMIT
一般的MySQL语句都是直接针对数据库表执行和编写的。这就是
所谓的隐含提交（implicit commit），即提交（写或保存）操作是自动
进行的。
但是，在事务处理块中，提交不会隐含地进行。为进行明确的提交，
使用COMMIT语句，

start transaction;
---some transaction---
commit;

26.2.3 使用保留点
为了支持回退部分事务处理，必须能在事务处理块中合适的位置放
置占位符。这样，如果需要回退，可以回退到某个占位符。
这些占位符称为保留点

savepoint p1;
savepoint p2;

rollback to p1;

保留点在事务处理完成（执行一条ROLLBACK或
COMMIT）后自动释放。自MySQL 5以来，也可以用RELEASE
SAVEPOINT明确地释放保留点。

26.2.4 更改默认的提交行为
正如所述，默认的MySQL行为是自动提交所有更改。换句话说，任何
时候你执行一条MySQL语句，该语句实际上都是针对表执行的，而且所做
的更改立即生效。为指示MySQL不自动提交更改，需要使用以下语句：
set autocommit = 0; 

autocommit标志是针对每个连接而不是服务器的。


第27 章 全球化和本地化
27.1 字符集和校对顺序
MySQL支持众多的字符集。为查看所支持的字符集完整列表，使用
以下语句：
show character set;

为了查看所支持校对的完整列表，使用以下语句：
show collation;

为了确定所用的字符集和校对，可以使用以下语句：
show variables like 'character%';
show variables like 'collation%';

实际上，字符集很少是服务器范围（甚至数据库范围）的
设置。不同的表，甚至不同的列都可能需要不同的字符集，而且两者都
可以在创建表时指定。
create table t(
    col1 varchar(10) character set latin1 collate xxx;
)
DEFAULT character set xxx 
collate xxx;

select col 
from t 
order by collate xxx;

一般，MySQL如
下确定使用什么样的字符集和校对。
 如果指定CHARACTER SET和COLLATE两者，则使用这些值。
 如果只指定CHARACTER SET，则使用此字符集及其默认的校对（如
SHOW CHARACTER SET的结果中所示）。
 如果既不指定CHARACTER SET，也不指定COLLATE，则使用数据库
默认。

第28 章
安 全 管 理

28.1 访问控制
MySQL服务器的安全基础是：用户应该对他们需要的数据具有适当
的访问权，既不能多也不能少。

MySQL Administrator（在第2章中
描述）提供了一个图形用户界面，可用来管理用户及账号权限。

28.2 管理用户
MySQL用户账号和信息存储在名为mysql的MySQL数据库中。一般
不需要直接访问mysql数据库和表（你稍后会明白这一点），但有时需要
直接访问。需要直接访问它的时机之一是在需要获得所有用户账号列表
时。为此，可使用以下代码：
use mysql;
select user from user;

在这部分知识点上，mysql 8.0 可能有重大变化；
28.2.1 创建用户账号
create user ben identified by 'pass123Fuck,';
create user ben identified by 'password';

指定散列口令 IDENTIFIED BY指定的口令为纯文本，MySQL
将在保存到user表之前对其进行加密。为了作为散列值指定口
令，使用IDENTIFIED BY PASSWORD

使用GRANT或INSERT GRANT语句（稍后介绍）也可以创建用
户账号，但一般来说CREATE USER是最清楚和最简单的句子。
此外，也可以通过直接插入行到user表来增加用户，不过为安
全起见，一般不建议这样做。MySQL用来存储用户账号信息
的表（以及表模式等）极为重要，对它们的任何毁坏都
可能严重地伤害到MySQL服务器。因此，相对于直接处理来
说，最好是用标记和函数来处理这些表

rename user ben to othername;

仅MySQL 5或之后的版本支持RENAME USER。
为了在以前的MySQL中重命名一个用户，可使用UPDATE直接
更新user表。

28.2.2 删除用户账号
drop user ben;
MySQL 5之前 自MySQL 5以来，DROP USER删除用户账号和
所有相关的账号权限。在MySQL 5以前，DROP USER只能用来
删除用户账号，不能删除相关的权限。因此，如果使用旧版
本的MySQL，需要先用REVOKE删除与账号相关的权限，然后
再用DROP USER删除账号。

28.2.3 设置访问权限
在创建用户账号后，必须接着分配访问权限。新创建的用户账号没有访
问权限

为看到赋予用户账号的权限，使用SHOW GRANTS FOR
show grants for ben;

USAGE表示根本没有权限（我知道，这不很直观）

MySQL的权限用用户名和主机名结
合定义。如果不指定主机名，则使用默认的主机名%（授予用
户访问权限而不管主机名）。

为设置权限，使用GRANT语句。GRANT要求你至少给出以下信息：
 要授予的权限；
 被授予访问权限的数据库或表；
 用户名。

grant select on crashcourse.* to ben;

GRANT的反操作为REVOKE，用它来撤销特定的权限
revoke select on crashcourse.* from ben;

GRANT和REVOKE可在几个层次上控制访问权限：
 整个服务器，使用GRANT ALL和REVOKE ALL；
 整个数据库，使用ON database.*；
 特定的表，使用ON database.table；
 特定的列；
 特定的存储过程。

p213表 权限 

在使用GRANT和REVOKE时，用户账号必须存在，
但对所涉及的对象没有这个要求。这允许管理员在创建数据库
和表之前设计和实现安全措施。（即就是说，授权时，表还不存在，不知道表实体）
这样做的副作用是，当某个数据库或表被删除时（用DROP语
句），相关的访问权限仍然存在。而且，如果将来重新创建该
数据库或表，这些权限仍然起作用。

简化多次授权 
grant select, insert on crashcourse.* to ben;

28.2.4 更改口令
set password for ben = password('xxxx');
Mysql 8.0
set password for 'benben'@'%'='ej*243njFoi';

SET PASSWORD还可以用来设置你自己的口令：
set password = password('xxx');
set password = "xxx"

第29 章 数据库维护
29.1 备份数据
像所有数据一样，MySQL的数据也必须经常备份。由于MySQL数据
库是基于磁盘的文件，普通的备份系统和例程就能备份MySQL的数据。
但是，由于这些文件总是处于打开和使用状态，普通的文件副本备份不
一定总是有效。

下面列出这个问题的可能解决方案。
 使用命令行实用程序mysqldump转储所有数据库内容到某个外部
文件。在进行常规备份前这个实用程序应该正常运行，以便能正
确地备份转储文件。
 可用命令行实用程序mysqlhotcopy从一个数据库复制所有数据
（并非所有数据库引擎都支持这个实用程序）。
 可以使用MySQL的BACKUP TABLE或SELECT INTO OUTFILE转储所
有数据到某个外部文件。这两条语句都接受将要创建的系统文件
名，此系统文件必须不存在，否则会出错。数据可以用RESTORE
TABLE来复原。

首先刷新未写数据 为了保证所有数据被写到磁盘（包括索引
数据），可能需要在进行备份前使用FLUSH TABLES语句。

29.2 进行数据库维护
 ANALYZE TABLE，用来检查表键是否正确
analyze table orders;

https://dev.mysql.com/doc/refman/8.0/en/check-table.html
 CHECK TABLE用来针对许多问题对表进行检查。在MyISAM表上还对
索引进行检查。CHECK TABLE支持一系列的用于MyISAM表的方式。
CHANGED检查自最后一次检查以来改动过的表。EXTENDED执行最
彻底的检查，FAST只检查未正常关闭的表，MEDIUM检查所有被删
除的链接并进行键检验，QUICK只进行快速扫描。如下所示，CHECK
TABLE发现和修复问题：

check table orders, orderitems; 

 如果MyISAM表访问产生不正确和不一致的结果，可能需要用
REPAIR TABLE来修复相应的表

 如果从一个表中删除大量数据，应该使用OPTIMIZE TABLE来收回
所用的空间，从而优化表的性能。

29.3 诊断启动问题
在排除系统启动问题时，首先应该尽量用手动启动服务器。MySQL
服务器自身通过在命令行上执行mysqld启动。下面是几个重要的mysqld
命令行选项：
 --help显示帮助——一个选项列表；
 --safe-mode装载减去某些最佳配置的服务器；
 --verbose显示全文本消息（为获得更详细的帮助消息与--help
联合使用）；
 --version显示版本信息然后退出。

29.4 查看日志文件
MySQL维护管理员依赖的一系列日志文件。主要的日志文件有以下
几种。
 错误日志。它包含启动和关闭问题以及任意关键错误的细节。此
日志通常名为hostname.err，位于data目录中。此日志名可用
--log-error命令行选项更改。
 查询日志。它记录所有MySQL活动，在诊断问题时非常有用。此
日志文件可能会很快地变得非常大，因此不应该长期使用它。此
日志通常名为hostname.log，位于data目录中。此名字可以用
--log命令行选项更改。
二进制日志。它记录更新过数据（或者可能更新过数据）的所有
语句。此日志通常名为hostname-bin，位于data目录内。此名字
可以用--log-bin命令行选项更改。注意，这个日志文件是MySQL5
中添加的，以前的MySQL版本中使用的是更新日志。
 缓慢查询日志。顾名思义，此日志记录执行缓慢的任何查询。这
个日志在确定数据库何处需要优化很有用。此日志通常名为
hostname-slow.log ， 位于data 目录中。此名字可以用
--log-slow-queries命令行选项更改。

在使用日志时，可用FLUSH LOGS语句来刷新和重新开始所有日志文
件。

第30 章 