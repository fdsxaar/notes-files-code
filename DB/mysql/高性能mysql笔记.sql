第4 章 Schema 与数据类型优化
4.1 选择优化的数据类型
更小的通常更好

简单就好
简单数据类型的操作通常需要更少的CPU 周期，整型比字符操作代价更低，
因为字符集和校对规则(排序规则)使字符比较比整型比较更复杂；一个是应该使用MySQL 
内建的类型扫而不是字符串来存储日期和时间，另外一个是应该用整型存储IP 地址

尽量避免NULL
如果查询中包含可为NULL 的列，对MySQL 来说更难优化，因为可为NULL 的列使
得索引、索引统计和值比较都更复杂。可为NULL 的列会使用更多的存储空间，在
MySQL 里也需要特殊处理。当可为NULL 的列被索引时，每个索引记录需要一个额
外的字节，在MyISAM 里甚至还可能导致固定大小的索引(例如只有一个整数列的
索引)变成可变大小的索引。

在为列选择数据类型时，第一步需要确定合适的大类型：数字、字符串、时间等
下一步是选择具体类型

4.1.1 整数类型
有两种类型的数字:整数(whole number) 和实数(real number) 。如果存储整数，可
以使用这几种整数类型: TINYINT, SMALLINT, MEDIUMINT INT, BIGINT,分别使用8,
16 , 24 , 32 , 64 位存储空间
整数类型有可选的UNSIGNED 属性，表示不允许负值，这大致可以使正数的上限提高一倍。
SMALLINT UNSIGNED 

你的选择决定MySQL 是怎么在内存和磁盘中保存数据的。然而，整数计算一般使用
64 位的BIGINT 整数，即使在32 位环境也是如此。(一些聚合函数是例外，它们使用
DEClMAL 或DOUBLE 进行计算)。

MySQL 可以为整数类型指定宽度，例如INT(11)，对大多数应用这是没有意义的:它不
会限制值的合禧范围，只是规定了MySQL 的一些交互工具(例如MySQL 命令行客户端)
用来显示字符的个数。对于存储和计算来说，INT(1)和INT(21)是相同的。

4.1.2 实数类型
实数是带有小数部分的数字。然而，它们不只是为了存储小数部分; 也可以使用
DECIMAL 存储比BIGINT 还大的整数。

DECIMAL 类型用于存储精确的小数。在MySQL 5.0 和更高版本， DECIMAL 类型支持精确
计算。MySQL 4.1 以及更早版本则使用浮点运算来实现DECIAML 的计算，这样做会因为
精度损失导致一些奇怪的结果。在这些版本的MySQL 中， DEClMAL 只是一个"存储类型"。

salary DECIMAL(5,2)
In this example, 5 is the precision and 2 is the scale. The precision represents 
the number of significant digits that are stored for values, 
and the scale represents the number of digits that can be stored following the decimal point.

MySQL 5.0 和更高版本将数字打包保存到一个二进制字符串中(每4 个字节存9 个数字)

有多种方撞可以指定浮点列所需要的精度，这会使得MySQL 悄悄选择不同的数据类型，
或者在存储时对值进行取舍。这些精度定义是非标准的，所以我们建议只指定数据类型，
不指定精度。

浮点类型在存储同样范围的值时，通常比DECIMAL 使用更少的空间。

因为需要额外的空间和计算开销，所以应该尽量只在对小数进行精确计算时才使用
DECIMAL- 例如存储财务数据。但在数据量比较大的时候，可以考虑使用BIGINT代替
DECIMAL ，将需要存储的货币单位根据小数的位数乘以相应的倍数即可

4.1.3 字符串类型
VARCHAR 和CHAR 是两种最主要的字符串类型。不幸的是，很难精确地解择这些值是怎么
存储在磁盘和内存中的，因为这眼存储引擎的具体实现有关.
存储引擎存储CHAR 或者VARCHAR 值的方式在内存中和在磁盘上可能不一样,所以MySQL 服务器从存储引擎读
出的值可能需要转换为另一种存储格式。

VARCHAR 类型用于存储可变长字符串，是最常见的字符串数据类型。它比定长类型
更节省空间，因为它仅使用必要的空间

VARCHAR 需要使用1 或2 个额外字节记录字符串的长度:如果列的最大长度小于或
等于255 字节，则只使用1 个字节表示，否则使用2 个字节

//频繁更新，产生碎片
由于行是变长的，在
UPDATE 时可能使行变得比原来更长，这就导致需要做额外的工作。如果一个行占用
的空间增长，并且在页内没有更多的空间可以存储，在这种情况下，不同的存储引
擎的处理方式是不一样的。例如， MyISAM 会将行拆成不同的片段存储， InnoDB
则需要分裂页来使行可以放进页内。其他一些存储引擎也许从不在原数据位置更新
数据。

下面这些情况下使用VARCHAR 是合适的:字符串列的最大长度比平均长度大很多；
列的更新很少，所以碎片不是问题；使用了像UTF-8 这样复杂的字符集，每个字符
都使用不同的字节数进行存储。

在5.0 或者更高版本，MySQL 在存储和检索时会保留末尾空格。但在4.1 或更老
的版本， MySQL 会剔除末尾空格。

CHAR
CHAR 类型是定长的: MySQL 总是根据定义的字符串长度分配足够的空间。当存储
CHAR 值时， MySQL 会删除所有的末尾空格；CHAR 适合存储很短的字符串，或者所有值都接近同
一个长度。例如， CHAR 非常适
合存储密码的问MD5值，因为这是一个定长的值。对于经常变更的数据， CHAR 也比
VARCHAR 更好，因为定长的CHAR 类型不容易产生碎片。对于非常短的列， CHAR 比
VARCHAR 在存储空间上也更有效率

与CHAR 和VARCHAR 类似的类型还有BINARY 和VARBINARY ，它们存储的是二进制字符串。
二进制字符串跟常规字符串非常相似，但是二进制字符串存储的是字节码而不是字符。
填充也不一样: MySQL 填充BINARY 采用的是\0 (零字节)而不是空格，在检索时也不
会去掉填充值

当需要存储二进制数据，井且希望MySQL 使用字节码而不是字符进行比较时，这些
类型是非常有用的。二进制比较的优势井不仅仅体现在大小写敏感上。MySQL 比较
BINARY 字符串时，每次按一个字节，并且根据该字节的数值进行比较。因此，二进制比
较比字符比较简单很多，所以也就更快。

更长的列会消耗更多的内存，因为MySQL 通常会分配固
定大小的内存块来保存内部位。尤其是使用内存临时农进行排序或操作时会特别糟
糕。在利用磁盘临时求进行排序时也同样糟糕。

BLOB 和TEXT 类型
BLOB 和TEXT 都是为存储很大的数据而设计的字符串数据类型，分别采用二进制和字符
方式存储。
实际上，它们分别属于两组不同的数据类型家族:字符类型是TINYTEXT ， SMALLTEXT, 
TEXT, MEDIUMTEXT ， LONGTEXT 对应的二进制类型是TINYBLOB ， SMALLBLOB, BLOB,
MEDIUMBLOB, LONGBLOB， BLOB 是SMALLBLOB 的同义词， TEXT 是SMALLTEXT 的同义词。
与其他类型不同， MySQL 把每个BLOB 和TEXT 值当作一小独立的对象处理。存储引擎
在存储时通常会做特殊处理。当BLOB 和TEXT 值太大时， InnoDB 会使用专门的"外部"
存储区域来进行存储，此时每个值在行内需要1 - 4 个字节存储一个指针，然后在外部
存储区域存储实际的值。
BLOB 和TEXT 家族之间仅有的不同是BLOB 类型存储的是二进制数据，没有排序规则或字
符集，而TEXT  类型有字符集和排序规则。
MySQL 对BLOB 和TEXT 列进行排序与其他类型是不同的:它只对每个列的最前max
sort_length 字节而不是整个字符串做排序。如果只需要排序前面一小部分字符，则可
以减小max_sort_length 的配置，或者使用ORDER BY SUSTRING(column , length) 。
MySQL 不能将BLOB 和TEXT 列全部长度的字符串进行索引，也不能使用这些索引消除
排序。

最好的解决方案是尽量避免使用BLOB 和TEXT 类型。如果实在无法避免，有一个技
巧是在所有用到BLOB 字段的地方都使用SUBSTRING(column , length) 将列佳转换为
字符串(在ORDER BY 子句中也适用) ，这样就可以使用内存临时表了

使用枚举(ENUM) 代替字符串类型
有时候可以使用枚举列代替常用的字符串类型。枚举列可以把一些不重复的字符串存储
成一个预定义的集合。MySQL 在存储枚举时非常紧凑，会根据列表值的数量压缩到一
个或者两个字节中。MySQL 在内部会将每个值在列表中的位置保存为整数，井且在表
的frm 文件中保存"数字-字符串"映射关系的"查找表"

如果使用数字作为ENUM 枚举常量，这种双重性很容易导致幌乱，例如ENUM ('1' ,
'2','3')

另外一个让人吃惊的地方是，枚举字段是按照内部存储的整数而不是定义的字符串进行
排序的.
SELECT e FROM enum_test ORDER BY FIELD(e, 'apple', 'dog','fish') ;

由于MySQL 把每个枚举值保存为整数，井且必须进行查找才能转换为字符串，所以枚
举列有一些开销。通常枚举的列表都比较小，所以开销还可以控制，但也不能保证一直
如此。在特定情况下，把CHAR/VARCHAR 列与枚举列进行关联可能会比直接关联CHAR/
VARCHAR 列更慢。

//从根本上说，枚举列存储的是数字，节省空间，易于比较
在本例中，如果不是必须和VARCHAR 列进行关联，那么
转换这些列为ENUM 就是个好主意。这是一个通用的设计实践，在"查找表"时采用整数
主键而避免采用基于字符串的值进行关联。
然而，转换列为枚举型还有另一个好处。根据SHOW TABLE STATUS 命令输出结果中
Data_length 列的值，把这两列转换为ENUM 可以让表的大小缩小1/3.

4.1 .4日期和时间类型
MySQL 能存储的最小时间粒度为秒(MariaDB 支持微秒级别的时间类型)。但是MySQL 也可以使用微秒
级的粒度进行临时运算，

MySQL 提供两种相似的日期类型: DATETIME 和 TIMESTAMP

DATETIME
这个类型能保存大范围的值，从1001 年到9999 年，精度为秒。它把日期和时间封
装到格式为YYYYMMDDHHMMSS 的整数中，与时区无关。使用8 个字节的存储
空间。

TIMESTAMP
就像它的名字一样， TIMESTAMP 类型保存了从1970 年1 月1 日午夜(格林尼治标准
时间)以来的秒数，它和UNIX 时间戳相同。TIMESTAMP只使用4 个字节的存储空间，
因此它的范围比DATETIME 小得多:只能表示从1970 年到2038 年。MySQL 提供了
FROM_UNIXTIME( )函数把Unix 时间戳转换为日期，井提供了UNIX_TIMESTAMP ( )函
数把日期转换为Unix 时间戳。

TIMESTAMP 显示的值也依赖于时区。MySQL 服务器、操作系统，以及客户端连接都
有时区设置。

如果在多个时区存储或访问
数据， TIMESTAMP 和DATETIME 的行为将很不一样。前者提供的值与时区有关系，后
者则保留文本表示的日期和时间。
TIMESTAMP 也有DATETIME 没有的特殊属性。默认情况下，如果插入时没有指定第一
个TIMESTAMP 列的值， MySQL 则设置这个列的值为当前时间注飞在插入一行记录时，
MySQL 默认也会更新第一个TIMESTAMP 列的值(除非在UPDATE 语句中明确指定了
值)

除了特殊行为之外，通常也应该尽量使用TIMESTAMP ，因为它比DAT盯IME 空间效率更高。

如果需要存储比秒更小粒度的日期和时间值怎么办? MySQL 目前没有提供合适的数据
类型，但是可以使用自己的存储格式:可以使用BIGI町类型存储微秒级别的时间截，或
者使用DOUBLE 存储秒之后的小数部分。这两种方式都可以，或者也可以使用MariaDB
替代MySQL.

TIMESTAMP 的行为规则比较复杂，并且在不同的MySQL 版本里会变动，所以你应该验证数据库的
行为是你需要的.一个好的方式是修改完TIMESTAP 列后用SH刷CREATE TABLE 命令检查输出.

4.1.5 位数据类型
所有这些位类型，不管底层存储格式和处理方式如何，从技术上来说都是字符串类型。

BIT
可以使用B盯列在一列中存储一个或多个true/false 值。BIT(l) 定义一个包含单个位
的字段， BIT(2) 存储2 个位，依此类推。BIT 列的最大长度是64 个位。

BIT 的行为因存储引擎而异。MylSAM 会打包存储所有的BIT 列，所以17 个单独的
BIT 列只需要17 个位存储(假设没有可为NULL 的列) ，这样MylSAM 只使用3 个
字节就能存储这17 个BIT 列。其他存储引擎例如Memory 和InnoDB ，为每个BIT
列使用一个足够存储的最小整数类型来存放，所以不能节省存储空间。

