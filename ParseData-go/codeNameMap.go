package main

//name字段的值，必须唯一

type indicator struct{
	code string         //指标代码，在世界银行数据库中为INDICATOR_CODE
	namecn string         //指标名字，在世界银行数据库中为INDICATOR_NAME
	name string        //指标名字的英文
	note string    //指标说明，在世界银行数据库中为SOURCE_NOTE
}

func codenamemap()map[string][]indicator{
	//GDP项
   var gdp = []indicator{
	   indicator{
		  code: "NY.GDP.MKTP.CN",
		  name: "gdp",              
		  namecn: "国内生产总值，GDP",
		  note: "GDP（现价本币单位),以购买者价格计算的 GDP是一个经济体内所有居民生产者创造的增加值的总和加上任何产品税并减去不包括在产品价值中的补贴。计算时未扣除资产折旧或自然资源损耗和退化。数据按当地货币不变价格计。",
	   },
	   indicator{
		   code: "NY.GDP.MKTP.KD.ZG",
		   name: "growthrate",   
		   namecn: "GDP增长率",
		   note: "市场价格GDP年增长率基于不变价本币计算。总额计算基于2010 年不变价美元。GDP 是一个经济体内所有居民生产者创造的增加值的总和，加上任何产品税并减去不包括在产品价值中的补贴。计算时未扣除资产折旧或自然资源损耗和退化。",
	   },
	   indicator{
		  code: "NY.GDP.PCAP.KN",
		  name: "avgvalue",   
		  namecn: "人均 GDP（不变价本币单位）",
		  note: "人均GDP是国内生产总值除以年中人口数。以购买者价格计算的 GDP是一个经济体内所有居民生产者创造的增加值的总和加上任何产品税并减去不包括在产品价值中的补贴。计算时未扣除资产折旧或自然资源损耗和退化。数据以本币不变价计。",
	   },
	   indicator{
		   code: "NY.GDP.PCAP.KD.ZG",
		   name: "avggrowthrate", 
		   namecn: "人均 GDP增长（年增长率）",
		   note: "基于不变价本币的人均GDP年增长率人均GDP是国内生产总值除以年中人口数。以购买者价格计算的 GDP是一个经济体内所有居民生产者创造的增加值的总和加上任何产品税并减去不包括在产品价值中的补贴。计算时未扣除资产折旧或自然资源损耗和退化。数据以2010年不变价美元计。",
	   },
	   /*
	   indicator{
		   code: "NY.GDP.MKTP.PP.CD",
		   name :"GDPPPPCurrent",   
		   namecn: "按购买力平价 (PPP) 衡量的 GDP（现价国际元）",
		   note: "按购买力平价 (PPP) 衡量的 GDP（现价国际元）,按购买力平价(PPP)计算的GDP是指用购买力平价汇率换算为国际元的国内生产总值。国际元的购买力与美元在美国的购买力相当。GDP是一个经济体内所有居民生产者创造的增加值的总和加上产品税并减去不包括在产品价值中的补贴。计算时未扣除资产折旧或自然资源损耗和退化。数据以现价国际元计。",
	   },*/
	}
	
	//人口项
	var population = []indicator{    
		indicator{
			code: "SP.POP.TOTL",   
			name: "total",
			namecn: "人口总数",
			note: "Total population is based on the de facto definition of population, which counts all residents regardless of legal status or citizenship. The values shown are midyear estimates.",
		},
		indicator{
			code: "SP.POP.TOTL.FE.ZS",   
			name: "femaleratio",
			namecn: "人口，女性（占总人口的百分比）",
			note: "女性人口是指女性在人口中的百分比。人口是根据实际存在的人口定义确定的。",
		},
		indicator{
			code: "SP.POP.1564.TO",    
			name: "15to64",
			namecn: "15-64岁的人口总数",
			note: "15-64岁之间的人口",
		},
		indicator{
		   code: "SP.POP.1564.TO.ZS",   
		   name: "15to64ratio",
		   namecn: "15-64岁的人口（占总人口的百分比）",
           note: "15至64岁的人口是15至64岁年龄组的总人口的百分比。人口是根据约定俗成的人口定义确定的。",
		},
	}
	
	//货币项
	var money = []indicator{
		indicator{
			code: "NY.GDS.TOTL.CN",
			name: "domestictotalsavings", 
			namecn: "国内总储蓄（现价本币)",
			note: "国内总储蓄的计算是用 GDP 减去最终消费支出（总消费）。数据按当地货币不变价格计。",
		},
		indicator{
			code: "FR.INR.RINR",
			name: "realinterestrate",  
			namecn: "实际利率 （%）",
			note: "实际利率是指按 GDP平减指数衡量的通胀调整贷款利率。",
		},
		/*
		indicator{
			code: "NY.GDS.TOTL.ZS",
			name: "DomesticTotalSavingsGDPRatio", //国内总储蓄（占 GDP 的百分比）
		},
		indicator{
			code: "NY.ADJ.NNAT.GN.ZS",
			name:"AdjSavingsNatNetRation",   //	调整后的储蓄：国民储蓄净额（占 GNI 的百分比）
		},
		indicator{
			code: "NY.ADJ.NNAT.CD",
			name: "AdjSavingsNatNet",	    //调整后的储蓄：国民储蓄净额（现价美元）
		},
		indicator{
		   code: "NY.ADJ.ICTR.GN.ZS",
		   name: "AdjSavingsGNIRatio",	   //调整后的储蓄： 总储蓄（占 GNI 的百分比）
	    },*/
   }  
	
   //收入
	var income = []indicator{
		indicator{
			code: "NY.ADJ.NNTY.PC.KD.ZG", 
			name: "adjavgnetincomeratio",   
			namecn: "人均调整国民收入净额（每年％的增长）",
			note: "调整后的国民净收入是GNI减去固定资本消耗和自然资源损耗。",
		},
		/*
		indicator{
			code: "NY.ADJ.NNTY.PC.KD",
			name: "AdjAvgNetIncome",   //调整后的国民净人均收入（2010年不变价美元）
		},
		indicator{
		   code: "NY.ADJ.NNTY.KD.ZG", 
		   name: "AdjPopNetIncomRatio", //调整后的国民净收入（年增长率）
		},*/
    }
	
	//工业
	var industry = []indicator{
		indicator{
			code: "NV.IND.TOTL.KN",
			name: "increment",
			namecn: "工业增加值（不变价格本币单位）",
			note: "工业与 ISIC 第 10-45 项相对应，并包括制造业（ISIC 第 15-37 项）。其中包括采矿业、制造业（同时作为独立组别予以公布）、建筑业、电力、水和天然气行业中的增加值。增加值为所有产出相加再减去中间投入得出的部门的净产出。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值的来源是根据《国际标准行业分类》第3修订版确定的。数据按不变价本币计。",
		},
		indicator{
		    code: "NV.IND.TOTL.KD.ZG",	
			name: "incrementrate",	
			namecn: "工业增加值（年增长率）",
			note: "工业增加值年增长率的计算基于不变价本币。总额的计算基于2010 年不变价美元。工业与 ISIC 第 10-45 项相对应，包括制造业（ISIC 第 15-37 项）。其中包括采矿业、制造业（同时作为独立组别予以公布）、建筑业、电力、水和天然气行业中的增加值。增加值为所有产出相加再减去中间投入得出的部门的净产出。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值的来源根据《国际标准行业分类》第3修订版确定。",
		},
		indicator{
			code: "NV.IND.TOTL.ZS",
		    name: "gdpincrement",
		    namecn: "工业增加值（占 GDP 的百分比）",
		    note: "工业与 ISIC 第 10-45 项相对应，并包括制造业（ISIC 第 15-37 项）。其中包括采矿业、制造业（同时作为独立组别予以公布）、建筑业、电力、水和天然气行业中的增加值。增加值为所有产出相加再减去中间投入得出的部门的净产出。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值来源是根据《国际标准行业分类》（ISIC）修订本第3版确定的。注： 对于 VAB 国家，用按要素成本计算的总增加值作为分母。",
		},
	}
	
	//制造业
	/*
	var manufacturing = []indicator{
		indicator{
			code: "NV.IND.MANF.KN",	
			name: "increment", //修改名字，使得名字在dataMap中唯一
			namecn: "制造业，增加值（不变价本币单位）",
			note: "制造业指的是属于国际标准产业分类（ISIC）中第15-37类的产业。增加值是一个部门在总计了各项产值并减去了中间投入之后的净产 值。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值的来源是根据《国际标准行业分类》第3修订版确定的。数据按不变价本币计。",
		},
		indicator{
			code: "NV.IND.MANF.KD.ZG",
			name: "inrgrowthrate",
			namecn: "制造业，增加值（年增长百分比）",
			note: "根据不变价本本币计算的制造业增加值的年增长率。总数是根据2010年不变价美元计算的。制造业指的是属于国际标准产业分类（ISIC）中第15-37类的产业。增加值是一个部门在总计了各项产值并减去了中间投入之后的净产值。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值的来源根据《国际标准行业分类》第3修订版确定。",
	    },
		indicator{
			code: "NV.IND.MANF.ZS",
		    name: "gdpmanfinr",
		    namecn: "制造业，增加值（占GDP的百分比）",
		    note: "制造业指的是属于国际标准产业分类（ISIC）中第15-37类的产业。增加值是一个部门在总计了各项产值并减去了中间投入之后的净产 值。这种计算方法未扣除装配式资产的折旧或自然资源的损耗和退化。增加值来源是根据《国际标准行业分类》（ISIC）修订本第3版确定的。注： 对于 VAB 国家，用按要素成本计算的总增加值作为分母",
		},
	
		
    }*/
	
	//商品进出口
	var importexport = []indicator{
	    indicator{
			code: "TG.VAL.TOTL.GD.ZS",
			name: "gdpcomdtdratio",
			namecn: "商品贸易（GDP的百分比）",
            note: "商品贸易占GDP的比重是商品出口和进口的总和除以GDP的价值，所有这些都是以现价美元计算的。",
		},
		indicator{
			code: "TX.VAL.MANF.ZS.UN",
            name: "manfexportcomdratio",
			namecn: "制造业出口（占商品出口的百分比)",
			note: "制造业商品是包括在国际贸易标准分类（SITC）中的第5部分（化工产品）、第6部分（基础制造业产品）、第7 部分（机械和运输设备）、以及第8部分（其他制造业产品）中的商品，其中不包括第68类（有色金属）商品。",
		},
	}

	//TODO: 税收、政府支出 

	var items = make(map[string][]indicator)
	items["gdp"] = gdp
	items["population"] = population
	items["money"] = money
	items["income"] = income
	items["industry"] = industry
	//items["manufacturing"] = manufacturing
	items["importexport"] = importexport
	
	return items
}