MySQL 把BIT 当作字符串类型，而不是数字类型。当检索BIT(l) 的值时，结果是
一个包含二进制0 或1 值的字符串，而不是ASCII 码的"0" 或"1" 。然而，在数
字上下文的场景中检索时，结果将是位字符串转换成的数字。如果需要和另外的值
比较结果，一定要记得这一点。例如，如果存储一个值b'00111001' (二进制值等
于57) 到BIT(8) 的列并且检索它，得到的内容是字符码为57 的字符串。也就是说
得到ASCII 码为57 的字符"9" 。但是在数字上下文场景中，得到的是数字57 :

这是相当令人费解的，所以我们认为应该谨慎使用BIT 类型。对于大部分应用，最
好避免使用这种类型。
如果想在一个bit 的存储空间中存储一个true/false 值，另一个方法是创建一个可以
为空的CHAR的列。该列可以保存空值(NULL) 或者长度为零的字符串(空字符串)。

SET 
如果需要保存很多true/false 值，可以考虑合井这些列到一个SET 数据类型，它在
MySQL 内部是以一系列打包的位的集合来表示的。这样就有效地利用了存储空间，
并且MySQL 有像FIND_IN_SET( )和FIELD() 这样的函数，方便地在查询中使用。
它的主要缺点是改变列的定义的代价较高：需要ALTER TABLE ，这对大表来说是非
常昂贵的操作(但是本章的后面给出了解决办法)。一般来说，也无法在SET 列上通
过索引查找。

在整数列上进行按位操作
一种替代SET 的方式是使用一个整数包装一系列的位

4.1.6 选择标识符( identifier)
标识列也可能在另外的表中作为外键使用，所以为标识列选择数据类型时，应该选择跟关联表中
的对应列一样的类型

一旦选定了一种类型，要确保在所有关联表中都使用同样的类型

在可以满足值的范围的需求，并且预留未来增长空间的前提下，应该选择最小的数据类
型。

整数类型
整数通常是标识列最好的选择，因为它们很快并且可以使用AUTO_INCREMENT

ENUM 和SET 类型
对于标识列来说， EMUM 和SET 类型通常是一个糟牒的选择，
ENUM 和SET 列适合存储固定信息，例如有序的状态、产品类型、人的性别。

字符串类型
如果可能，应该避免使用字符串类型作为标识列，因为它们很捎耗空间，井且通
常比数字类型慢。

MyISAM 默认对字符串使用压缩索引，这会导致查询慢得多

对于完全"随机"的字符串也需要多加注意，例如MD5( )、SHAl( )或者UUID( )产生
的宇符串。这些函数生成的新值会任意分布在很大的空间内，这会导致INSERT 以及
一些SELECT 语句变得很慢注13 :
• 因为插入值会随机地写到索引的不同位置，所以使得INSERT 语句更睦。这会导
致页分裂、磁盘随机访问，以及对于聚簇存储引擎产生聚簇索引碎片。关于这
一点第5 章有更多的讨论。
• SELECT 语句会变得更慢，因为逻辑上相邻的行会分布在磁盘和内存的不同地方。
• 随机值导致缓存对所有类型的查询语句效果都很差，因为会使得缓存赖以工作
的访问局部性原理失效。如果整个数据集都一样的"热"，那么缓存任何一部分
特定数据到内存都没有好处，女口果工作集比内存大，缓存将会有很多刷新和不
命中。

如果存储UUID 值，则应该移除"_" ; 符号自或者更好的做法是，用UNHEX( )函数转换
UUID 值为16 字节的数字，井且存储在一个BINARY(16) 列中。检索时可以通过HEX()
函数来格式化为十六进制格式。

另一方面，对一些有很多写的特别大的哀，这种伪随机位实际上可以帮助消除热点。

4.1.7 特殊类型数据
人们经常使用VARCHAR(15) 列来存储IP 地址。然而，它
们实际上是32 位无符号整数，不是字符串。用小数点将地址分成四段的表示方法只是
为了让人们阅读容易。所以应该用无符号整数存储IP 地址。MySQL 提供INET_ATON( )
和INET_NTOA() 函数在这两种表示方战之间转换。

4.2 MySQL schema 设计中的陷阱
太多的列
MySQL 的存储引擎API 工作时需要在服务器层和存储引擎层之间通过行缓冲格式
拷贝数据，然后在服务器层将缓冲内容解码成各个列。从行缓冲中将编码过的列转
换成行数据结构的操作代价是非常高的

太多的关联
所谓的"实体-属性-值" (EAV) 设计模式是一个常见的糟糕设计模式，尤其是在
MySQL 下不能靠谱地工作. MySQL 限制了每个关联操作最多只能有61 张表,
一个粗略的经验法则，如果希望查询执行得快速且并发性好，单个查询最
好在12 个表以内做关联。

全能的枚举
注意防止过度使用枚举(ENUM) 。
CREATE TABLE ••• (
country enum('' , 'O' , '1' , '2' ,..., '31')
这里应该用整数作为外键关联到字典表或者查找表来查找具体值。但是在MySQL 中，
当需要在枚举列表中增加一个新的国家时
就要做一次ALTER TABLE 操作

变相的枚举
CREATE TABLE ...(
is_default set('Y' , 'N') NOT NULL default 'N'
如果这里真和假两种情况不会同时出现，那么毫无疑问应该使用枚举列代替集合列。

非此发明(Not Invent Here) 的NULL
但是遵循这个原则也不要走极端。当确实需要表示未知值时也不要害怕使用NULL
CRE盯E TABLE •.. (
dt DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00'
伪造的全0 值可能导致很多问题(可以配置MySQL 的SQL_MODE 来禁止不可能的日期，
对于新应用这是个非常好的实践经验，它不会让创建的数据库里充满不可能的值)。
值得一提的是， MySQL 会在索引中存储NULL 值，而Oracle 则不会

4.3 范式和反范式
在范式化的数据库中，每个事实数据会出现并且只出现一次。相反，在
反范式化的数据库中，信息是冗余的，可能会存储在多个地方。

4.3.1 范式的优点和缺点
优点:总的来说，没有冗余数据
缺点：通常需要关联

4.3.2 反范式的优点和缺点
反范式化的schema 因为所有数据都在一张表中，可以很好地避免关联。
如果不需要关联表，则对大部分查询最差的情况一一即使表没有使用索引一一是全表扫
描。当数据比内存大时这可能比关联要快得多，因为这样避免了随机I/O 

4.3.3 混用范式化和反范式化
在实际应用中经常需要混用，可能使用部分范式化的
schema、缓存表，以及其他技巧。

最常见的反范式化数据的方站是复制或者缓存，在不同的表中存储相同的特定列。在
MySQL 5.0 和更新版本中，可以使用触发器更新缓存值，这使得实现这样的方案变得更
简单。

//在这些技术背后，隐含的是算法的思想，空间换时间；以及并发的思想，多线程知识
4.4 缓存表和汇总表
The terms “cache table” and “summary table” don’t have standardized meanings. We
use the term “cache tables” to refer to tables that contain data that can be easily, if more
slowly, retrieved from the schema (i.e., data that is logically redundant). When we say
“summary tables,” we mean tables that hold aggregated data from GROUP BY queries
(i.e., data that is not logically redundant). Some people also use the term “roll-up tables”
for these tables, because the data has been “rolled up.”

//P170
不管是哪种方法————不严格的计数或通过小范围查询填满间隙的严格计数————都比计算
message 表的所有行要有效得多。这是建立汇总表的最关键原因。实时计算统计值是很
昂贵的操作，因为要么需要扫描表中的大部分数据，要么查询语句只能在某些特定的索
引上才能有效运行，而这类特定索引一般会对UPDATE 操作有影响，所以一般不希望创建
这样的索引。计算最活跃的用户或者最常见的"标签"是这种操作的典型例子。

缓存表则相反，其对优化搜索和检索查询语句很有效。这些查询语句经常需要特殊的表
和索引结构，跟普通OLTP 操作用的表有些区别。
例如，可能会需要很多不同的索引组合来加速各种类型的查询。这些矛盾的需求有时需
要创建一张只包含主表中部分列的缓存表。一个有用的技巧是对缓存表使用不同的存储
引擎。例如，如果主表使用InnoDB ，用MyISAM 作为缓存表的引擎将会得到更小的索
引占用空间，井且可以做全文搜索。有时甚至想把整个表导出MySQL ，插入到专门的
搜索系统中获得更高的搜索效率，例如Lucene 或者Sphinx 搜索引擎。
在使用缓存表和汇总表时，必须决定是实时维护数据还是定期重建。哪个更好依赖于应
用程序，但是定期重建并不只是节省资源，也可以保持表不会有很多碎片，以及有完全
顺序组织的索引(这会更加高效)。
当重建汇总表和缓存表时，通常需要保证数据在操作时依然可用。这就需要通过使用"影
子表"来实现，"影子表"指的是一张在真实表"背后"创建的表。当完成了建表操作后，
可以通过一个原子的重命名操作切换影子表和原表

4.4.1 物化视图
Flexviews
4.4.2 计数器表
创建一张独立的表存储计数器通常是个好主意，这样可使计数器表小且快

要获得更高的并发更新性能，也可以将计数器保存在多行中，每次随机选择一行进行更新
 CREATE TABLE hit_counter (
 slot tinyint unsigned not null primary key.
 cnt int unsigned not null
) ENGINE=InnoDB

一个常见的需求是每隔一段时间开始一个新的计数器(例如，每天一个)
CREATE TABLE daily_hit_counter (
 day date not null.
 slot tinyint unsigned not null.
 cnt int unsigned not null. • primary key(day. slot)
 ) ENGINE=InnoDB

在这个场景中，可以不用像前面的例子那样预先生成行，而用ON DUPLICATE KEY
UPDATE 代替
mysql) INSERT INTO daily_hit_counter(day, slot, cnt)
 VALUES(CURRENT_D，盯E ， RAND() * 100, 1)
 ON DUPLICATE KEY UPDATE cnt = cnt + 1;
如果希望减少表的行数，以避免表变得太大，可以写一个周期执行的任务，合井所有结
果到0 号槽，井且删除所有其他的槽
mysql) UPDATE daily_hit_counter as c
-) INNER JOIN (
-) SELECT day, SUM(cnt) AS cnt ，阴IN(slot) AS mslot
-) FROM daily_hit_counter
-) GROUP BY day
-) ) AS x USING(day)
-) SET c.cnt = IF(c.slot = x.mslot, x.cnt, 0),
-) c.slot = IF(c.slot = x.mslot, 0, c.slot)
mysql) DELETE FROM daily_hit_counter WHERE slot <> 0 AND cnt = Oj

4.5 加快ALTER TABLE 操作的速度
一般而言，大部分ALTER TABLE 操作将导致MySQL 服务中断。我们会展示一些在DDL
操作时有用的技巧，但这是针对一些特殊的场景而言的。对常见的场景，能使用的技巧
只有两种:一种是先在一台不提供服务的机器上执行ALTER TABLE 操作，然后和提供服
务的主库进行切换；另外一种技巧是"影子拷贝"。影子拷贝的技巧是用要求的表结构
创建一张和源表无关的新表，然后通过重命名和删表操作交换两张表

Tools can help with this: for example, the “online schema change” tools
from Facebook’s database operations team (https://launchpad.net/mysqlatfacebook),
Shlomi Noach’s openark toolkit (http://code.openark.org/), and Percona Toolkit (
    http://www.percona.com/software/). If you are using Flexviews (discussed in “Materialized
Views” on page 138), you can perform nonblocking schema changes with its CDC
utility too

//不会引起表重建
不是所有的ALTER TABLE 操作都会引起表重建。例如，有两种方怯可以改变或者删除一
个列的默认值(一种方法很快，另外一种则很慢)。假如要修改电影的默认租赁期限，从
三天改到五天。下面是很慢的方式:
mysql> ALTER TABLE sakila.film
->MODIFY COLUMN rental_duration TINVINT(3) NOT NULL DEFAULT 5;
SHOW STATUS 显示这个语句做了1 000 次读和1 000 次插入操作。换句话说，它拷贝了整
张表到一张新表，甚至列的类型、大小和可否为NULL 属性都没改变。
理论上， MySQL 可以跳过创建新表的步骤。列的默认值实际上存在表的.frm 文件中，
所以可以直接修改这个文件而不需要改动表本身。然而MySQL 还没有采用这种优化的
方法，所有的MODIFY COLUMN 操作都将导致表重建。

另外一种方法是通过ALTER COLUMN  操作来改变列的默认值:
mysql> ALTER TABLE sakila.film
-> ALTER COLUMN rental_duration SET DEFAULT 5;
这个语句会直接修改.frm 文件而不涉及表数据。所以，这个操作是非常快的。

注意可变长字符串，其在临时表和排序时可能导致悲观的按最大长度分配内存。


第5 章 创建高性能的索引
索引(在MySQL 中也叫做"键(key)") 是存储引擎用于快速找到记录的一种数据结构。

索引优化应该是对查询性能优化最有效的手段了

5.1 索引基础
索引可以包含一个或多个列的值。如果索引包含多个列，那么列的顺序也十分重要，因
为MySQL 只能高效地使用索引的最左前缀列

5.1.1 索引的类型
MySQL 支持的索引类型
B-Tree 索引，InnoDB 则使用的是B+Tree

请注意，索引对多个值进行排序的依据是CREATE TABLE 语句中定义索引时列的顺序

CREATE TABLE People (
  last_name varchar(50) not null,
  first_name varchar(50) not null,
  dob date not null,
  gender enum('m', 'f')not null,
  key(last_name, first_name, dob)
);

可以使用B-Tree 索引的查询类型：
B-Tree 索引适用于全键值、键值范围或键前缀查找。
其中键前缀查找只适用于根据最左前缀的查找。
匹配最左前级
前面提到的索引可用于查找所有姓为Allen 的人，即只使用索引的第一列。

一些关于B-Tree 索引的限制:
• 如果不是按照索引的最左列开始查找，则无站使用索引
•不能跳过索引中的列。也就是说，前面所述的索引无法用于查找姓为Smith 并且在
某个特定日期出生的人。如果不指定名(first_name) ，则MySQL 只能使用索引的
第一列。
•如果查询中有某个列的范围查询，则其右边所有列都无怯使用索引优化查找。例如
有查询刷ERE last name=' Smith , AND 币rst name LIKE '且， AND dob = '1976-
12-23' ，这个查询只能使用索引的前两列，因为这里口KE 是一个范围条件(但是服
务器可以把其余列用于其他目的)。如果范围查询列值的数量有限，那么可以通过使
用多个等于条件来代替范围条件

这些限制都和索引列的顺序有关。在优化性能的时候，可能需要使用相同的列但顺序不同的索引来满足不
同类型的查询需求。

哈希索引
在MySQL 中，只有Memory 引擎显式支持哈希索引。这也是Memory 引擎表的默认索
引类型， Memory 引擎同时也支持B-Tree 索引。值得一提的是， Memory 引擎是支持非
唯一哈希索引的，这在数据库世界里面是比较与众不同的

p184 哈希索引也有它的限制:
InnoDB 引擎有一个特殊的功能叫做"自适应哈希索引(adaptive hash index)" 。当
InnoDB 注意到某些索引值被使用得非常频繁时，它会在内存中基于B-Tree 索引之上再
创建一个哈希索引，这样就让B-Tree 索引也具有哈希索引的一些优点，比如快速的哈希
查找

创建自定义哈希索引
思路很简单:在B-Tree 基础上创建一个伪哈希索引。这和真正的哈希索引不是一回事，
因为还是使用B-Tree 进行查找，但是它使用哈希值而不是键本身进行索引查找。你需要
做的就是在查询的where子句中手动指定使用哈希函数。

CREATE TABLE pseudohash (
  id int unsigned NOT NULL auto_increment,
  url varchar(255) NOT NULL,
  url_crc int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY(id)
);

这样实现的缺陷是需要维护哈希值。可以手动维护，也可以使用触发器实现

如果采用这种方式，记住不要使用SHA1( )和MD5()作为哈希函数。因为这两个函数计算
出来的哈希值是非常长的字符串，会浪费大量空间，比较时也会更慢。

如果数据表非常大， CRC32 ( )会出现大量的哈希冲突，则可以考虑自己实现一个简单的
64 位哈希函数。这个自定义函数要返回整数，而不是字符串。一个简单的办陆可以使用
MD5 ( )函数返回值的一部分来作为自定义哈希函

//防止冲突 
当使用哈希索引进行查询的时候，必须在WHERE 子句中包含常量值:
mysql> SELECT id FROM ur1 WHERE url_crc=CRC32(lhttp://www.mysql.com")
-> AND url=lhttp://www.mysql.com"
如果不是想查询具体
值，例如只是统计记录数(不精确的) ，则可以不带入列值，直接使用CRC32() 的哈希值
查询即可。还可以使用如FNV64 ( )函数作为哈希函数，这是移植自Percona Server 的函
数，可以以插件的方式在任何MySQL 版本中使用，哈希值为64 位，速度快，且冲突比
CRC32 ( )要少很多。

空间数据索引(R-Tree)
MyISAM 表支持空间索引，可以用作地理数据存储。和B-Tree 索引不同，这类索引无
须前缀查询。空间索引会从所有维度来索引数据。查询时，可以有效地使用任意维度来
组合查询。必须使用MySQL 的GIS 相关函数如问BRCONTAINS() 等来维护数据。MySQL
的GIS 支持并不完善，所以大部分人都不会使用这个特性。开源关系数据库系统中对
GIS 的解决方案做得比较好的是PostgreSQL 的PostGIS

全文索引
全文索引更类似于搜索引擎傲的事情
在相同的列上同时创建全文索引和基于值的B-Tree 索引不会有冲突，全文索引适用于
MATCH AGAINST 操作，而不是普通的where 条件操作。

其他索引类别
还有很多第三方的存储引擎使用不同类型的数据结构来存储索引。例如TokuDB 使用分
形树索引(fractal tree index),
多数情况下，针对InnoDB 的讨论也都适用于TokuDB

5.2 索引的优点
最常见的B-Tree 索引，按照顺序存储数据，所以MySQL 可以用来做ORDER BY 和GROUP
BY 操作。因为数据是有序的，所以B-Tree 也就会将相关的列值都存储在一起。最后，
因为索引中存储了实际的列值，所以某些查询只使用索引就能够完成全部查询。据此特
性，总结下来索引有如下三个优点:
1. 索引大大减少了服务器需要扫描的数据量。
2. 索引可以帮助服务器避免排序和临时表。
3. 索引可以将随机I/O 变为顺序I/O 。

三星系统
(three-star system) :索引将相关的记录放到一起则获得一星，如果索引中的数据顺序和
查找中的排列顺序一致则获得二星3 如果索引中的列包含了查询中需要的全部列则获得
"三星"

对于中到大型的表，索引就非常有效。但对于特大型的表，建立和使用索引的代价将随之增长。
这种情况下，则需要一种技术可以直接区分出查询需要的一组数据，而不是一条记录一条记录地匹配。
例如可以使用分区技术

5.3 高性能的索引策略
正确地创建和使用索引是实现高性能查询的基础

5.3.1 独立的列
如果查询中的列不是独立的，则MySQL 就不会使用索引。"独立的列"是指索引列不能是
表达式的一部分，也不能是函数的参数。
mysql> SELECT actor_id FROM sakila.actor WHERE actor_id + 1 = 5;
mysql> SELECT ... WHERE TO_DAYS(CURRENT_DATE) - TO_DAYS(date_col) <= 10;

5.3.2 前缀索引和索引选择性
有时候需要索引很长的字符列，这会让索引变得大且慢。一个策略是前面提到过的模拟
哈希索引。但有时候这样做还不够，还可以做些什么呢?

通常可以索引开始的部分字符，这样可以大大节约索引空间，从而提高索引效率。但
这样也会降低索引的选择性。索引的选择性是指，不重复的索引值(也称为基数，
cardinality) 和数据表的记录总数(#T) 的比值，范围从l/#T 到1 之间。索引的选择性
越高则查询效率越高，因为选择性高的索引可以让MySQL 在查找时过撞掉更多的行。
唯一索引的选择性是1 ，这是最好的索引选择性，性能也是最好的。

一般情况下某个列前缀的选择性也是足够高的，足以满足查询性能。对于BLOB、TEXT 或
者很长的VARCHAR 类型的列，必须使用前缀索引，因为MySQL 不允许索引这些列的完
整长度。

有时候需要索引很长的字符列，这会让索引变得大且慢。一个策略是前面提到过的模拟
哈希索引；

找到合适的前缀长度：方法一
为了决定前缀的合适长度，需要找到最常见的值的列表，然后和最常见的前缀列表进行
比较；
mysql> SELECT COUNT(*) AS cnt, city
-> FROM sakila.city_demo GROUP BY city ORDER BY cnt DESC LIMIT 10;
增加前缀长度，直到这个前缀的选择性接近完整列的选择性；
mysql> SELECT COUNT(*) AS cnt, LEFT(city, 3) AS pref
-> FROM sakila.city_demo GROUP BY pref ORDER BY cnt DESC LIMIT 10;
//增加前缀长度，逐步实验
mysql> SELECT COUNT(*) AS cnt, LEFT(city, 7) AS pref
-> FROM sakila.city_demo GROUP BY pref ORDER BY cnt DESC LIMIT 10;

方法二：
计算完整列的选择性，并使前缀的选择性接近于完整列的选择性
mysql> SELECT COUNT(DISTINCT city)/COUNT(*) FROM sakila.city_demo;
mysql> SELECT COUNT(DISTINCT LEFT(city, 3))/COUNT(*) AS sel3,
-> COUNT(DISTINCT LEFT(city, 4))/COUNT(*) AS sel4,
-> COUNT(DISTINCT LEFT(city, 5))/COUNT(*) AS sel5,
-> COUNT(DISTINCT LEFT(city, 6))/COUNT(*) AS sel6,
-> COUNT(DISTINCT LEFT(city, 7))/COUNT(*) AS sel7
-> FROM sakila.city_demo;
查询显示当前缀长度到达7 的时候，再增加前缀长度，选择性提升的幅度已经很小了。

创建前缀索引
mysql> ALTER TABLE sakila.city_demo ADD KEY (city(7));
前缀索引是一种能使索引更小、更快的有效办法，但另一方面也有其缺点: MySQL 无
法使用前缀索引做ORDER BY 和GROUP BY，也无法使用前缀索引做覆盖扫描。

有时候后缀索引(suffix index) 也有用途(例如，找到某个域名的所有电子邮件地址。
MySQL 原生并不支持反向索引，但是可以把字符串反转后存储，并基于此建
立前缀索引。可以通过触发器来维护这种索引

5.3.3 多列索引
mysql> SELECT film_id, actor_id FROM sakila.film_actor WHERE actor_id = 1
-> UNION ALL
-> SELECT film_id, actor_id FROM sakila.film_actor WHERE film_id = 1
-> AND actor_id <> 1;
但在MySQL 5.0 和更新的版本中，查询能够同时使用这两个单列索引进行扫描，并将结
果进行合井。这种算法有三个变种:OR 条件的联合(Union) ,AND 条件的相交(intersection) ,
组合前两种情况的联合及相交。

索引合井策略有时候是一种优化的结果，但实际上更多时候说明了表上的索引建得很糟
糕:
• 当出现服务器对多个索引做相交操作时(通常有多个AND 条件) ，通常意味着需要一
个包含所有相关列的多列索引，而不是多个独立的单列索引。
• 当服务器需要对多个索引做联合操作时(通常有多个OR 条件) ，通常需要耗费大量
CPU 和内存资源在算法的缓存、排序和合并操作上。特别是当其中有些索引的选择
性不高，需要合井扫描返回的大量数据的时候。
 • 更重要的是，优化器不会把这些计算到"查询成本" (cost) 中，优化器只关心随机
页面读取。这会使得查询的成本被"低估"，导致该执行计划还不如直接走全表扫描。
这样做不但会消耗更多的CPU 和内存资源，还可能会影响查询的井发性，但如果是
单独运行这样的查询则往往会忽略对井发性的影响

如果在EXPLAIN 中看到有索引合井，应该好好检查一下查询和表的结构，看是不是已
经是最优的。也可以通过参数optimizer_switch 来关闭索引合并功能。也可以使用
IGNORE INDEX 提示让优化器忽略掉某些索引。通常来说，还不如像在MySQL4.1 或者
更早的时代一样，将查询改写成UNION 的方式往往更好。

5.3 .4选择合适的索引列顺序
本节内容适用于B-Tree索引，哈希或者其他类型的索引井不会像B-Tree 索引一样按顺序存储数据)。

在一个多列B-Tree 索引中，索引列的顺序意味着索引首先按照最左列进行排序，其次是
第二列，等等。所以，索引可以按照升序或者降序进行扫描，以满足精确符合列顺序的
ORDER BY、GROUP BY 和DISTINCT 等子句的查询需求。

//需要计算某一列的选择性 
对于如何选择索引的列顺序有一个经验法则:将选择性最高的列放到索引最前列，
经验法则考虑的是全局基数和选择性

当不需要考虑排序和分组时，将选择性最高的列放在前面通常是很好的。这时候索引的
作用只是用于优化WHERE 条件的查找。在这种情况下，这样设计的索引确实能够最快地
过撞出需要的行，对于在WHERE 子句中只使用了索引部分前缀列的查询来说选择性也更
高。然而，性能不只是依赖于所有索引列的选择性(整体基数) ，也和查询条件的具体
值有关，也就是和值的分布有关。这和前面介绍的选择前缀的长度需要考虑的地方一样。
可能需要根据那些运行频率最高的查询来调整索引列的顺序，让这种情况下索引的选择
性最高。

最后，尽管关于选择性和基数的经验陆则值得去研究和分析，但一定要记住别忘了
WHERE 子句中的排序、分组和范围条件等其他因素，这些因素可能对查询的性能造成非
常大的影响。

5.3.5 聚簇索引
聚簇索引 并不是一种单独的索引类型，而是一种数据存储方式。具体的细节依赖于其
实现方式，但InnoDB 的聚簇索引实际上在同一个结构中保存了B-Tree 索引和数据行。

当表有聚簇索引时，它的数据行实际上存放在索引的叶子页(leafpage) 中。术语"聚簇"
表示数据行和相邻的键值紧凑地存储在一起剧。因为无故同时把数据行存放在两个不同
的地方，所以一个表只能有一个聚簇索引(不过，覆盖索引可以模拟多个聚簇索引的情况，

因为是存储引擎负责实现索引，因此不是所有的存储引擎都支持聚簇索引

InnoDB 将通过主键聚集数据

如果没有定义主键， InnoDB 会选择一个唯一的非空索引代替。如果没有这样的索引，
InnoDB 会隐式定义一个主键来作为聚簇索引。InnoDB 只聚集在同一个页面中的记录。
包含相邻键值的页面可能会相距甚远。

聚集的数据有一些重要的优点
• 可以把相关数据保存在一起。例如实现电子邮箱时，可以根据用户ID 来聚集数据，
这样只需要从磁盘读取少数的数据页就能获取某个用户的全部邮件。如果没有使用
聚簇索引，则每封邮件都可能导致一次磁盘1/0.
• 数据访问更快。聚簇索引将索引和数据保存在同一个B-Tree 中，因此从聚簇索引中
获取数据通常比在非聚簇索引中查找要快。
• 使用覆盖索引扫描的查询可以直接使用页节点中的主键值。

缺点：
• 聚簇数据最大限度地提高了1/0 密集型应用的性能，但如果数据全部都放在内存中，
则访问的顺序就没那么重要了，聚簇索引也就没什么优势了。
• 插入速度严重依赖于插入顺序。按照主键的顺序插入是加载数据到InnoDB 表中速
度最快的方式。但如果不是按照主键顺序加载数据，那么在加载完成后最好使用
0阿IMIZE TABLE命令重新组织一下表
• 更新聚簇索引列的代价很高，因为会强制InnoDB 将每个被更新的行移动到新的位
置。
• 基于聚簇索引的表在插入新行，或者主键被更新导致需要移动行的时候，可能面临
"页分裂(page split)" 的问题。当行的主键值要求必须将这一行插入到某个已捕的
页中时，存储引擎会将该页分裂成两个页面来容纳该行，这就是一次页分裂操作。
页分裂会导致表占用更多的磁盘空间。
• 聚簇索引可能导致全表扫描变慢，尤其是行比较稀疏，或者由于页分裂导致数据存
储不连续的时候。
• 二级索引(非聚簇索引)可能比想象的要更大，因为在二级索引的叶子节点包含了
引用行的主键列。
• 二级索引访问需要两次索引查找，而不是一次。
二级索引中
保存的"行指针"的实质。要记住，二级索引叶子节点保存的不是指向行的物理位置的
指针，而是行的主键值。
这意味着通过二级索引查找行，存储引擎需要找到二级索引的叶子节点获得对应的主键
值，然后根据这个值去聚簇索引中查找到对应的行。这里做了重复的工作, 两次B-Tree
查找而不是一次注. 对于InnoDB. 自适应哈希索引能够减少这样的重复工作。

InnoDB 和MylSAM 的数据分布对比
InnoDB 二级索引的叶子节点中存储的不是"行指针"，而是主键值，并以此作为指向行的"指针"。
这样的策略减少了当出现行移动或者数据页分裂时二级索引的维护工作。使用主键值当
作指针会让二级索引占用更多的空间，换来的好处是， InnoDB 在移动行时无须更新二
级索引中的这个"指针"。

在InnoDB 表中按主键顺序插入行
在InnoDB 表中按主键顺序插入行
如果正在使用InnoDB 表井且没有什么数据需要聚集，那么可以定义一个代理键
(surrogate key) 作为主键，这种主键的数据应该和应用无关，最简单的方曲是使用
AUTO_INCREME阳自增列。这样可以保证数据行是按顺序写人，对于根据主键做关联操作
的性能也会更好。
最好避免随机的(不连续且值的分布范围非常大)聚簇索引，特别是对于I/O 密集型的
应用。例如，从性能的角度考虑，使用UUID 来作为聚簇索引则会很糟糕,它使得聚簇
索引的插入变得完全随机，这是最坏的情况，使得数据没有任何聚集特性。

顺序的主键什么时候会造成更坏的结果?
对于高并发工作负载，在InnoDB 中按主键顺序插入可能会造成明显的争用。主键
的上界会成为"热点"。因为所有的插入都发生在这里，所以并发插入可能导效间
隙锁竞争。另一个热点可能是AUTO INCREMENT 锁机制;如果遇到这个问题，则可
能需妥考虑重新设计农或者应用，或者史改innodb_autoinc_lock_mode 配直。如
果你的服务器版本还不支持innodb_autoinc_lock-mode 参数，可以升级到新版本
的InnoDB ，可能对这种场景会工作得更好。

5.3.6 覆盖索引
如果一个索引包含(或者说覆盖)所有需要查询的宇段的值，我们就称
之为"覆盖索引"。

考虑一下如果查询只需要扫描索引
而无须回表，会带来多少好处:
• 索引条目通常远小于数据行大小，所以如果只需要读取索引，那MySQL 就会极大
地减少数据访问量。这对缓存的负载非常重要，因为这种情况下响应时间大部分花
费在数据拷贝上。覆盖索引对于1/0 密集型的应用也有帮助，因为索引比数据更小，
更容易全部放入内存中(这对于MylSAM 尤其正确，因为MylSAM 能压缩索引以
变得更小)。
• 因为索引是按照列值顺序存储的(至少在单个页内是如此) ，所以对于1/0 密集型的
范围查询会比随机从磁盘读取每一行数据的1/0 要少得多。对于某些存储引擎，例
如MylSAM 和Percona XtraDB ，甚至可以通过OPTIMIZE 命令使得索引完全顺序排
列，这让简单的范围查询能使用完全顺序的索引访问。
• 一些存储引擎如MylSAM 在内存中只缓存索引，数据则依赖于操作系统来缓存，因
此要访问数据需要一次系统调用。这可能会导致严重的性能问题，尤其是那些系统
调用占了数据访问中的最大开销的场景。
• 由于InnoDB 的聚簇索引，覆盖索引对InnoDB 表特别有用。InnoDB 的二级索引在
叶子节点中保存了行的主键值，所以如果二级主键能够覆盖查询，则可以避免对主
键索引的二次查询。

不是所有类型的索引都可以成为覆盖索引。覆盖索引必须要存储索引列的值，而哈希索
引、空间索引和全文索引等都不存储索引列的值，所以MySQL 只能使用B-Tree 索引做
覆盖索引。另外，不同的存储引擎实现覆盖索引的方式也不同，而且不是所有的引擎都
支持覆盖索引(在写作本书时， Memory 存储引擎就不支持覆盖索引)。

当发起一个被索引覆盖的查询(也叫做索引覆盖查询)时，在EXPLAIN 的Extra 列可以
看到"Using index" 的信息。

MySQL 查询优化器会在执行查
询前判断是否有一个索引能进行覆盖。假设索引覆盖了WHERE 条件中的字段，但不是整
个查询渺及的字段。如果条件为假(false) ， MySQL 5.5 和更早的版本也总是会回表获
取数据行，尽管井不需要这一行且最终会被过滤掉。

mysql> EXPLAIN SELECT * FROM products WHERE actor='SEAN CARREY'
-> AND title like '%APOLLO%'\G
这里索引无法覆盖该查询，有两个原因2
• 没有任何索引能够覆盖这个查询。因为查询从表中选择了所有的列，而没有任何索
引覆盖了所有的列。不过，理论上MySQL 还有一个捷径可以利用:where条件中的
列是有索引可以覆盖的，因此MySQL 可以使用该索引找到对应的actor 井检查title
是否匹配，过滤之后再读取需要的数据行。
• MySQL 不能在索引中执行LIKE 操作。这是底层存储引擎API的限制，MySQL 5.5
和更早的版本中只允许在索引中做简单比较操作(例如等于、不等于以及大于)。
MySQL 能在索引中做最左前缀匹配的LIKE 比较，因为该操作可以转换为简单的比
较操作，但是如果是通配符开头的LIKE 查询，存储引擎就无越做比较匹配。这种情
况下， MySQL 服务器只能提取数据行的值而不是索引值来做比较。

也有办法可以解决上面说的两个问题，需要重写查询井巧妙地设计索引。先将索引扩展
至覆盖三个数据列(actor， title, prod_id) ，然后按如下方式重写查询:
mysql> EXPLAIN SELECT *
-> FROM products
-> JOIN (
-> SELECT prod_id
-> FROM products
-> WHERE actor='SEAN CARREY' AND title LIKE '%APOLLO%'
-> ) AS t1 ON (t1.prod_id=products.prod_id)\G

我们把这种方式叫做延迟关联(deferred join) ，因为延迟了对列的访问。

在本书写作之际. MySQL 5.6 版本(未正式发布)包
含了在存储引擎API 上所做的一个重要的改造，其被称为"索引条件推送(index
condition pushdown)"。这个特性将大大改善现在的查询执行方式，如此一来上面
介绍的很多技巧也就不再需妥了。

5.3.7 使用索引扫描来做排序
MySQL 有两种方式可以生成有序的结果:通过排序操作，或者按索引顺序扫 ，如果
EXPLAIN 出来的type 列的值为"index" ，则说明MySQL 使用了索引扫描来做排序(不
要和Extra 列的"Using index" 搞棍淆了)。

扫描索引本身是很快的，因为只需要从一条索引记录移动到紧接着的下一条记录。但如
果索引不能覆盖查询所需的全部列，那就不得不每扫描一条索引记录就都回表查询一次
对应的行。这基本上都是随机 I/O ，因此按索引顺序读取数据的速度通常要比顺序地全
表扫描慢，尤其是在 I/O 密集型的工作负载时。

MySQL 可以使用同一个索引既满足排序，又用于查找行。因此，如果可能，设计索引
时应该尽可能地同时满足这两种任务，这样是最好的。

只有当索引的列顺序和ORDER BY 子句的顺序完全一致，并且所有列的排序方向(倒序
或正序)都一样时， MySQL 才能够使用索引来对结果做排序 。如果查询需要关联多
张表，则只有当ORDER BY 子句引用的字段全部为第一个表时，才能使用索引做排序。
ORDER BY 子句和查找型查询的限制是一样的:需要满足索引的最左前缀的要求,否则，
MySQL 都需要执行排序操作，而无法利用索引排序。

有一种情况下ORDER BY 子句可以不满足索引的最左前缀的要求，就是前导列为常量的时
候。如果WHERE 子句或者JOIN 子句中对这些列指定了常量，就可以"弥补"索引的不足。

下面这个查询也没问题，因为ORDER 即使用的两列就是索引的最左前缀:
... WHERE rental_date > '2005-05-25' ORDER BY rental_date, inventory_id;
下面这个查询在索引列的第一列上是范围条件，所以MySQL 无法使用索引的其余
列:
... WHERE rental_date > '2005-05-25' ORDER BY inventory_id, customer_id;
这个查询在inventory_id 列上有多个等于条件。对于排序来说，这也是一种范围查
询:
... WHERE rental_date = '2005-05-25' AND inventory_id IN(1,2) ORDER BY customer_
id;

5.3.8 压缩(前缀压缩)索引
MyISAM 使用前缀压缩来减少索引的大小，从而让更多的索引可以放入内存中，这在某
些情况下能极大地提高性能。默认只压缩字符串，但通过参数设置也可以对整数做压缩。
可以在CREATE TABLE 语句中指定PACK KEYS 参数来控制索引压缩的方式。

5.3.9 冗余和重复索引
重复索引是指在相同的列上按照相同的顺序创建的相同类型的索引。应该避免这样创建
重复索引，发现以后也应该立即移除。

事实上， MySQL 的唯一限制和主键限制都是通过索引实现的，

冗余索引和重复索引有一些不同。如果创建了索引(A,B)，再创建索引(A) 就是冗余索引，

冗余索引通常发生在为表添加新索引的时候。例如，有人可能会增加一个新的索引(A ,B) 
而不是扩展已有的索引(A) 。还有一种情况是将一个索引扩展为(A， ID) ，其中ID 是主键，
对于InnoDB 来说主键列已经包含在二级索引中了，所以这也是冗余的。

可以看到，表中的索引越多插入速度会越慢。一般来说，增加新索引将会导致INSERT、
UPDATE、DEL盯E 等操作的速度变慢，特别是当新增索引后导致达到了内存瓶颈的时候。
解决冗余索引和重复索引的方撞很简单，删除这些索引就可以
You can write various complicated queries against the INFORMA
TION_SCHEMA tables, but there are two easier techniques. You can use the views in Shlomi
Noach’s common_schema, a set of utility routines and views you can install into your
server (http://code.google.com/p/common-schema/). This is faster and easier than writing
the queries yourself. Or you can use the pt-duplicate-key-checker tool included with
Percona Toolkit, which analyzes table structures and suggests indexes that are duplicate
or redundant. The external tool is probably a better choice for very large servers; queries
against the INFORMATION_SCHEMA tables can cause performance problems when there is
a lot of data or a large number of tables.

如果有像WHERE A = 5 ORDER BY 10 这样的查询，这个索引会很有作用。但
如果将索引扩展为(A,B)，则实际上就变成了(A， B, ID)，那么上面查询的ORDER BY 子句
就无怯使用该索引做排序，而只能用文件排序了。所以，建议使用Percona 工具箱中的
pt-upgrade 工具来仔细检查计划中的索引变更。

5.3.10 未使用的索引
有两个工具可以帮助定位未使用的索引。最简单有效的办站是
在Percona Server 或者MariaDB 中先打开userstates 服务器变量(默认是关闭的) ，然
后让服务器正常运行一段时间，再通过查询INFORMATION_SCHEMA.INDEX_STATISTICS 就
能查到每个索引的使用频率。

另外，还可以使用Percona Toolkit 中的pt-index-usage ， 该工具可以读取查询日志，井
对日志中的每条查询进行EXPLAIN 操作，然后打印出关于索引和查询的报告。这个工具
不仅可以找出哪些索引是未使用的，还可以了解查询的执行计划——— 例如在某些情况
有些类似的查询的执行方式不一样，这可以帮助你定位到那些偶尔服务质量差的查询，
优化它们以得到一致的性能表现。该工具也可以将结果写入到MySQL 的表中，方便查
询结果。

5.3.11 索引和锁

//索引过滤掉无用行，减少了需要锁住的行数
InnoDB 只有在访问行的时候才会对其加锁，而索引能够减少InnoDB 访问的行数，从
而减少锁的数量。但这只有当InnoDB 在存储引擎层能够过滤掉所有不需要的行时才有
效。如果索引无摇过滤掉无效的行，那么在InnoDB 检索到数据并返回给服务器层以后，
MySQL 服务器才能应用WHERE 子句。这时已经无捺避免锁定行了: InnoDB 已经锁住
了这些行，到适当的时候才释放。在MySQL 5.1 和更新的版本中， InnoDB 可以在服务
器端过滤掉行后就释放锁，但是在早期的MySQL 版本中， InnoDB 只有在事务提交后才
能释放锁。

有些索引的功能相当于唯一约束，虽然该索引一直没有被查询使用，却可能是用于避免产生重复
数据的.

P219 实例

关于InnoDB 、索引和锁有一些很少有人知道的细节: InnoDB 在二级索引上使用共享
(读)锁，但访问主键需要排他(写)锁。这消除了使用覆盖索引的可能性，井且
使得SELECT FOR UPDATE 比LOCK IN SHARE MODE 或非锁定查询要慢很多。

5.4 索引案例学习 P220 
5 .4 .1 支持多种过滤条件
如果某个查询不限制性别，那么可以通过在查询条件中新增AND SEX IN ('m','f')来让MySQL 选择该索引。
但是必须加上这个列的条件， MySQL 才能够匹配索引的最左前缀。

如果发现某些查询需要创建新索
引，但是这个索引又会降低另一些查询的效率，那么应该想一下是否能优化原来的查询。

这里描述的基本原则是，尽可能
将需要做范围查询的列放到索引的后面，以便优化器能使用尽可能多的索引列。
每额外增加一个IN() 条件，优
化器需要做的组合都将以指数形式增加，最终可能会极大地降低查询性能

5.4.2 避免多个范围条件
从EXPLAIN 的输出很难区分MySQL 是要查询范围值，还是查询列表（IN中的）值。EXPLAIN
使用同样的坷"range" 来描述这两种情况；
这两种访问效率是不同的。对于范围条件查询. MySQL 无法再使
用范围列后面的其他索引到了，但是对于"多个等值条件查询"则没有这个限制。

在这个案例中，优化器的特性是影响索引策略的一个很重要的因素。如果未来版本的
MySQL 能够实现松散索引扫描，就能在一个索引上使用多个范围条件，那也就不需要
为上面考虑的这类查询使用IN() 列表了。

我们能够将其中的一个范围查询转
换为一个简单的等值比较

mysql> SELECT <cols> FROM profiles WHERE sex='M' ORDER BY rating LIMIT 100000,10;
无论如何创建索引，这种查询都是个严重的问题。因为随着偏移量的增加. MySQL 需
要花费大量的时间来扫描需要丢弃的数据。反范式化、预先计算和缓存可能是解决这类
查询的仅有策略。一个更好的办越是限制用户能够翻页的数量，实际上这对用户体验的<JKI
影响不大，因为用户很少会真正在乎搜索结果的第10000 页。

优化这类索引的另一个比较好的策略是使用延迟关联，通过使用覆盖索引查询返回需要
的主键，再根据这些主键关联原表获得需要的行。这可以减少MySQL 扫描那些需要丢
弃的行数
mysql> SELECT <cols> FROM profiles INNER JOIN (
-> SELECT <primary key cols> FROM profiles
-> WHERE x.sex='M' ORDER BY rating LIMIT 100000, 10
-> ) AS x USING(<primary key cols>);

5.5 维护索引和表
维护表有三个主要的目的找到井修复损坏的表，维护准确
的索引统计信息，减少碎片。
5.5.1 找到并修复损坏的表
如果你遇到了古怪的问题————例如一些不应该发生的错误————可以
尝试运行CHECK TABLE 来检查是否发生了表损坏
可以使用REPAIR TABLE 命令来修复损坏的表，但同样不是所有的存储引擎都支持该命令。
如果存储引擎不支持，也可通过一个不做任何操作(no-op) 的ALTER 操作来重建表，例
如修改表的存储引擎为当前的引擎。下面是一个针对InnoDB 表的例子:
mysql> ALTER TABLE innodb_tbl ENGINE=INNODB;
此外，也可以使用一些存储引擎相关的离线工具，例如myisamchk ， 或者将数据导出一份，
然后再重新导入。不过，如果损坏的是系统区域，或者是表的"行数据"区域，而不是
索引，那么上面的办站就没有用了。在这种情况下，可以从备份中恢复表，或者尝试从
损坏的数据文件中尽可能地恢复数据。

如果InnoDB 引擎的表出现了损坏，那么一定是发生了严重的错误，需要立刻调查一下
原因。
常见的类似错误通常是由于尝试使用rsync 备份InnoDB 导致的。

可以通过设置innodb_force_recovery 参数进入InnoDB 的
强制恢复模式来修复数据，更多细节可以参考MySQL 手册。另外，还可以使用开源的
InnoDB 数据恢复工具箱(InnoDB Data Recovery Toolkit) 直接从InnoDB 数据文件恢复出
数据

5.5.2 更新索引统计信息
MySQL 的查询优化器会通过两个API 来了解存储引擎的索引值的分布信息，以决定
如何使用索引。第一个API 是records_in_range( )，通过向存储引擎传入两个边界
值获取在这个范围大概有多少条记录。对于某些存储引擎，该接口返回精确值，例如
MyISAM ，但对于另一些存储引擎则是一个估算值，例如InnoDB 。
第二个API 是info() ，该接口返回各种类型的数据，包括索引的基数(每个键值有多少
条记录)。
如果存储引擎向优化器提供的扫描行数信息是不准确的数据，或者执行计划本身太复杂
以致无战准确地获取各个阶段匹配的行数，那么优化器会使用索引统计信息来估算扫描
行数。MySQL 优化器使用的是基于成本的模型，而衡量成本的主要指标就是一个查询
需要扫描多少行。如果表没有统计信息，或者统计信息不准确，优化器就很有可能做出
错误的决定。可以通过运行ANALYZE TABLE 来重新生成统计信息解决这个问题。

可以使用SHOW INDEX FROM 命令来查看索引的基数(Cardinality)
索引列的基数(Cardinali ty) ，其显示了存储
引擎估算索引列有多少个不同的取值

InnoDB 的统计信息值得深入研究。InnoDB 引擎通过抽样的方式来计算统计信息，首先
随机地读取少量的索引页面，然后以此为样本计算索引的统计信息。在老的InnoDB 版
本中，样本页面数是8 ，新版本的InnoDB 可以通过参数innodb_stats_sample_pages 来
设置样本页的数量。设置更大的值，理论上来说可以帮助生成更准确的索引信息，特别
是对于某些超大的数据表来说，但具体设置多大合适依赖于具体的环境。

InnoDB 会在表首次打开，或者执行ANALYZE TABLE ，抑或表的大小发生非常大的变化
(大小变化超过十六分之一或者新插入了20 亿行都会触发)的时候计算索引的统计信息。
InnoDB 在打开某些INFORMATION SCHEMA 衰，或者使用SHOW TABLE STATUS 和SHOW
INDEX ，抑或在MySQL 客户端开启自动补全功能的时候都会触发索引统计信息的更新。
如果服务器上有大量的数据，这可能就是个很严重的问题，尤其是当1/0 比较慢的时候。
客户端或者监控程序触发索引信息采样更新时可能会导致大量的锁，并给服务器带来很
多的额外压力，这会让用户因为启动时间漫长而沮丧。只要SH刷INDEX 查看索引统计信
息，就一定会触发统计信息的更新。可以关闭innodb_stats_on_metadata 参数来避免上
面提到的问题。

5.5.3 减少索引和数据的碎片
可以通过执行OPTIMIZE TABLE 或者导出再导人的方式来重新整理数据
对于那些不支持OPTI阳ZE TABLE 的存储引擎，可以通过一个不做任何操作(no-op) 的
ALTER TABLE 操作来重建表。只需要将表的存储引擎修改为当前的引擎即可:
mysql> ALTER TABLE <table> ENGINE=<engine>;

对于开启了expand_fast_index_creation 参数的Percona Server ，按这种方式重建表，
则会同时消除表和索引的碎片化。但对于标准版本的MySQL 则只会消除表(实际上是
聚簇索引)的碎片化。可用先删除所有索引，然后重建表，最后重新创建索引的方式模
拟Percona Server 的这个功能。

应该通过一些实际测量而不是随意假设来确定是否需要消除索引和表的碎片化

1. 单行访问是很慢的。特别是在机械硬盘存储中(SSD 的随机I/O 要快很多，不过这
一点仍然成立)。如果服务器从存储中读取一个数据块只是为了获取其中一行，那么
就浪费了很多工作。最好读取的块中能包含尽可能多所需要的行。使用索引可以创
建位置引用以提升效率。
2. 按顺序访问范围数据是很快的，这有两个原因。第一，顺序I/O 不需要多次磁盘寻道，
所以比随机I/O要快很多(特别是对机械硬盘)。第二，如果服务器能够按需要顺序
读取数据，那么就不再需要额外的排序操作，井且GROUP BY 查询也无须再做排序和
将行按组进行聚合计算了。
3. 索引覆盖查询是很快的。如果一个索引包含了查询需要的所有列，那么存储引擎就
不需要再回表查找行。这避免了大量的单行坊问，而上面的第1 点已经写明单行访
问是很慢的。

总的来说，编写查询语句时应该尽可能选择合适的索引以避免单行查找、尽可能地使用
数据原生顺序从而避免额外的排序操作，井尽可能使用索引覆盖查询。这与本章开头提
到的Lahdenmaki 和Leach 的书中的"三星"评价系统是一致的

//第三章
那如何判断一个系统创建的索引是合理的呢?一般来说，我们建议按响应时间来对查询~
进行分析。找出那些消耗最长时间的查询或者那些给服务器带来最大压力的查询(第3
章中介绍了如何测量) ，然后检查这些查询的schema 、SQL 和索引结构，判断是否有查
询扫描了太多的行，是否做了很多额外的排序或者使用了临时表，是否使用随机1/0 访
问数据，或者是有太多回表查询那些不在索引中的列的操作。

如果仍然想找到那些索引不是很合适的查询，
并在它们成为问题前进行优化，则可以使用pt-query-digest 的查询审查"review" 功能，
分析其EXP山N 出来的执行计划。

第6 章
6.1 为什么查询速度会慢
通常来说，查询的生命周期大致可以按照顺序来看:从客户端，到服务器，然后
在服务器上进行解析，生成执行计划，执行，并返回结果给客户端

6.2 慢查询基础：优化数据访问
查询性能低下最基本的原因是访问的数据太多。
对于低效的查询，我们发现通过下面两个步骤来分析总是很有效：
1. 确认应用程序是否在检索大量超过需要的数据。这通常意味着访问了太多的行，但
有时候也可能是访问了太多的列。
2. 确认MySQL 服务器层是否在分析大量超过需要的数据行。

6.2.1 是否向数据库请求了不需要的数据
查询不需要的记录
一个常见的错误是常常会误以为MySQL 会只返回需要的数据，实际上MySQL 却
是先返回全部结果集再进行计算。最简单有效的解决方站就是在这样的查询后面加上LIMIT。

如果你想查询所有在电影Academy Dinosaur 中出现的演员，千万不要按下面的写捷
编写查询:
mysql> SELECT * FROM sakila.actor
-> INNER JOIN sakila.film_actor USING(actor_id)
-> INNER JOIN sakila.film USING(film_id)
-> WHERE sakila.film.title = 'Academy Dinosaur';
这将返回这三个表的全部数据列。正确的方式应该是像下面这样只取需要的列：
mysql> SELECT sakila.actor.* FROM sakila.actor...;

总是取出全部到
每次看到SELECT *的时候都需要用怀疑的眼光审视

重复查询相同的数据

6.2.2 MySQL 是否在扫描额外的记录
查询为了返回结果是否扫描了过多的数据。对于MySQL ，最简单的衡量查询开销的三个指标如下:
• 晌应时间
• 扫描的行数
• 返回的行数

这三个指标都会记录到MySQL 的慢日志中，所以检查慢日志记录是找出扫描行数过多的查询的好办法。

晌应时间
要记住，响应时间只是一个表面上的值
响应时间是两个部分之和:服务时间和排队时间。服务时间是指数据库处理这个查询
真正花了多长时间。排队时间是指服务器因为等待某些资源而没有真正执行查询的时
间————可能是等I/O操作完成，也可能是等待行锁，等等。遗憾的是，我们无陆把晌应
时间细分到上面这些部分，除非有什么办陆能够逐个测量上面这些消耗，不过很难做到。
一般最常见和重要的等待是I/O 和锁等待，但是实际情况更加复杂。

扫描的行数和返回的行数
理想情况下扫描的行数和返回的行数应该是相同的

扫描的行数和访问类型
在EXPLAIN 语句中的type 列反应了访问类型；
如果查询没有办陆找到合适的访问类型，那么解决的最好办陆通常就是增加一个合适的索引。

一般MySQL 能够使用如下三种方式应用WHERE条件，从好到坏依次为
• 在索引中使用WHERE 条件来过滤不匹配的记录。这是在存储引擎层完成的。
• 使用索引覆盖扫描(在Extra 列中出现了Using index) 来返回记录，直接从索引中
过滤不需要的记录并返回命中的结果。这是在MySQL 服务器层完成的，但无须再
回表查询记录。
• 从数据表中返回数据，然后过施不满足条件的记录(在Extra 列中出现Using
Where) 。这在MySQL 服务器层完成， MySQL 需要先从数据表读出记录然后过滤。

Understanding how many
rows the server accesses and how many it really uses requires reasoning about the query

如果发现查询需要扫描大量的数据但只返回少数的行，那么通常可以尝试下面的技巧去
优化它:
• 使用索引覆盖扫描，把所有需要用的列都放到索引中，这样存储引擎无须回表获取
对应行就可以返回结果了(在前面的章节中我们已经讨论过了)。
• 改变库表结构。例如使用单独的汇总表(这是我们在第4 章中讨论的办告)。
• 重写这个复杂的查询，让MySQL 优化器能够以更优化的方式执行这个查询(这是
本章后续需要讨论的问题)。

6.3 重构查询的方式
6.3.1 一个复杂查询还是多个简单查询
6.3.2 切分查询
有时候对于一个大查询我们需要"分而治之"，将大查询切分成小查询，每个查询功能
完全一样，只完成一小部分，每次只返回一小部分查询结果。

删除旧的数据就是一个很好的例子。定期地清除大量数据时，如果用一个大的语句一次
性完成的话，则可能需要一次锁住很多数据、占满整个事务日志、艳尽系统资源、阻塞
很多小的但重要的查询。将一个大的DEL盯E 语句切分成多个较小的查询可以尽可能小地
影响MySQL 性能，同时还可以减少MySQL 复制的延迟

6.3.3 分解关联查询
• 让缓存的效率更高。许多应用程序可以方便地缓存单表查询对应的结果对象。
。另外，对MySQL 的查询缓存来说注6 ，如果关联中的某个表发生了变化，
那么就无撞使用查询缓存了，而拆分后，如果某个表很少改变，那么基于该表的查
询就可以重复利用查询缓存结果了。

6.4 查询执行的基础
当希望MySQL 能够以更高的性能运行查询时，最好的办法就是弄清楚MySQL 是如何
优化和执行查询的。
6 .4 .1 MySQL 客户端/服务器通信协议
MySQL 客户端和服务器之间的通信协议是"半双工"的，这意味着，
在任何一个时刻，要么是由服务器向客户端发送数据，要么是由客户端向服务器发送
数据，这两个动作不能同时发生

客户端用一个单独的数据包将查询传给服务器。这也是为什么当查询的语句很长的时候，
参数max_allowed_packet 就特别重要了

在必要的时候一定要在查询中加上LIMIT 限制的原因。

多数连接MySQL 的库函数都可以获得全部结果集井缓存到内存里，还可以远行获取需
耍的数据。默认一般是获得全部结果集并缓存到内存中。MySQL 通常需要等所有的数
据都已经发送给客户端才能释放这条查询所占用的资源，所以接收全部结果井缓存通常
可以减少服务器的压力，让查询能够早点结束、早点释放相应的资源。

多数情况下这没什么问题，但是如果需要返回一个很大的结果集的时候，这样做并不好，因为库函数
会花很多时间和内存来存储所有的结果集。如果能够尽早开始处理这些结果集，就能大
大减少内存的捎耗，这种情况下可以不使用援存来记录结果而是直接处理。这样做的缺
点是，对于服务器来说，需要查询完成后才能释放资橱，所以在和客户端交互的整个过
程中，服务器的资源都是被这个查询所占用的。

查询状态
查看当前的状态，最简单的是使用SHOW FULL
PROCESSLIST 命令(该命令返回结果中的Command 列就表示当前的状态)

6.4.2 查询缓存
6 .4 .3 查询优化处理
语法解析器和预处理可以通过查询当前会话的Last_query_cost 的值来得知MySQL 计算的当前查询的成本。

列表IN() 的比较
在很多数据库系统中， IN ( )完全等同于多个OR 条件的子句，因为这两者是完全等
价的。在MySQL 中这点是不成立的， MySQL 将IN ()列表中的数据先进行排序，
然后通过二分查找的方式来确定列表中的值是否满足条件，这是一个O(log n) 复杂
度的操作，等价地转换成OR 查询的复杂度为O(时，对于IN() 列表中有大量取值的
时候， MySQL 的处理速度将会更快。

数据和索引的统计信息
统计信息由存储引擎实现

MySQL 如何执行关联查询
MySQL 认为任何一个查询都是一次"关联"
当前MySQL 关联执行的策略很简单: MySQL 对任何关联都执行嵌套循环关联操作，即
MySQL 先在一个表中循环取出单条数据，然后再嵌套循环到下一个表中寻找匹配的行，
依次下去，直到找到所有表中匹配的行为止。然后根据各个表E配的行，返回查询中需
要的各个列。MySQL 会尝试在最后一个关联表中找到所有匹配的行，如果最后一个关
联表无战找到更多的行以后， MySQL 返回到上一层次关联表，看是否能够找到更多的
匹配记录，依此类推迭代执行。

内联结：
mysq1> SELECT tbl1.col1 , tb12.col2
-> FROM tbl1 INNER JOIN tb12 USING(coI3)
-> WHERE tbl1.col1 IN(5 , 6)
pseudocode:
outer_iter = iterator over tbl1 where col1 IN(S ,6)
outer row = outer iter.next
while outer row
  inner iter = iterator over tb12 where co13 = outer row.co13
  inner row = inner iter.next
  while inner row
    output [ outer_row.col1 , inner_row.co12 1
    inner row = inner iter.next
  end 
  outer row = outer iter.next
end

左外联结：
mysq1> SELECT tbl1.col1, tbl2.col2
-> FROM tbl1 LEFT OUTER JOIN tb12 USING(coI3) 
-> WHERE tbl1.col1 IN(5 ,6)
伪代码：
outer_iter = iterator over tbl1 where col1 IN(5,6)
outer_row = outer_iter.next
while outer_row
  inner_iter = iterator over tbl2 where col3 = outer_row.col3
  inner_row = inner_iter.next
  if inner_row
    while inner_row
      output [ outer_row.col1, inner_row.col2 ]
      inner_row = inner_iter.next
    end
  else
    output [ outer_row.col1, NULL ]
  end
  outer_row = outer_iter.next
end

另一种可视化查询执行计划的方曲是根据优化器执行的路径绘制出对应的"泳道图"

从本质上说， MySQL 对所有的类型的查询都以同样的方式运行。例如， MySQL 在FROM
子句中遇到子查询时，先执行子查询并将其结果放到一个临时表中注16 ，然后将这个临时
表当作一个普通表对待(正如其名"派生表"). MySQL 在执行UNION 查询时也使用类
似的临时表，在遇到右外连接的时候， MySQL 将其改写成等价的左外连接。简而言之，
当前版本的MySQL 会将所有的查询类型都转换成类似的执行计划

注16: MySQL 的临时农是没有任何索引的，在编写复杂的子查询和关联查询的时候需要注意这一点。这
一点对UNION 查询也一样。
注17 : 在MySQL5.6 和MariaDB 中有了重大改变，这两个版本都引入了支加复杂的执行计划。

全外连接就无怯通过嵌套循环
和回湖的方式完成，这时当发现关联表中没有找到任何匹配行的时候，则可能是因为关
联是恰好从一个没有任何匹配的表开始。这大概也是MySQL 并不支持全外连接的原因。

执行计划
和很多其他关系数据库不同， MySQL 并不会生成查询字节码来执行查询。MySQL 生成
查询的一棵指令树，然后通过存储引擎执行完成这棵指令树井返回结果。最终的执行计
划包含了重构查询的全部信息。如果对某个查询执行即叫N 眩TENDED 后，再执行SHOW
WARNINGS ，就可以看到重构出的查询

P254 
所以， MySQL 的执行计划总是如图6-4 所示，是一棵左测深度优先的树。

//交给优化器去做吧 
关联查询优化器
MySQL 优化器最重要的一部分就是关联查询优化，它决定了多个表关联时的顺序。通
常多表关联的时候，可以有多种不同的关联顺序来获得相同的执行结果。关联查询优化
器则通过评估不同顺序时的成本来选择一个代价最小的关联顺序。

可以使用STRAIGHT JOIN 关键字重写查询，让优
化器按照你认为的最优的关联顺序执行

排序优化
无论如何排序都是一个成本很高的操作，所以从性能角度考虑，应尽可能避免排序或者
尽可能避免对大量数据进行排序。

在内存或磁盘上排序，统一称为文件排序 

如果需要排序的数据量小于"排序缓冲区"， MySQL 使用内存进行"快速排序"操
作。如果内存不够排序，那么MySQL 会先将数据分块，对每个独立的块使用"快速排
序"进行排序，井将各个块的排序结果存放在磁盘上，然后将各个排好序的块进行合并
(merge) ，最后返回排序结果。

MySQL 有如下两种排序算怯:
读取行指针和需要排序的字段，对其进行排序，然后再根据排序结果读取所需要的
数据行。
这需要进行两次数据传输，即需要从数据表中读取两次数据，第二次读取数据的时
候，因为是读取排序列进行排序后的所有记录，这会产生大量的随机1/ 0 ，所以两
次数据传输的成本非常高

羊次传输排序(新版本使用)
先读取查询所需要的所有列，然后再根据给定列进行排序，最后直接返回排序结果。

当查询需要所有
列的总长度不超过参数max_length_for_sort_data 时， MySQL 使用"单次传输排
序"，可以通过调整这个参数来影响MySQL 排序算怯的选择。关于这个细节，可以
参考第8 章"文件排序优化"

MySQL 在进行文件排序的时候需要使用的临时存储空间可能会比想象的要大得多。原
因在于MySQL 在排序时，对每一个排序记录都会分配一个足够长的定长空间来存放。
这个定长空间必须足够长以容纳其中最长的字符串，例如，如果是VARC陆R 列则需要分
配其完整长度，如果使用UTF-8 宇符集，那么MySQL 将会为每个字符预留三个字节。

在关联查询的时候如果需要排序， MySQL 会分两种情况来处理这样的文件排序。如
果ORDER BY 子句中的所有列都来自关联的第一个衰，那么MySQL 在关联处理第一
个表的时候就进行文件排序。如果是这样，那么在MySQL 的EXPLAIN 结果中可以看到
Extra 字段会有"Using filesort" 。除此之外的所有情况， MySQL 都会先将关联的结果
存放到一个临时表中，然后在所有的关联都结束后，再进行文件排序。这种情况下，在
MySQL 的EXPLAIN 结果的Extra 宇段可以看到"Using tempora叩; Using filesort" 。如果
查询中有LIMIT 的话, LIMIT 也会在排序之后应用，所以即使需要返回较少的数据，临
时表和需要排序的数据量仍然会非常大。

6.4.4 查询执行引擎
6 .4 .5 返回结果给客户端

//注意:更高版本的mysql可能会取消这些限制
6.5 MySQL 查询优化器的局限性
6.5.1 关联子查询
MySQL 的子查询实现得非常糟腾。最糟糕的一类查询是WHERE 条件中包含IN() 的子查
询语句
//在MySQL 8.0种已经不存在这种查询方式，所以在优化时还是使用
//explain看一下
mysql> SELECT * FROM sakila.film
-> WHERE film_id IN(
-> SELECT film_id FROM sakila.film_actor WHERE actor_id = 1);
MySQL 会将相关的外层表压到子查询中
MySQL 会将查询改写成下面的样子:
EXPLAIN SELECT * FROM sakila.film
WHERE EXISTS (
SELECT * FROM sakila.film_actor WHERE actor_id = 1
AND film_actor.film_id = film.film_id);
通过EXPLAIN 我们可以看到子查询是一个相关子查询
(DEPENDE町SUBQUERY)
//优化查询
mysql) SELECT film.* FROM sakila. film
-) INNER JOIN sakila.film_actor USING(film_id)
-)WHERE actor_id = 1
另一个优化的办站是使用函数GROUP CONCAT() 在IN() 中构造一个由逗号分隔的列表。
有时这比上面的使用关联改写更快。因为使用IN() 加子查询，性能经常会非常糟，所以
通常建议使用EXISTS() 等效的改写查询来获取更好的效率。

如何用好关联子查询
井不是所有关联子查询的性能都会很差，先测试，然后做出自己的判断。
EXPLAIN SELECT film_id, language_id FROM sakila.film
-> WHERE NOT EXISTS(
-> SELECT * FROM sakila.film_actor
-> WHERE film_actor.film_id = film.film_id
-> )\G
一般会建议使用左外连接(LEFT OUTER JOIN) 重写该查询，以代替子查询。理论上，改
写后MySQL 的执行计划完全不会改变。
mysql> EXPLAIN SELECT film.film_id, film.language_id
-> FROM sakila.film
-> LEFT OUTER JOIN sakila.film_actor USING(film_id)
-> WHERE film_actor.film_id IS NULL\G

6.5.2 UNION 的限制
有时， MySQL 无告将限制条件从外层"下推"到内层，这使得原本能够限制部分返回
结果的条件无怯应用到内层查询的优化上。
如果希望UNION 的各个子句能够根据LIMIT 只取部分结果集，或者希望能够先排好序再
合并结果集的话，就需要在UNION 的各个子句中分别使用这些子句

(SELECT first_name, last_name
FROM sakila.actor
ORDER BY last_name)
UNION ALL
(SELECT first_name, last_name
FROM sakila.customer
ORDER BY last_name)
LIMIT 20;
这条查询将会把actor 中的200 条记录和customer 表中的599 条记录存放在一个临时
表中，然后再从临时表中取出前20 条。可以通过在UNION 的两个子查询中分别加上一个
LIMIT 20 来减少临时表中的数据:

(SELECT first_name, last_name
FROM sakila.actor
ORDER BY last_name
LIMIT 20)
UNION ALL
(SELECT first_name, last_name
FROM sakila.customer
ORDER BY last_name
LIMIT 20)
LIMIT 20;
从临时表中取出数据的顺序并不是一定的，所以如果想获得正确的顺序，还需要加上一
个全局的ORDER BY 和LIMIT 操作。

6.5.3 索引合并优化
6.5.4等值传递
6.5.5 并行执行
MySQL 无法利用多核特性来并行执行查询。

6.5.6 哈希关联
6.5.7 松散索引扫描
通常， MySQL 的索引扫描需要先定义一个起点和终点，即使需要的数据只是这
段索引中很少数的几个， MySQL 仍需要扫描这段索引中每→个条目。
下面我们通过一个示例说明这点。假设我们有如下索引(a ， b) ，有下面的查询:
mysql> SELECT ... FROM tbl WHERE b BETWEEN 2 AND 3;
因为索引的前导字段是列a 但是在查询中只指定了字段b ， MySQL 无陆使用这个索引，
从而只能通过全表扫描找到匹配的行

MySQL 5.0 之后的版本，在某些特殊的场景下是可以使用松散索引扫描的，例如，在一
个分组查询中需要找到分组的最大值和最小值
mysql> EXPLAIN SELECT actor_id, MAX(film_id)
-> FROM sakila.film_actor
-> GROUP BY actor_id\G
*************************** 1. row ***************************
id: 1
select_type: SIMPLE
table: film_actor
type: range
possible_keys: NULL
key: PRIMARY
key_len: 2
ref: NULL
rows: 396
Extra: Using index for group-by
在EXPLAIN 中的Extra 字段显示"Using index for group-by" ，表示这里将使用松散索引
扫描
在MySQL5.6 之后的版本，关于松散索引扫描的一些限制将会通过"索引条件下推(index
condition pushdown)" 的方式解决。

6.5.8 最大值和最小值优化
mysql> SELECT MIN(actor_id) FROM sakila.actor WHERE first_name = 'PENELOPE';
因为在first_name 字段上并没有索引，因此MySQL 将会进行一次全表扫描
一个曲线的优化办法是移除MIN() ，然后使用LIMIT 来将查询重写如下：
mysql> SELECT actor_id FROM sakila.actor USE INDEX(PRIMARY)
-> WHERE first_name = 'PENELOPE' LIMIT 1;

6.5.9 在同一个表上查询和更新
MySQL 不允许对同一张表同时进行查询和更新。
mysql> UPDATE tbl AS outer_tbl
-> SET cnt = (
-> SELECT count(*) FROM tbl AS inner_tbl
-> WHERE inner_tbl.type = outer_tbl.type
-> );
ERROR 1093 (HY000): You can’t specify target table 'outer_tbl' for update in FROM
clause
可以通过使用生成表的形式来绕过上面的限制，因为MySQL 只会把这个表当作一个临
时表来处理。实际上，这执行了两个查询:一个是子查询中的SELECT语句，另一个是多
表关联UPDATE ，只是关联的表是一个临时衰。子查询会在UPDATE 语句打开表之前就完成，
mysql> UPDATE tbl
-> INNER JOIN(
-> SELECT type, count(*) AS cnt
-> FROM tbl
-> GROUP BY type
-> ) AS der USING(type)
-> SET tbl.cnt = der.cnt;

6.6 查询优化器的提示( hint)
通过在查询中加入相应的提示，就可以控制该查询的执行计划；
建议直接阅读MySQL 官方手册

HIGH PRIORITY 和 LOW PRIORITY
这两个提示只对使用表锁的存储引擎有效，千万不要在InnoDB 或者其他有细粒度
锁机制和井发控制的引擎中使用。即使是在MyISAM 中使用也要注意，因为这两个
提示会导致井发插入被禁用，可能会严重降低性能。
HIGH PRIORIlY和LOW PRIORIlY经常让人感到困惑。这两个提示并不会获取更多资
摞让查询"积极"工作，也不会少获取资源让查询"消极"工作。它们只是简单地
控制了MySQL 访问某个数据表的队列顺序。

这个提示可以放置在SELECT 语句的SELECT 关键字之后，也可以放置在任何两个关
联表的名字之间。第一个用怯是让查询中所有的表按照在语句中出现的顺序进行关
联。第二个用越则是固定其前后两个表的关联顺序。
当MySQL 没能选择正确的关联顺序的时候，或者由于可能的顺序太多导致MySQL
无战评估所有的关联顺序的时候， STRAIGHT JOIN 都会很有用。在后面这种情况，
MySQL 可能会花费大量时间在"statistics" 状态，加上这个提示则会大大减少优化
器的搜索空间。

SQL_SMALL_RESULT 和SQL_ BIG RESULT
这两个提示只对SELE口语句有效。它们告诉优化器对GROUP BY 或者DISTINCT 查询
如何使用临时表及排序。SQL_SMALL_RESULT 告诉优化器结果集会很小，可以将结果
集放在内存中的索引临时表，以避免排序操作。如果是SQL BIG RESULT，则告诉优
化器结果集可能会非常大，建议使用磁盘临时表做排序操作

SQL_BUFFER_RESULT
这个提示告诉优化器将查询结果放入到一个临时表，然后尽可能快地释放表锁。
代价是，服务器端将需要更多的内存。

SQL_CALC_FOUND_ROWS 
查询中加上该提示MySQL 会计算
 除去LIMIT 子句后这个查询要返回的结果集的总数，而实际上只返回LIMIT 要求的
结果集。可以通过函数FOUND_ROW( )获得这个值

FOR UPDATE 和LOCK IN SHARE MODE
这两个提示主要控制SELECT 语句的锁机制，但只对
实现了行级锁的存储引擎有效。使用该提示会对符合查询条件的数据行加锁。对于
INSERT. . .SELECT 语句是不需要这两个提示的，因为对于MySQL 5.0 和更新版本会
默认给这些记录加上读锁。
唯一内置的支持这两个提示的引擎就是InnoDB。另外需要记住的是，这两个提示会
让某些优化无撞正常使用，例如索引覆盖扫描。InnoDB 不能在不访问主键的情况下
排他地锁定行，因为行的版本信息保存在主键中。

USE INDEX、IGNORE INDEX 和FORCE INDEX
这几个提示会告诉优化器使用或者不使用哪些索引来查询记录(例如，在决定关联
顺序的时候使用哪个索引)。在MySQL 5.0 和更早的版本，这些提示并不会影响到
优化器选择哪个索引进行排序和分组，在MyQL 5.1 和之后的版本可以通过新增选
项FOR ORDER BY 和FOR GROUP BY 来指定是否对排序和分组有效。
FORCE INDEX 和USE INDEX 基本相同，除了一点: FORCE INDEX 会告诉优化器全表扫
描的成本会远远高于索引扫描，哪怕实际上该索引用处不大。当发现优化器选择了
错误的索引，或者因为某些原因(比如在不使用ORDER BY 的时候希望结果有序)要
使用另一个索引时，可以使用该提示。

在MySQL5.0 和更新版本中，新增了一些参数用来控制优化器的行为:
optimizer_search_depth
这个参数控制优化器在穷举执行计划时的限度。如果查询长时间处于"Statistics"
状态，那么可以考虑调低此参数。
optimizer_prune_level
该参数默认是打开的，这让优化器会根据需要扫描的行数来决定是否跳过某些执行
计划。
optimizer_switch 
这个变量包含了一些开启/关闭优化器特性的标志位。例如在MySQL 5.1 中可以通
过这个参数来控制禁用索引合井的特性。

使用Percona Toolkit 中的pt-upgrade 工具，就可以检查在新版本中运行的SQL 是否与
老版本一样，返回相同的结果。

6.7 优化特定类型的查询
本节介绍的多数优化技巧都是和特定的版本有关的，所以对于未来MySQL 的版本未必
适用。

COUNTO 的作用
COUNT ( )是一个特殊的函数，有两种非常不同的作用z 它可以统计某个列值的数量，也
可以统计行数。在统计列值时要求列值是非空的(不统计NULL) 。如果在COUNT( )的括
号中指定了列或者列的表达式，则统计的就是这个表达式有值的结果数注飞因为很多人
对NULL 理解有问题，所以这里很容易产生误解。如果想了解更多关于SQL 语句中NULL
的含义，建议阅读一些关于SQL 语句基础的书籍。(关于这个话题，互联网上的一些信
息是不够精确的。

关于MylSAM 的神话
一个容易产生的误解就是: MyISAM 的COU阳()函数总是非常快，不过这是有前提条件的，
即只有没有任何刷E旺条件的COU阳(*)才非常快，因为此时无须实际地去计算表的行数。

简单的优化
有时候可以使用MyISAM 在COUNT( 叫全表非常快的这个特性，来加速一些特定条件的
COUNT( )的查询
mysql> SELECT COUNT(*) FROM world.City WHERE ID > 5;
如果将条件反转一下，先查找IO 小于等于5 的城市数，然后用总城市数一减就能得到同样的结果。
mysql> SELECT (SELECT COUNT(*) FROM world.City) - COUNT(*)
-> FROM world.City WHERE ID <= 5;

在同一个查询中统计同一个列的不同值的数量，以减少查询的语句量：
//也可以写成这样的5UM() 农达式: 5UM(color = 'blue'， SUM(color = 'red')
mysql> SELECT SUM(IF(color = 'blue', 1, 0)) AS blue,SUM(IF(color = 'red', 1, 0))
-> AS red FROM items;
也可以使用COUNT( )而不是SUM( )实现同样的目的，只需要将满足条件设置为真，不满
足条件设置为NULL 即可
mysql> SELECT COUNT(color = 'blue' OR NULL) AS blue, COUNT(color = 'red' OR NULL)
-> AS red FROM items;

使用近似值
有时候某些业务场景并不要求完全精确的COUNT值，此时可以用近似值来代替。EXPLAIN
出来的优化器估算的行数就是一个不错的近似值，执行EXPLAIN 并不需要真正地去执行
查询，所以成本很低。

更复杂的优化
通常来说， COUNT() 都需要扫描大量的行(意味着要访问大量数据)才能获得精确的结
果，因此是很难优化的。除了前面的方棒，在MySQL 层面还能做的就只有索引覆盖扫
描了。如果这还不够，就需要考虑修改应用的架构，可以增加汇总表(第4 章已经介绍过) ,
或者增加类似Memcached 这样的外部缓存系统。可能很快你就会发现陆入到一个熟悉的
困境，"快速，精确和实现简单"，三者永远只能满足其二，必须舍掉其中一个。

6.7.2 优化关联查询
• 确保ON 或者USING 子句中的列上有索引。在创建索引的时候就要考虑到关联的顺序。
当表A 和表B 用列c 关联的时候，如果优化器的关联顺序是B、A ，那么就不需要在
B 表的对应列上建上索引。没有用到的索引只会带来额外的负担。一般来说，除非
有其他理由，否则只需要在关联顺序中的第二个表的相应列上创建索引。
• 确保任何的GROUP BY 和ORDER BY 中的表达式只涉及到一个表中的列，这样MySQL
才有可能使用索引来优化这个过程。
• 当升级MySQL 的时候需要注意:关联语陆、运算符优先级等其他可能会发生变化
的地方。因为以前是普通关联的地方可能会变成笛卡儿积，不同类型的关联可能会
生成不同的结果等。

6.7.3 优化子查询
关于子查询优化我们给出的最重要的优化建议就是尽可能使用关联查询代替
如果使用的是MySQL 5.6 或更新的版本或者MariaDB ，那么就可以直接忽
略关于子查询的这些建议了。

6.7.4 优化GROUP BY 和DISTINCT
它们都可以使用索引来优化，这也是最有效的优化办法。
//文件排序使用临时表
在MySQL 中，当无法使用索引的时候， GROUP BY 使用两种策略来完成, 使用临时表或
者文件排序来做分组。对于任何查询语句，这两种策略的性能都有可以提升的地方。可
以通过使用提示SQL BIG RESULT 和SQL SMALL RESULT 来让优化器按照你希望的方式运
行。

如果需要对关联查询做分组(GROUP BY) ，井且是按照查找表中的某个列进行分组，那
么通常采用查找表的标识列分组的效率会比其他列更高。
mysql> SELECT actor.first_name, actor.last_name, COUNT(*)
-> FROM sakila.film_actor
-> INNER JOIN sakila.actor USING(actor_id)
-> GROUP BY actor.first_name, actor.last_name;
The query is more efficiently written as follows:
mysql> SELECT actor.first_name, actor.last_name, COUNT(*)
-> FROM sakila.film_actor
-> INNER JOIN sakila.actor USING(actor_id)
-> GROUP BY film_actor.actor_id;
使用acto.actor_id 列分组的效率甚至会比使用film_actor.actor_id 更好

This query takes advantage of the fact that the actor’s first and last name are dependent
on the actor_id, so it will return the same results, but it’s not always the case that you
can blithely select nongrouped columns and get the same result. You might even have
the server’s SQL_MODE configured to disallow it. You can use MIN() or MAX() to work
around this when you know the values within the group are distinct because they depend
on the grouped-by column, or if you don’t care which value you get:
mysql> SELECT MIN(actor.first_name), MAX(actor.last_name), ...;

但若更在乎的是MySQL 运行查询的效率时这样做也无可厚非。如果实在较真的话也可以改写成下面的形式
mysql> SELECT actor.first_name, actor.last_name, c.cnt
-> FROM sakila.actor
-> INNER JOIN (
-> SELECT actor_id, COUNT(*) AS cnt
-> FROM sakila.film_actor
-> GROUP BY actor_id
-> ) AS c USING(actor_id) ;
这样写更满足关系理论，但成本有点高，因为子查询需要创建和填充临时表，而子查询
中创建的临时表是没有任何索引的
在分组查询的提出口中直接使用非分组列通常都不是什么好主意，因为这样的结果通常
是不定的，当索引改变，或者优化器选择不同的优化策略时都可能导致结果不一样。我
们碰到的大多数这种查询最后都导致了故障(因为MySQL 不会对这类查询返回错误) ,
而且这种写曲大部分是由于偷懒而不是为优化而故意这么设计的。建议始终使用含义明
确的语曲。事实上，我们建议将MySQL 的SQL_MOOE 设置为包含ONLY_FULL_GROUP_BY ，
这时MySQL 会对这类查询直接返回一个错误，提醒你需要重写这个查询。

如果没有通过ORDER BY 子句显式地指定排序列，当查询使用GROUP BY子句的时候，结
果集会自动按照分组的字段进行排序。如果不关心结果集的顺序，而这种默认排序又导
致了需要文件排序，则可以使用ORDER BY NULL ，让MySQL 不再进行文件排序。也可
以在GROUP BY子句中直接使用DESC 或者ASC 关键字，使分组的结果集按需要的方向排序。

优化GROUP BY WITH ROLLUP
可以通过EXPLAIN 来观察其
执行计划，特别要注意分组是否是通过文件排序或者临时表实现的.然后再去掉WITH
ROLLUP 子句看执行计划是否相同。也可以通过本节前面介绍的优化器提示来固定执行计
划。
最好的办曲是尽可能的将WITH ROLLUP 功能转移到应用程序中处理。

6.7.5 优化LIMIT 分页
优化此类分页查询的一个最简单的办格就是尽可能地使用索引覆盖扫描，而不是查询所
有的列。然后根据需要做一次关联操作再返回所需的列。对于偏移量很大的时候，这样
做的效率会提升非常大。考虑下面的查询:
Mysql> 5ELECT film_id, description F刷sakila.film ORDER BY title LIMIT 50, 5;
如果这个表非常大，那么这个查询最好改写成下面的样子
mysql> SELECT film.film_id, film.description
-> FROM sakila.film
-> INNER JOIN (
-> SELECT film_id FROM sakila.film
-> ORDER BY title LIMIT 50, 5
-> ) AS lim USING(film_id);
这个技术也可以用于优化关联查询中的LIMIT 子句。

有时候也可以将LIMIT 查询转换为已知位置的查询，让MySQL 通过范围扫描获得到对
应的结果
mysql> SELECT film_id, description FROM sakila.film
-> WHERE position BETWEEN 50 AND 54 ORDER BY position;

如果可以使用书签记录上次取数据的位置，那么下次就可以直接从该
书签记录的位置开始扫描，这样就可以避免使用OFFSET.

6.7.6 优化SQL_CALC_FOUND_ROWS
分页的时候，另一个常用的技巧是在LIMIT语句中加上SQL_CALC_FOUND_ROWS提示(hint) ,
这样就可以获得去掉LIMIT 以后满足条件的行数，因此可以作为分页的总数。

不管是否需要， MySQL 都会扫描所有满足条件的行，然后再抛弃掉不需要的行，而不
是在满足LIMIT 的行数后就终止扫描。所以该提示的代价可能非常高.

一个更好的设计是将具体的页数换成"下一页"按钮，假设每页显示20 条记录，那么
我们每次查询时都是用LI 问IT 返回21 条记录并只显示20 条，如果第21 条存在，那么
我们就显示"下一页"按钮，否则就说明没有更多的数据，也就无须显示"下一页"按
钮了。

另一种做站是先获取井缓存较多的数据

6.7.7 优化UNION 查询
MySQL 总是通过创建井填充临时表的方式来执行UNION 查询。因此很多优化策略在
UNION 查询中都没怯很好地使用。经常需要手工地将刷ERE、LIMIT、ORDER 町等子句"下
推"到UNION 的各个子查询中，以便优化器可以充分利用这些条件进行优化(例如，直
接将这些子句冗余地写一份到各个子查询)。

//
除非确实需要服务器消除重复的行，否则就一定要使用UNION ALL ，这一点很重要。如
果没有ALL 关键字， MySQL 会给临时表加上DISTINCT 选项，这会导致对整个临时表的
数据做唯一性检查。这样做的代价非常高。

6.7.8 静态查询分析
Percona Toolkit 中的pt-query-advisor 能够解析查询日志、分析查询模式，然后给出所有
可能存在潜在问题的查询，并给出足够详细的建议

6.7.9 使用用户自定义变量
在查询中混合使用过程化和关系化逻辑的时候，自定义变量可能会非常有用

用户自定义变量是一个用来存储内容的临时容器，在连接MySQL 的整个过程中都存在。
可以使用下面的SET 和SELECT 语句来定义它们
mysql> SET @one := 1;
mysql> SET @min_actor := (SELECT MIN(actor_id) FROM sakila.actor);
mysql> SET @last_week := CURRENT_DATE-INTERVAL 1 WEEK;

不能使用用户自定义变量z
• 使用自定义变量的查询，无战使用查询缓存。
• 不能在使用常量或者标识符的地方使用自定义变量，例如表名、列名和LIM盯子句中.
• 用户自定义变量的生命周期是在一个连接中有效，所以不能用它们来做连接间的通
信.
• 如果使用连接地或者持久化连接，自定义变量可能让看起来毫无关系的代码发生交
互(如果是这样，通常是代码bug 或者连接地bug. 这类情况确实可能发生)。
• 在5.0 之前的版本，是大小写敏感的，所以要注意代码在不同MySQL 版本间的兼容
性问题.
• 不能显式地声明自定义变量的类型。确定未定义变量的具体类型的时机在不同
MySQL 版本中也可能不一样。如果你希望变量是整数类型，那么最好在初始化的时
候就赋值为0 ，如果希望是浮点型则赋值为0.0 ，如果希望是字符串则赋值为''，用〈噩3
户自定义变量的类型在赋值的时候会改变。MySQL 的用户自定义变量是一个动态
类型。
• MySQL 优化器在某些场景下可能会将这些变量优化掉，这可能导致代码不按预想的
方式运行。
• 赋值的顺序和赋值的时间点并不总是固定的，这依赖于优化器的决定
• 贼值符号.-的优先级非常低，所以需要注意，赋值表达式应该使用明确的括号。
• 使用未定义变量不会产生任何语禧错误，如果没有意识到这一点，非常容易犯错。

优化排名语旬
使用用户自定义变量的一个重要特性是你可以在给一个变量赋值的同时使用这个变
量。换句话说，用户自定义变量的赋值具有"左值"特性。
mysql> SET @rownum := 0;
mysql> SELECT actor_id, @rownum := @rownum + 1 AS rownum
-> FROM sakila.actor LIMIT 3;

//使用变量会出现"诡异"的现象

避免重复查询刚刚更新的数据
如果在更新行的同时叉希望获得该行的信息，在MySQL 中你可以使用变量来解决这个
问题
UPDATE t1 SET lastUpdated = NOW() WHERE id = 1 AND @now := NOW();
SELECT @now;
这里的第二个查询无须访问任何数据表，所以会快非常多

统计更新和插入的数量
当使用了INSERT ON DUPLlCATE 旺Y UPDATE 的时候，如果想知道到底插入了多少行数据，
到底有多少数据是因为冲突而改写成更新操作的? Kerstian Köhntopp 在他的博客上给出
了一个解决这个问题的办撞撞30. 实现办撞的本质如下z
INSERT INTO t1(c1, c2) VALUES(4, 4), (2, 1), (3, 1)
ON DUPLICATE KEY UPDATE
c1 = VALUES(c1) + ( 0 * ( @x := @x +1 ) );
当每次由于冲突导致更新时对变量@x自增一次。然后通过对这个表达式乘以0 来让其不
影响要更新的内容。另外， MySQL 的协议会返回被更改的总行数，所以不需要单独统
计这个值。

mysql> SET @rownum := 0;
mysql> SELECT actor_id, @rownum := @rownum + 1 AS cnt
-> FROM sakila.actor
-> WHERE @rownum <= 1
-> ORDER BY first_name;
This query returns every row in the table, because the ORDER BY added a filesort and the
WHERE is evaluated before the filesort。
解决这个问题的办站是让变量的赋值和取值发生在执行查询的同一阶段:
mysql> SET @rownum := 0;
mysql> SELECT actor_id, @rownum AS rownum
-> FROM sakila.actor
-> WHERE (@rownum := @rownum + 1) <= 1;

//出现诡异的现象 
mysql> SET @rownum := 0;
mysql> SELECT actor_id, @rownum AS rownum
-> FROM sakila.actor
-> WHERE (@rownum := @rownum + 1) <= 1;

SET @rownum := 0;
 SELECT actor_id, first_name, @rownum AS rownum
FROM sakila.actor
 WHERE @rownum <= 1
ORDER BY first_name, LEAST(0, @rownum := @rownum + 1);
我们将赋值语句放到LEAST() 函
数中，这样就可以在完全不改变排序顺序的时候完成赋值操作(在上面例子中， L日町()
函数总是返回0) .这个技巧在不希望对子句的执行结果有影响却又要完成变量赋值的
时候很有用。
。这个例子中，无须在返回值中新增额外列。这样的函数还有GREATEST() 、
LENGHT() 、ISNULL() 、NULLIFL() 、IF() 和COALESCE ( ) ，可以单独使用也可以组合使用。
例如， COALESCE ( )可以在一组参数中取第一个已经被定义的变量

编写偷懒的UNION
假设需要编写一个UNION 查询，其第一个子查询作为分支条件先执行，如果找到了E配
的行，则跳过第二个分支
一
且在第一个表中找到记录，我们就定义一个变量@found. 我们通过在结果列中做一次赋
值来实现，然后将赋值放在函数GR臼JEST 中来避免返回额外的数据。
SELECT GREATEST(@found := −1, id) AS id, 'users' AS which_tbl
//如果where成立，则select,那么@found就被定义了
FROM users WHERE id = 1
UNION ALL
SELECT id, 'users_archived'
FROM users_archived WHERE id = 1 AND @found IS NULL
UNION ALL
//按照上下文意思，是先返回值，再赋值
SELECT 1, 'reset' FROM DUAL WHERE ( @found := NULL ) IS NOT NULL;

优化器会把变量当作一个
编译时常量来对待，而不是对其进行赋值。将函数放在类似于LEAST( )这样的函数中通
常可以避免这样的问题。另一个办告是在查询被执行前检查变量是否被赋值。不同的场
景下使用不同的办单。

6.8.1 使用MySQL 构建一个队列表
CREATE TABLE unsent_emails (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  -- columns for the message, from, to, subject, etc.
  status ENUM('unsent', 'claimed', 'sent'),
  owner INT UNSIGNED NOT NULL DEFAULT 0,
  ts TIMESTAMP,
  KEY (owner, status, ts)
);

//两次查询之间会持有锁
BEGIN;
  SELECT id FROM unsent_emails
  WHERE owner = 0 AND status = 'unsent'
  LIMIT 10 FOR UPDATE;
  -- result: 123, 456, 789
  UPDATE unsent_emails
  SET status = 'claimed', owner = CONNECTION_ID()
  WHERE id IN(123, 456, 789);
COMMIT;
//改写的版本
SET AUTOCOMMIT = 1;
COMMIT;
UPDATE unsent_emails
  SET status = 'claimed', owner = CONNECTION_ID()
  WHERE owner = 0 AND status = 'unsent'
  LIMIT 10;
SET AUTOCOMMIT = 0;
  SELECT id FROM unsent_emails
  WHERE owner = CONNECTION_ID() AND status = 'claimed';
  -- result: 123, 456, 789
所有的SELECT FOR UPDATE 都可以使用类似的方法改写。

有时，最好的办站就是将任务队列从数据库中迁移出来。Redis 就是一个很好的队列容
器，也可以使用memcached 来实现。RabbitMQ 和Gearman也可以实现类似的功能。

6.8.2 计算两点之间的距离
不建议用户使用MySQL 做太复杂的空间信息存储——— PostgreSQL 在这方面是不错的选择

先使用简单的方案过滤大多数数据，然后再到过滤出来的更小的集合上使用复杂的
公式运算

6.8.3 使用用户自定义函数
当你需要更快的速度，那么C 和C++ 是很好的选择
户自定义函数(UDFs)